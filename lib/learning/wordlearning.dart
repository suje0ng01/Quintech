import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  int correctCount = 0; // →버튼 누를 때 카운트
  int totalCount = 0;

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
    );
    await _cameraController!.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
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
      });
    }
  }

  void _goToNext() async {
    // 마지막 단어면 팝업
    if (currentIndex == _letters.length - 1) {
      setState(() {
        correctCount++; // 마지막 단어에서도 +1
      });
      _showCompleteDialog();
      return;
    }

    // 중간 단계
    setState(() {
      currentIndex++;
      correctCount++; // 다음 문제 이동할 때 +1
      _isLoading = true;
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
              if (mounted) Navigator.pop(context); // 이 페이지 닫기
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
    return "WORD"; // 나머지는 다 단어학습
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
      "contentType": _getContentType(widget.category), // 동적으로!
      "topic": widget.category,
      "correctCount": correctCount,
      "totalCount": totalCount,
      "finishedAt": now,
    };

    // 👇 실제로 전송하는 데이터 콘솔에 출력
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

    // 👇 서버 응답도 콘솔에 출력
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
                  // ⭐ 정답 수를 여기로!
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
            // 카메라 박스
            Container(
              width: 200,
              height: 200,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _isCameraInitialized && _cameraController != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: _cameraController!.value.aspectRatio,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _cameraController!.value.previewSize!.height,
                          height: _cameraController!.value.previewSize!.width,
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                    ),
                  ),
                ),
              )
                  : const Center(child: CircularProgressIndicator()),
            ),
            // 이동 버튼
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
