import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/constants.dart';

class GameDetailPage extends StatefulWidget {
  const GameDetailPage({Key? key}) : super(key: key);

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  int currentIndex = 0;
  int correctCount = 0;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  final TextEditingController _answerController = TextEditingController();
  List<bool> _isAnswered = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _answerController.dispose();
    super.dispose();
  }

  // 비디오인지 체크 (확장자 robust하게)
  bool isVideoUrl(String? url) {
    if (url == null) return false;
    final lowerUrl = url.toLowerCase();
    final path = lowerUrl.split('?').first; // ?파라미터 제거
    return path.endsWith('.mp4') || path.endsWith('.mov');
  }

  // 🔹 Firestore에서 영상 URL 찾기
  Future<String?> fetchSignVideoUrl(String category, String word) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('learningdata')
          .doc('category')
          .collection(category)
          .doc(word)
          .get();
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['imageUrl'] as String?;
      }
    } catch (e) {
      print('파이어베이스 에러: $e');
    }
    return null;
  }

  // 🔹 서버 문제 받아오고 WORD에 영상 URL 붙이기 (병렬처리+데이터 프린트)
  Future<void> fetchQuestions() async {
    final storage = FlutterSecureStorage();
    final jwt = await storage.read(key: 'jwt_token');
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse('http://223.130.136.121:8082/api/game/questions'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> questions = body['questions'];
      print('서버에서 받아온 문제: $questions'); // ★ 어떤 문제 나오는지 콘솔 출력

      List<Map<String, dynamic>> loaded = [];
      List<Future<void>> futures = [];

      for (final q in questions) {
        final m = Map<String, dynamic>.from(q);
        if (m['contentType'] == "WORD") {
          final category = m['topic'] ?? '';
          final word = m['question'] ?? '';
          futures.add(
              fetchSignVideoUrl(category, word).then((url) {
                m['videoUrl'] = url;
              })
          );
        }
        loaded.add(m);
      }
      await Future.wait(futures); // 병렬 처리로 빠르게!

      setState(() {
        _questions = loaded;
        _isAnswered = List<bool>.filled(_questions.length, false);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('문제 불러오기 실패: ${response.body}')),
      );
    }
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

  void _goToNext() {
    if (!_isAnswered[currentIndex]) {
      setState(() {
        correctCount++;
        _isAnswered[currentIndex] = true;
      });
    }

    if (currentIndex == _questions.length - 1) {
      _savePracticeResult();
      _showCompleteDialog();
    } else {
      setState(() {
        currentIndex++;
        _answerController.clear();
      });
    }
  }

  void _checkWordAnswer() {
    final userInput = _answerController.text.trim();
    final correctAnswer = _questions[currentIndex]['question']?.trim();

    if (userInput == correctAnswer) {
      if (!_isAnswered[currentIndex]) {
        setState(() {
          correctCount++;
          _isAnswered[currentIndex] = true;
        });
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('정답입니다!', textAlign: TextAlign.center),
          content: const Text('잘했어요! 다음 문제로 넘어갑니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                if (currentIndex == _questions.length - 1) {
                  _savePracticeResult();
                  _showCompleteDialog();
                } else {
                  setState(() {
                    currentIndex++;
                    _answerController.clear();
                  });
                }
              },
              child: const Text('다음 문제'),
            ),
          ],
        ),
      );
    } else {
      // 틀린 경우
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('틀렸습니다', textAlign: TextAlign.center),
          content: const Text('아쉽지만 다음 문제로 넘어갑니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                if (currentIndex == _questions.length - 1) {
                  _savePracticeResult();
                  _showCompleteDialog();
                } else {
                  setState(() {
                    currentIndex++;
                    _answerController.clear();
                  });
                }
              },
              child: const Text('다음 문제'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _savePracticeResult() async {
    final storage = FlutterSecureStorage();
    final jwt = await storage.read(key: 'jwt_token');
    if (jwt == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 필요!')),
      );
      return;
    }

    final now = DateTime.now().toIso8601String().substring(0, 19);
    final result = {
      "correctCount": correctCount,
      "totalCount": _questions.length,
      "playedAt": now,
    };

    final response = await http.post(
      Uri.parse('http://223.130.136.121:8082/api/game/save'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(result),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게임 결과가 저장되었습니다!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: ${response.body}')),
      );
    }
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          '게임 완료',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '정답: $correctCount / ${_questions.length}',
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
              if (mounted) Navigator.pop(context);
            },
            child: const Text(
              '닫기',
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty || currentIndex >= _questions.length) {
      return const Scaffold(
        body: Center(child: Text('데이터가 없습니다')),
      );
    }

    final Map<String, dynamic> q = _questions[currentIndex];
    final String contentType = q['contentType'] ?? '';
    final String question = q['question'] ?? '';
    final String? videoUrl = q['videoUrl'];

    final double mainBoxSize = MediaQuery.of(context).size.width * 0.8 > 400
        ? 400
        : MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: const Text(
          '오늘의 퀴즈',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 정답수 & 진행률
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: (currentIndex + 1) / _questions.length,
                      color: Colors.blue,
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(height: 4),
                    Text('${currentIndex + 1}/${_questions.length}'),
                    const SizedBox(height: 8),
                    Text('정답 수: $correctCount / ${_questions.length}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (contentType == "VOWEL" || contentType == "CONSONANT") ...[
                // 기존 카메라 문제
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                  elevation: 4,
                  color: Colors.blueGrey[50],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
                    child: Column(
                      children: [
                        const Text(
                          '아래 적힌 단어를 손으로 표현해보세요',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: mainBoxSize,
                            constraints: const BoxConstraints(minHeight: 80),
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blueAccent.shade100, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.07),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              question,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Center(
                  child: Container(
                    width: mainBoxSize,
                    height: mainBoxSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: _isCameraInitialized && _cameraController != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _cameraController!.value.previewSize!.height,
                            height: _cameraController!.value.previewSize!.width,
                            child: CameraPreview(_cameraController!),
                          ),
                        ),
                      ),
                    )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_forward, size: 40),
                        onPressed: _goToNext,
                      ),
                    ],
                  ),
                ),
              ] else if (contentType == "WORD") ...[
                // WORD 문제 (수어영상 or 이미지 + 입력폼)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                  elevation: 4,
                  color: Colors.blueGrey[50],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
                    child: Column(
                      children: [
                        const Text(
                          '수어 영상을 보고 단어를 입력하세요',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: (videoUrl != null && videoUrl.isNotEmpty)
                              ? isVideoUrl(videoUrl)
                              ? AspectRatio(
                            aspectRatio: 16 / 9,
                            child: VideoPlayerWidget(url: videoUrl),
                          )
                              : Image.network(videoUrl, width: mainBoxSize, height: mainBoxSize * 0.7, fit: BoxFit.contain)
                              : const Text('미디어 없음'),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _answerController,
                          decoration: const InputDecoration(
                            labelText: "정답을 입력하세요",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _checkWordAnswer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "정답 확인",
                              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// 비디오 위젯 (video_player 패키지 필요)
class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget({required this.url, Key? key}) : super(key: key);
  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const Center(child: CircularProgressIndicator());
    return VideoPlayer(_controller);
  }
}
