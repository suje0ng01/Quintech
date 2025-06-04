import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;

import '../constants/constants.dart';

class LearningDetailPage extends StatefulWidget {
  final String category;

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
  String _resultText = '';
  bool _isCapturingFrames = false;

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
    return lowerUrl.contains('.mp4') || lowerUrl.contains('.mov') || lowerUrl.contains('.avi');
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    final frontCamera = _cameras?.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );
    _cameraController = CameraController(
      frontCamera!,
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

  // 3초간 실시간 프레임 연속 캡처 & 서버로 한 번에 50장 전송
  Future<void> _captureFramesAndSend() async {
    if (!_isCameraInitialized || _cameraController == null) return;
    if (_isCapturingFrames) return; // 중복 방지

    setState(() { _resultText = '3초간 실시간 인식 중...'; });
    List<Uint8List> frameList = [];
    _isCapturingFrames = true;
    int maxFrames = 60; // 3초 20fps
    int frameCount = 0;
    final Stopwatch sw = Stopwatch()..start();
    Completer<void> done = Completer();

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
      if (sw.elapsedMilliseconds > 3000 || frameCount >= maxFrames) {
        _isCapturingFrames = false;
        await _cameraController!.stopImageStream();
        sw.stop();
        done.complete();
      }
    });

    await done.future;

    setState(() { _resultText = '${frameList.length}장 캡처, 서버 전송 중...'; });

    await _sendFramesToServerAllAtOnce(frameList);
  }

  // 이미지를 50장 한 번에 서버로 전송 (images[] multipart 필드)
  Future<void> _sendFramesToServerAllAtOnce(List<Uint8List> frames) async {
    final url = 'https://85f0-2001-2d8-2009-3f17-4dd8-85d2-3e65-404b.ngrok-free.app/check-sign';
    final uri = Uri.parse(url.trim());

    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'user_id') ?? 'user123';

    final doc = _letters[currentIndex];
    final String step = doc['question'] ?? '기본';

    var request = http.MultipartRequest('POST', uri);

    // images key로 50장 한 번에 추가
    for (int i = 0; i < frames.length; i++) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'images',  // 복수형 "images"!
          frames[i],
          filename: 'frame_$i.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }
    request.fields['user_id'] = userId;
    request.fields['category'] = widget.category;
    request.fields['step'] = step;

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('서버 응답: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _resultText = data['result'] ?? '인식 성공!';
        });
      } else {
        setState(() {
          _resultText = '서버 오류: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _resultText = '네트워크 오류: $e';
      });
    }
  }

  void _goToPrevious() async {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _isLoading = true;
      });
      await _initializeVideoIfNeeded();
      setState(() {
        _isLoading = false;
        _resultText = '';
      });
    }
  }

  void _goToNext() async {
    if (!_isAnswered[currentIndex]) {
      setState(() {
        correctCount++;
        _isAnswered[currentIndex] = true;
      });
    }
    if (currentIndex == _letters.length - 1) {
      _showCompleteDialog();
      return;
    }
    setState(() {
      currentIndex++;
      _isLoading = true;
      _resultText = '';
    });
    await _initializeVideoIfNeeded();
    setState(() {
      _isLoading = false;
    });
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          '학습 완료',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '해당 챕터를 완료했어요!\n다음 챕터에 도전하세요',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
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
              await _savePracticeResult();
              if (mounted) Navigator.pop(context);
            },
            child: const Text(
              '다른 챕터 보기',
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
                fontSize: 24
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
                    SizedBox(
                      width: 200,
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
            // 3초 연속 촬영(실시간 프레임 전송) 버튼
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isCameraInitialized && !_isCapturingFrames
                      ? _captureFramesAndSend
                      : null,
                  icon: const Icon(Icons.fiber_manual_record, color: Colors.white, size: 24),
                  label: const Text('수어 인식 3초 연속', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
            if (_resultText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_resultText, style: const TextStyle(fontSize: 18, color: Colors.blue)),
              ),
            // 카메라 프리뷰
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 40),
                    onPressed: _goToPrevious,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 40),
                    onPressed: _goToNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
