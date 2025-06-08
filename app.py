from flask import Flask, request, jsonify
import os
import json
import cv2
import numpy as np
import pickle
from collections import defaultdict, deque, Counter
import mediapipe as mp
import torch
import torch.nn as nn

app = Flask(__name__)

# ── 설정값 ────────────────────────────────────────────────────────────────
STATIC_MODEL_DIR    = "models/static"
DYNAMIC_MODEL_DIR   = "models/dynamic"
MIN_STATIC_FRAMES   = 10    # 퀴즈/학습 모드(자음·모음)에서 사용할 프레임 수
MIN_DYNAMIC_FRAMES  = 20    # 학습 모드(단어 등 동적)에서 사용할 프레임 수
MAX_BUFFER          = 300   # 내부 버퍼 최대 크기
CONF_THRESHOLD      = 0.7   # MediaPipe 신뢰도 문턱

# 한글→영어 카테고리 맵핑 (퀴즈 모드)
CATEGORY_MAP = {
    "자음": "consonant",
    "모음": "vowel",
}

# ── 프레임 버퍼 ────────────────────────────────────────────────────────────
# 퀴즈 전용 (자음·모음 10장)
quiz_buffers  = defaultdict(lambda: deque(maxlen=MIN_STATIC_FRAMES))
# 학습 전용 (동적 20장 / 정적 10장)
learn_buffers = defaultdict(lambda: deque(maxlen=MAX_BUFFER))

# ── MediaPipe 초기화 ───────────────────────────────────────────────────────
mp_hands = mp.solutions.hands
mp_pose  = mp.solutions.pose
hands = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=2,
    min_detection_confidence=CONF_THRESHOLD,
    min_tracking_confidence=CONF_THRESHOLD
)
pose = mp_pose.Pose(
    min_detection_confidence=CONF_THRESHOLD,
    min_tracking_confidence=CONF_THRESHOLD
)

# ── 정적 모델(SVM) 로드 ───────────────────────────────────────────────────
svm_cons_path  = os.path.join(STATIC_MODEL_DIR, "svm_model_consonants.pkl")
lbl_cons_path  = os.path.join(STATIC_MODEL_DIR, "label_encoder_consonants.pkl")
svm_vowl_path  = os.path.join(STATIC_MODEL_DIR, "svm_model_vowels.pkl")
lbl_vowl_path  = os.path.join(STATIC_MODEL_DIR, "label_encoder_vowels.pkl")

SVM_CONS_MODEL = pickle.load(open(svm_cons_path, "rb"))
CONS_LABELS    = pickle.load(open(lbl_cons_path, "rb"))
SVM_VOWL_MODEL = pickle.load(open(svm_vowl_path, "rb"))
VOWL_LABELS    = pickle.load(open(lbl_vowl_path, "rb"))

def predict_static(frames_bgr, model, labels):
    """여러 프레임에 대해 SVM 예측 → 다수결 최빈 레이블 반환"""
    preds = []
    for idx, img_bgr in enumerate(frames_bgr):
        img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        res     = hands.process(img_rgb)
        detected = bool(res.multi_hand_landmarks)
        conf     = res.multi_handedness[0].classification[0].score if res.multi_handedness else 0.0
        print(f"[static] frame#{idx}: detected={detected}, conf={conf:.2f}")
        if not detected or conf < CONF_THRESHOLD:
            continue
        lm = res.multi_hand_landmarks[0]
        kp = [c for lmpt in lm.landmark for c in (lmpt.x, lmpt.y, lmpt.z)]
        if len(kp) != 63:
            continue
        arr = np.array(kp).reshape(1, -1)
        cls = model.predict(arr)[0]
        preds.append(labels.get(cls, ""))
    if not preds:
        return None
    most, cnt = Counter(preds).most_common(1)[0]
    print(f"[static] 최빈='{most}' ({cnt}/{len(preds)})")
    return most

# ── 동적 모델(LSTM) 클래스 & 로드 ─────────────────────────────────────────
class LSTMModel(nn.Module):
    def __init__(self, input_dim=32, hidden_dim=128, num_classes=5):
        super().__init__()
        self.lstm = nn.LSTM(input_dim, hidden_dim, batch_first=True)
        self.fc1  = nn.Linear(hidden_dim, 128)
        self.fc2  = nn.Linear(128, num_classes)
    def forward(self, x):
        out, _ = self.lstm(x)
        out    = out[:, -1, :]
        out    = self.fc1(out)
        return self.fc2(out)

loaded_dynamic = {}
for fname in os.listdir(DYNAMIC_MODEL_DIR):
    if not fname.endswith(".pth"):
        continue
    cat        = fname.split("_")[0]
    model_path = os.path.join(DYNAMIC_MODEL_DIR, fname)
    label_path = os.path.join(DYNAMIC_MODEL_DIR, f"{cat}_label.json")
    if not os.path.exists(label_path):
        print(f"⚠️ 레이블 누락: {label_path}")
        continue
    with open(label_path, "r", encoding="utf-8") as f:
        label_map = json.load(f)
    num_cls = len(label_map)
    model   = LSTMModel(input_dim=32, hidden_dim=128, num_classes=num_cls)
    state   = torch.load(model_path, map_location="cpu")
    model.load_state_dict(state)
    model.eval()
    loaded_dynamic[cat] = {
        "model":  model,
        "labels": {int(k): v for k, v in label_map.items()}
    }
    print(f"✅ 동적 모델 로드 완료: {cat} ({num_cls} classes)")

def calc_angles(multi_hands, handedness_list, pose_landmarks):
    """MediaPipe landmarks → 32차원 각도 벡터"""
    try:
        left = np.zeros(15, dtype=np.float32)
        right= np.zeros(15, dtype=np.float32)
        # 손 관절
        for i, hand in enumerate(multi_hands):
            lab = handedness_list[i].classification[0].label
            pts = np.array([[lm.x,lm.y,lm.z] for lm in hand.landmark])
            v1  = pts[[0,1,2,3,  0,5,6,7,  0,9,10,11,  0,13,14,15,  0,17,18,19]]
            v2  = pts[[1,2,3,4,  5,6,7,8,  9,10,11,12,  13,14,15,16,  17,18,19,20]]
            v   = (v2 - v1) / np.linalg.norm(v2-v1, axis=1, keepdims=True)
            ang = np.degrees(np.arccos(np.clip(
                np.einsum('nt,nt->n',
                          v[[0,1,2,4,5,6,8,9,10,12,13,14,16,17,18]],
                          v[[1,2,3,5,6,7,9,10,11,13,14,15,17,18,19]]
                ), -1,1)))
            if lab=="Left":  left = ang
            else:            right= ang
        # 팔각도
        lm = pose_landmarks.landmark
        def angle(a,b,c):
            ba,bc = a-b, c-b
            ba/=np.linalg.norm(ba); bc/=np.linalg.norm(bc)
            return np.degrees(np.arccos(np.clip(np.dot(ba,bc),-1,1)))
        L = np.array([[lm[11].x,lm[11].y,lm[11].z],
                      [lm[13].x,lm[13].y,lm[13].z],
                      [lm[15].x,lm[15].y,lm[15].z]])
        R = np.array([[lm[12].x,lm[12].y,lm[12].z],
                      [lm[14].x,lm[14].y,lm[14].z],
                      [lm[16].x,lm[16].y,lm[16].z]])
        return np.concatenate([left, right, [angle(*L), angle(*R)]])
    except:
        return None

def predict_dynamic(frames_bgr, cat):
    """최근 MIN_DYNAMIC_FRAMES 프레임 LSTM 예측"""
    cfg = loaded_dynamic.get(cat)
    if not cfg:
        return None
    seq = []
    for img_bgr in frames_bgr[-MIN_DYNAMIC_FRAMES:]:
        rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        hr  = hands.process(rgb)
        pr  = pose.process(rgb)
        if not hr.multi_hand_landmarks or not pr.pose_landmarks:
            continue
        ang = calc_angles(hr.multi_hand_landmarks, hr.multi_handedness, pr.pose_landmarks)
        if ang is not None and ang.shape[0]==32:
            seq.append(ang)
    if len(seq)<MIN_DYNAMIC_FRAMES:
        return None
    X = torch.tensor(np.array(seq)[None,...], dtype=torch.float32)
    with torch.no_grad():
        idx = cfg["model"](X).argmax(dim=1).item()
        return cfg["labels"].get(idx)

# ── 퀴즈 모드: 자음·모음만 10장 모아서 예측 ───────────────────────────────
@app.route("/check-quiz", methods=["sPOST"])
def handle_quiz():
    raw_cat = request.form.get("category","")
    mapped   = CATEGORY_MAP.get(raw_cat, raw_cat)
    c
    rategory = mapped.lower()
     
    user_id = request.form.get("user_id","")
    step    = request.form.get("step","")

    # 1) 이미지(들) 읽어서 quiz_buffers에 쌓기
    files = request.files.getlist("images")
    if not files and 'image' in request.files:
        files = [request.files['image']]
    if not files:
        return jsonify({"error":"images 또는 image 필드 필요"}),400

    buf = quiz_buffers[user_id]
    for f in files:
        img = cv2.imdecode(np.frombuffer(f.read(), np.uint8), cv2.IMREAD_COLOR)
        buf.append(img)

    collected = len(buf)
    if collected < MIN_STATIC_FRAMES:
        return jsonify({
            "status":          "waiting",
            "frames_collected":collected,
            "needed":          MIN_STATIC_FRAMES-collected
        }), 200

    # 2) 다 모였으면 predict_static → 결과 반환
    frames = list(buf)
    model, labels = (SVM_CONS_MODEL, CONS_LABELS) if category=="consonant" else (SVM_VOWL_MODEL, VOWL_LABELS)
    pred = predict_static(frames, model, labels)
    buf.clear()  # 버퍼 초기화

    if not pred:
        return jsonify({"status":"fail","error":"손 인식 실패"}),200

    result = "O" if pred==step else "X"
    return jsonify({
        "status":     "success",
        "predicted":  pred,
        "result":     result,
        "frames_used":MIN_STATIC_FRAMES
    }),200

# ── 학습 모드: 정적/동적 모두 처리 ─────────────────────────────────────────
@app.route("/check-sign", methods=["POST"])
def handle_sign():
    raw_cat = request.form.get("category","")
    # 동적 카테고리(단어 등)는 이미 영어로 넘어온다고 가정
    category= CATEGORY_MAP.get(raw_cat, raw_cat)
    user_id = request.form.get("user_id","")
    step    = request.form.get("step","")

    # 1) 이미지 읽어서 learn_buffers에 쌓기
    files = request.files.getlist("images")
    if not files and 'image' in request.files:
        files = [request.files['image']]
    if not files:
        return jsonify({"error":"images 또는 image 필드 필요"}),400

    buf = learn_buffers[user_id]
    for f in files:
        img = cv2.imdecode(np.frombuffer(f.read(), np.uint8), cv2.IMREAD_COLOR)
        buf.append(img)

    collected = len(buf)
    # -- 정적(자음·모음) --
    if category in ("consonant","vowel"):
        if collected < MIN_STATIC_FRAMES:
            return jsonify({
                "status":"waiting",
                "frames_collected":collected,
                "needed":MIN_STATIC_FRAMES-collected
            }),200
        frames = list(buf)[-MIN_STATIC_FRAMES:]
        model, labels = (SVM_CONS_MODEL, CONS_LABELS) if category=="consonant" else (SVM_VOWL_MODEL, VOWL_LABELS)
        pred = predict_static(frames, model, labels)

    # -- 동적(단어·카테고리별) --
    else:
        if collected < MIN_DYNAMIC_FRAMES:
            return jsonify({
                "status":"waiting",
                "frames_collected":collected,
                "needed":MIN_DYNAMIC_FRAMES-collected
            }),200
        frames = list(buf)[-MIN_DYNAMIC_FRAMES:]
        pred = predict_dynamic(frames, category)

    buf.clear()  # 예측 후 버퍼 초기화

    if not pred:
        return jsonify({"status":"fail","error":"예측 실패"}),200

    result = "O" if pred==step else "X"
    return jsonify({
        "status":     "success",
        "predicted":  pred,
        "result":     result,
        "frames_used": MIN_STATIC_FRAMES if category in ("consonant","vowel") else MIN_DYNAMIC_FRAMES,
        "buffer_size":collected
    }),200

# ── 서버 실행 ─────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("\n[💡 라우트 목록]")
    for r in app.url_map.iter_rules():
        print(f"{r.methods} {r.rule}")
    app.run(host="0.0.0.0", port=5000, debug=True)
