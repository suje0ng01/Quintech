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
  "주생활":   "life",
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

  // “수어 인식 3초 연속” 버튼 상태 관리용
  bool _isCapturingFrames = false;
  bool _hasSentFrames = false;
  int _countdown = 0; // 카운트다운 타이머 값

  static const int MIN_FRAMES = 10; // 동적 처리 시 최소 필요 프레임 수
  static const int MAX_FRAMES = 60; // 3초간 대략 수집할 최대 프레임 수

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

  /// 3초간 실시간으로 프레임 캡처 → 한 번에 서버 전송
  Future<void> _captureFramesAndSend() async {
    if (!_isCameraInitialized || _cameraController == null) return;
    if (_isCapturingFrames) return; // 이미 인식 중이면 중복 방지

    setState(() {
      _isCapturingFrames = true;
      _hasSentFrames = false;
      _countdown = 3; // 3초 카운트다운 시작
    });

    List<Uint8List> frameList = [];
    int frameCount = 0;
    final sw = Stopwatch()..start();
    final done = Completer<void>();

    // 1초 간격으로 카운트다운
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        setState(() => _countdown = 0);
      }
    });

    // 이미지 스트림 시작
    _cameraController!.startImageStream((CameraImage image) async {
      if (!_isCapturingFrames) return;

      try {
        if (image.format.group == ImageFormatGroup.bgra8888) {
          final jpgBytes = await _bgra8888ToJpeg(image);
          frameList.add(jpgBytes);
        }
      } catch (e) {
        print("프레임 변환 실패: $e");
      }

      frameCount++;
      if (sw.elapsedMilliseconds > 3000 || frameCount >= MAX_FRAMES) {
        // 3초가 지났거나 최대 프레임 수에 도달하면 스트림 중지
        _isCapturingFrames = false;
        await _cameraController!.stopImageStream();
        sw.stop();
        done.complete();
      }
    });

    // 3초가 끝나기를 기다림
    await done.future;
    print("보낼 프레임 개수: ${frameList.length}");

    // “인식 중...” 상태로 보여주기
    setState(() {
      _countdown = 0;
      _isCapturingFrames = true; // 서버 응답 대기 중에도 true로 유지
    });

    // 서버로 전송
    await _sendFramesToServerAllAtOnce(frameList);
  }

  Future<void> _sendFramesToServerAllAtOnce(List<Uint8List> frames) async {
    // 정적(자음/모음)인지 여부
    final bool isStatic = (widget.category == "자음" || widget.category == "모음");
    final String url = 'https://ac47-2001-2d8-6a85-a461-8040-fa76-f29a-7844.ngrok-free.app/check-sign';

    final uri = Uri.parse(url);
    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'user_id') ?? 'user123';
    final doc = _letters[currentIndex];
    final String step = doc['question'] ?? '기본';

    // 한글 카테고리명을 영어 키로 변환 (동적 카테고리만)
    final String engCategory = korToEngCategory[widget.category] ?? widget.category;

    var request = http.MultipartRequest('POST', uri);

    if (isStatic) {
      // ── 정적 모드: 'image' 키로 첫 프레임만 전송 ──
      if (frames.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image', // 반드시 'image' 키 사용
            frames.first,
            filename: 'frame_static.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }
      request.fields['user_id']  = userId;
      request.fields['category'] = widget.category; // "자음" or "모음"
      request.fields['step']     = step;
    } else {
      // ── 동적 모드: 'images' 키로 모든 프레임 전송 ──
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
      print('🚀 서버 응답: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String status = data['status'] ?? '';

        if (status == 'success') {
          final String result = data['result'] ?? '';
          _handleResult(result);
        } else if (status == 'waiting') {
          // 동적 모드에서 MIN_FRAMES 미만일 때
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
          // 실패 케이스
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
      setState(() {
        _hasSentFrames = false;
        _isCapturingFrames = false;
      });
    }
  }

  /// 서버 응답에 따른 처리: O/X
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
              _goToNext(); // 자동으로 다음 문제로 이동
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
    // 현재 문제에 대한 답안 채점 완료 표시
    if (!_isAnswered[currentIndex]) {
      _isAnswered[currentIndex] = true;
    }
    // 마지막 문제인지 확인
    if (currentIndex == _letters.length - 1) {
      // 전체 정답률 계산
      double ratio = totalCount > 0 ? (correctCount / totalCount) : 0.0;
      // 80% 이상 통과 여부에 따라 다이얼로그 분기
      if (ratio >= 0.8) {
        _showCompleteDialog(passed: true);
      } else {
        _showCompleteDialog(passed: false);
      }
      return;
    }
    // 마지막 문제가 아니라면 다음으로 이동
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

  /// passed == true/false 둘 다 “확인” 버튼만 나오게 수정
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
              // “확인” 버튼을 누르면 다이얼로그 닫고, 이 페이지도 함께 닫아서
              // 이전 화면으로 돌아가도록 함
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

  /// 학습 결과 서버에 저장
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

    print('==== 서버에 보낼 데이터 ====');
    print(jsonEncode(result));
    print('=========================');

    final response = await http.post(
      Uri.parse('http://223.130.136.121:8082/api/practice/save'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(result),
    );

    print('==== 서버 응답 ====');
    print('statusCode: ${response.statusCode}');
    print('body: ${response.body}');
    print('=================');

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

    // “진행률” 바가 들어있는 Padding: horizontal 16이므로, 전체 화면 너비 - 32가 진행률 바의 너비
    final double boxWidth = MediaQuery.of(context).size.width - 32;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: AppColors.appbarcolor,
          title: Text(
            widget.category,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
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
              margin: const EdgeInsets.all(16),
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
                    // 진행률 바와 동일한 너비로 설정
                    SizedBox(
                      width: boxWidth,
                      height: 200,
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

            // ── 수어 인식 3초 연속 버튼 ──
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: (!_isCapturingFrames && !_hasSentFrames)
                      ? _captureFramesAndSend
                      : null,
                  icon: const Icon(Icons.fiber_manual_record, color: Colors.white, size: 24),
                  label: _countdown > 0
                      ? Text(
                    '$_countdown',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                      : _isCapturingFrames
                      ? const Text(
                    '인식 중...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                      : _hasSentFrames
                      ? const Text(
                    '완료',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                      : const Text(
                    '수어 인식 3초 연속',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),

            // ── 카메라 프리뷰 ──
            Container(
              width: 200,
              height: 200,
              margin: const EdgeInsets.symmetric(vertical: 10),
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

            // 이전/다음 버튼 제거 → 자동으로 처리하기 위해 UI에서 삭제
          ],
        ),
      ),
    );
  }
}
