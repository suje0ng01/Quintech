// learning_detail_page.dart

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;

import '../constants/constants.dart';

// — 한글→영어 매핑 테이블 (동적 카테고리에서만 영어 키 사용) —
const Map<String, String> korToEngCategory = {
  "동물":   "animal",
  "개념":   "concept",
  "문화":   "culture",
  "경제생활":   "economic",
  "기타":   "etc",
  "삶":   "human",
  "인간":   "human",
  "사회생활":   "social",
  // 정적(자음/모음)은 한글 그대로 사용
  "자음":   "자음",
  "모음":   "모음",
};

class LearningDetailPage extends StatefulWidget {
  final String category; // 예: "자음", "모음", "동물", "개념" 등

  const LearningDetailPage({Key? key, required this.category}) : super(key: key);

  @override
  State<LearningDetailPage> createState() => _LearningDetailPageState();
}

class _LearningDetailPageState extends State<LearningDetailPage> {
  List<DocumentSnapshot> _letters = [];
  bool _isLoading = true;
  int currentIndex = 0;

  VideoPlayerController? _videoController;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  int correctCount = 0;
  int totalCount = 0;
  List<bool> _isAnswered = [];

  // “수어 인식” 버튼 상태 관리용
  bool _isCapturingFrames = false;
  bool _hasSentFrames = false;
  int _countdown = 0; // (카운트다운은 동적 모드 전용)

  static const int MIN_FRAMES = 10; // 동적 처리 시 최소 필요 프레임 수
  static const int MAX_FRAMES = 200; // 동적 모드에서 10초간 최대 수집
  static const int STATIC_MAX = 20; // 정적 모드(자음/모음)에서 수집할 이미지 수를 20으로 변경

  @override
  void initState() {
    super.initState();
    fetchLetters();
    _initCamera();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> fetchLetters() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('learningdata')
        .doc('category')
        .collection(widget.category)
        .orderBy('question')
        .get();

    setState(() {
      _letters = snapshot.docs;
      totalCount = snapshot.docs.length;
      _isLoading = false;
      _isAnswered = List.filled(snapshot.docs.length, false);
      _hasSentFrames = false;
      _countdown = 0;
    });

    if (_letters.isNotEmpty) {
      await _initializeVideoIfNeeded();
    }
  }

  Future<void> _initializeVideoIfNeeded() async {
    final doc = _letters[currentIndex];
    final String url = doc['imageUrl'] ?? '';

    if (_isVideo(url)) {
      _videoController?.dispose();
      _videoController = VideoPlayerController.network(url);
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      await _videoController!.play();
      setState(() {});
    } else {
      _videoController?.dispose();
      _videoController = null;
      setState(() {});
    }
  }

  bool _isVideo(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.mp4') ||
        lowerUrl.contains('.mov') ||
        lowerUrl.contains('.avi');
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );
    await _cameraController!.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<Uint8List> _bgra8888ToJpeg(CameraImage image) async {
    final plane = image.planes[0];
    final bytes = plane.bytes;
    final width = image.width;
    final height = image.height;

    final imageBuffer = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
    return Uint8List.fromList(img.encodeJpg(imageBuffer, quality: 70));
  }

  /// ── 1) 메인 프레임 캡처 함수 ─────────────────────────────────────────────
  ///
  /// widget.category가 "자음" or "모음"이면 → _captureStaticFrames()
  /// 그렇지 않으면 → _captureDynamicFrames()
  ///
  Future<void> _captureFramesAndSend() async {
    if (!_isCameraInitialized || _cameraController == null) return;
    if (_isCapturingFrames) return; // 중복 방지

    final bool isStaticMode = (widget.category == "자음" || widget.category == "모음");
    if (isStaticMode) {
      await _captureStaticFrames();
    } else {
      await _captureDynamicFrames();
    }
  }

  /// ── 2) 정적 모드: 이미지 20장만 캡처해서 서버로 전송 ────────────────────────
  Future<void> _captureStaticFrames() async {
    setState(() {
      _isCapturingFrames = true;
      _hasSentFrames = false;
    });

    List<Uint8List> frameList = [];
    int captured = 0;

    await _cameraController!.startImageStream((CameraImage image) async {
      if (!_isCapturingFrames) return;

      try {
        if (image.format.group == ImageFormatGroup.bgra8888) {
          final jpgBytes = await _bgra8888ToJpeg(image);
          frameList.add(jpgBytes);
          captured++;
        }
      } catch (e) {
        print("정적 프레임 변환 실패: $e");
      }

      // 20장 모이면 스트림 종료
      if (captured >= STATIC_MAX) {
        _isCapturingFrames = false;
        await _cameraController!.stopImageStream();
      }
    });

    // 스트림이 완전히 멈출 때까지 대기
    while (_isCapturingFrames) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    setState(() {
      _hasSentFrames = false;
    });

    // 서버 전송 호출
    await _sendFramesToServerAllAtOnce(frameList);
  }

  /// ── 3) 동적 모드: 3초 동안 프레임 캡처 후 서버 전송 ────────────────────────
  Future<void> _captureDynamicFrames() async {
    setState(() {
      _isCapturingFrames = true;
      _hasSentFrames = false;
      _countdown = 10; // 10초 카운트다운 시작
    });

    List<Uint8List> frameList = [];
    int frameCount = 0;
    final sw = Stopwatch()..start();
    final done = Completer<void>();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        setState(() => _countdown = 0);
      }
    });

    _cameraController!.startImageStream((CameraImage image) async {
      if (!_isCapturingFrames) return;

      try {
        if (image.format.group == ImageFormatGroup.bgra8888) {
          final jpgBytes = await _bgra8888ToJpeg(image);
          frameList.add(jpgBytes);
        }
      } catch (e) {
        print("동적 프레임 변환 실패: $e");
      }

      frameCount++;
      if (sw.elapsedMilliseconds > 10000 || frameCount >= MAX_FRAMES) {
        _isCapturingFrames = false;
        await _cameraController!.stopImageStream();
        sw.stop();
        done.complete();
      }
    });

    await done.future;

    setState(() {
      _countdown = 0;
      _isCapturingFrames = true;
    });

    await _sendFramesToServerAllAtOnce(frameList);
  }

  /// ── 4) 서버로 이미지 전송 (정적/동적 공통) ──────────────────────────────
  Future<void> _sendFramesToServerAllAtOnce(List<Uint8List> frames) async {
    final bool isStaticMode = (widget.category == "자음" || widget.category == "모음");
    final String url = 'https://dd12-2001-2d8-698a-8365-d1b7-a990-2b6b-9c90.ngrok-free.app/check-sign';

    final uri = Uri.parse(url);
    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'user_id') ?? 'user123';
    final doc = _letters[currentIndex];
    final String step = doc['question'] ?? '기본';

    final String engCategory = korToEngCategory[widget.category] ?? widget.category;
    var request = http.MultipartRequest('POST', uri);

    if (isStaticMode) {
      // ── 정적 모드: 캡처한 20장 모두를 전송 ──
      for (int i = 0; i < frames.length; i++) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'images',
            frames[i],
            filename: 'frame_$i.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }
      request.fields['user_id']  = userId;
      request.fields['category'] = widget.category; // "자음" or "모음"
      request.fields['step']     = step;
    } else {
      // ── 동적 모드: 모든 프레임 전송 ──
      for (int i = 0; i < frames.length; i++) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'images',
            frames[i],
            filename: 'frame_$i.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }
      request.fields['user_id']  = userId;
      request.fields['category'] = engCategory; // "animal", "concept", ...
      request.fields['step']     = step;
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 로그 콘솔에서만 확인 가능하도록 print 사용
      print('🚀 서버 응답 (statusCode: ${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String status = data['status'] ?? '';

        if (status == 'success') {
          final String result = data['result'] ?? '';
          _handleResult(result);
        } else if (status == 'waiting') {
          final int collected = data['frames_collected'] ?? 0;
          final int needed = data['needed'] ?? MIN_FRAMES;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("현재 $collected장 수집, $needed장 더 필요")),
          );
          setState(() {
            _hasSentFrames = false;
            _isCapturingFrames = false;
          });
        } else {
          final String error = data['error'] ?? '알 수 없는 오류';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("예측 실패: $error")),
          );
          setState(() {
            _hasSentFrames = false;
            _isCapturingFrames = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: ${response.body}')),
        );
        setState(() {
          _hasSentFrames = false;
          _isCapturingFrames = false;
        });
      }
    } catch (e) {
      print('네트워크 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
      setState(() {
        _hasSentFrames = false;
        _isCapturingFrames = false;
      });
    }
  }

  /// ── 5) 서버 응답 처리: O/X 다이얼로그 ───────────────────────────────────
  void _handleResult(String result) {
    final bool isCorrect = result == 'O';
    if (isCorrect) correctCount++;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isCorrect ? '정답입니다!' : '틀렸습니다'),
        content: Text(isCorrect
            ? '잘 하셨습니다.'
            : '아쉽지만 정답은 다음 기회에 도전해 보세요.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _goToNext(); // 다음 문제로 이동
            },
            child: const Text('다음'),
          ),
        ],
      ),
    );
    setState(() {
      _hasSentFrames = true;
      _isCapturingFrames = false;
      _countdown = 0;
    });
  }

  void _goToPrevious() async {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _isLoading = true;
        _hasSentFrames = false;
        _countdown = 0;
      });
      await _initializeVideoIfNeeded();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToNext() async {
    if (!_isAnswered[currentIndex]) {
      _isAnswered[currentIndex] = true;
    }
    if (currentIndex == _letters.length - 1) {
      double ratio = totalCount > 0 ? (correctCount / totalCount) : 0.0;
      if (ratio >= 0.8) {
        _showCompleteDialog(passed: true);
      } else {
        _showCompleteDialog(passed: false);
      }
      return;
    }
    setState(() {
      currentIndex++;
      _isLoading = true;
      _hasSentFrames = false;
      _countdown = 0;
    });
    await _initializeVideoIfNeeded();
    setState(() {
      _isLoading = false;
    });
  }

  void _showCompleteDialog({required bool passed}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          passed ? '학습 완료 🎉' : '학습 미달',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (passed) ...[
              const Text(
                '해당 챕터를 80% 이상 맞히셨어요!\n축하드립니다!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ] else ...[
              const Text(
                '아쉽게도 정답률이 80% 미만입니다.\n다시 학습해 주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              '정답: $correctCount / $totalCount',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              Navigator.pop(context);
            },
            child: const Text(
              '확인',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getContentType(String category) {
    if (category == "모음") return "VOWEL";
    if (category == "자음") return "CONSONANT";
    return "WORD";
  }

  Future<void> _savePracticeResult() async {
    final storage = FlutterSecureStorage();
    final jwt = await storage.read(key: 'jwt_token');
    if (jwt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 필요!')),
      );
      return;
    }

    final now = DateTime.now().toIso8601String().substring(0, 19);
    final result = {
      "contentType": _getContentType(widget.category),
      "topic": widget.category,
      "correctCount": correctCount,
      "totalCount": totalCount,
      "finishedAt": now,
    };

    final response = await http.post(
      Uri.parse('http://223.130.136.121:8082/api/practice/save'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(result),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('학습 결과가 저장되었습니다!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_letters.isEmpty || currentIndex >= _letters.length) {
      return const Scaffold(
        body: Center(child: Text('데이터가 없습니다')),
      );
    }

    final doc = _letters[currentIndex];
    final String letter = doc['question'] ?? '';
    final String imageUrl = doc['imageUrl'] ?? '';

    // “진행률” 바 너비 계산
    final double boxWidth = MediaQuery.of(context).size.width - 32;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: AppColors.appbarcolor,
          centerTitle: true,
          title: Text(
            widget.category,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Column(
        children: [
          // ── 진행률 표시 ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (currentIndex + 1) / _letters.length,
                  color: Colors.blue,
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(height: 4),
                Text('${currentIndex + 1}/${_letters.length}'),
                const SizedBox(height: 8),
                Text('정답 수: $correctCount / $totalCount'),
              ],
            ),
          ),

          // ── 카드: 따라하기 영상/이미지 ──
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('따라 해보세요', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    letter,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: boxWidth,
                    height: 180,
                    child: _isVideo(imageUrl)
                        ? (_videoController != null && _videoController!.value.isInitialized
                        ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                        : const Center(child: CircularProgressIndicator()))
                        : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: imageUrl.isNotEmpty
                            ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.contain,
                        )
                            : null,
                      ),
                      child: imageUrl.isEmpty
                          ? const Center(child: Text('이미지 없음'))
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 수어 인식 버튼 ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: SizedBox(
              width: 180,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: (!_isCapturingFrames && !_hasSentFrames)
                    ? _captureFramesAndSend
                    : null,
                icon: const Icon(Icons.fiber_manual_record, color: Colors.white, size: 20),
                label: _countdown > 0
                    ? Text(
                  '$_countdown',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
                    : _isCapturingFrames
                    ? const Text(
                  '인식 중...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
                    : _hasSentFrames
                    ? const Text(
                  '완료',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
                    : const Text(
                  '수어 인식 시작',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appbarcolor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),

          // ── 카메라 프리뷰 + 양옆 버튼 ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 왼쪽 버튼: 이전
                IconButton(
                  icon: const Icon(Icons.arrow_left, size: 32),
                  onPressed: currentIndex > 0 ? _goToPrevious : null,
                ),

                // 카메라 프리뷰 (크기 및 위치는 변경 없음)
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _isCameraInitialized && _cameraController != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AspectRatio(
                      aspectRatio: _cameraController!.value.aspectRatio,
                      child: CameraPreview(_cameraController!),
                    ),
                  )
                      : const Center(child: CircularProgressIndicator()),
                ),

                // 오른쪽 버튼: 다음
                IconButton(
                  icon: const Icon(Icons.arrow_right, size: 32),
                  onPressed: currentIndex < _letters.length - 1 ? _goToNext : null,
                ),
              ],
            ),
          ),

          // ── 여유 공간 ──
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}