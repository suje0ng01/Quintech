import os
from flask import Flask, request, jsonify
import requests
from collections import defaultdict, deque
import cv2
import numpy as np
import datetime

app = Flask(__name__)

# ── 디버깅용: 받은 이미지를 임시 저장할 폴더 ───────────────────────────────
RECV_DIR = "received_images"
os.makedirs(RECV_DIR, exist_ok=True)

MIN_FRAMES = 10
MAX_FRAMES = 50
frame_buffers = defaultdict(lambda: deque(maxlen=MAX_FRAMES))

# (CV 서버, SpringBoot URL 등은 이전 예시 그대로 설정하세요)

@app.route('/check-sign', methods=['POST'])
def check_sign():
    print("🔷 Flask: /check-sign 요청 도착")
    print("    form:", request.form.to_dict())
    print("    files:", list(request.files.keys()))

    user_id = request.form.get("user_id")
    category = request.form.get("category")
    step     = request.form.get("step")
    images   = request.files.getlist("images")

    if not user_id or not category or not step or not images:
        return jsonify({"error": "user_id, category, step, images 모두 필요합니다."}), 400

    # ── 1) 받은 이미지를 임시로 저장해서 확인 ─────────────────────────────────
    saved_filenames = []
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    for idx, img_file in enumerate(images):
        # 예: received_images/user123_20250604_195700_000000_frame0.jpg
        fname = f"{user_id}_{timestamp}_frame{idx}.jpg"
        path = os.path.join(RECV_DIR, fname)
        img_file.save(path)
        saved_filenames.append(fname)

    print(f"    ▶ 받은 이미지 {len(images)}장 저장: {saved_filenames}")

    # ── 2) 기존 로직: 버퍼에 이미지 바이트 추가 ─────────────────────────────────
    buf = frame_buffers[user_id]
    for img_file in images:
        img_bytes = img_file.read()
        buf.append(img_bytes)

    collected = len(buf)
    print(f"    ▶ 버퍼 크기({user_id}): {collected}장 (최소 {MIN_FRAMES}장 필요)")

    if collected < MIN_FRAMES:
        return jsonify({
            "status": "waiting",
            "frames_collected": collected,
            "needed": MIN_FRAMES - collected,
            "received_filenames": saved_filenames
        }), 200

    # ── 3) CV 서버 호출 전 buf 내용을 확인하고 싶으면 여기에 디코딩해서 살펴봐도 됩니다 ─────────
    # 예시: buf에 있는 첫 번째 프레임만 디코딩해서 이미지 크기를 출력
    first_frame_bytes = buf[0]
    nparr = np.frombuffer(first_frame_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    h, w = img.shape[:2]
    print(f"    ▶ 버퍼 첫 번째 프레임 크기: {w}x{h}")

    # ── 4) CV 서버로 buf에 쌓인 모든 프레임 전송 (기존 코드) ─────────────────────────────────
    files = []
    for idx, img_data in enumerate(buf):
        files.append(
            ('images', (f"frame_{idx}.jpg", img_data, 'image/jpeg'))
        )
    cv_data = {"user_id": user_id, "category": category, "step": step}
    # ... (CV 호출 및 SpringBoot 저장 로직) ...

    # 버퍼 비우기
    buf.clear()

    # ── 5) Flutter에 응답할 때 ‘received_filenames’ 를 같이 돌려주면,  
    #        Flutter 쪽에서도 어떤 파일명이 전송되었는지 알 수 있습니다. ─────────────────────────
    return jsonify({
        "status": "success",
        "result": "X",  # (예시)
        "predicted": "",
        "received_filenames": saved_filenames
    }), 200


if __name__ == "__main__":
    print("\n[💡 라우트 목록]")
    for rule in app.url_map.iter_rules():
        print(f"{rule.methods} {rule.rule}")
    app.run(host="0.0.0.0", port=5000, debug=True)
