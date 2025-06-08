import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quintech/game/vowel_Consonant.dart';
import 'package:quintech/game/word_question.dart';

import '../constants/constants.dart';
import '../constants/widget.dart'; // AppColors 사용 (기존대로)

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

  bool _isWordVideoLoading = false;

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

      setState(() {
        _questions = List<Map<String, dynamic>>.from(questions);
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
        _isWordVideoLoading = false;
      });
    }
  }

  void _savePracticeResult() async {
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
  // GameDetailPage 내부에 추가
  void _handleCorrect() {
    if (!_isAnswered[currentIndex]) {
      setState(() {
        correctCount++;
        _isAnswered[currentIndex] = true;
      });
    }
    _goToNextQuestion();
  }

  void _handleIncorrect() {
    if (!_isAnswered[currentIndex]) {
      setState(() {
        _isAnswered[currentIndex] = true;
      });
    }
    _goToNextQuestion();
  }

  void _goToNextQuestion() {
    if (currentIndex == _questions.length - 1) {
      _savePracticeResult();
      _showCompleteDialog();
    } else {
      setState(() {
        currentIndex++;
        _answerController.clear();
        _isWordVideoLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("게임 문제 생성중...", style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
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
    String? videoUrl = q['videoUrl'];
    final String? category = q['topic'];

    if (contentType == "WORD" && (videoUrl == null || videoUrl.isEmpty)) {
      if (!_isWordVideoLoading) {
        _isWordVideoLoading = true;
        fetchSignVideoUrl(category ?? '', question).then((url) {
          if (url != null && mounted) {
            setState(() {
              _questions[currentIndex]['videoUrl'] = url;
              _isWordVideoLoading = false;
            });
          } else {
            setState(() {
              _isWordVideoLoading = false;
            });
          }
        });
      }

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.appbarcolor,
          title: const Text('오늘의 퀴즈', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 18),
              Text("수어 영상 불러오는 중...", style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          CorrectCounter(
            currentIndex: currentIndex,
            questions: _questions,
            correctCount: correctCount,
          ),
          const Divider(height: 1),
          Expanded(
            child: Builder(
              builder: (context) {
                if (contentType == 'WORD') {
                  return WordQuestionView(
                    questionData: q,
                    answerController: _answerController,
                    onAnswerCorrect: _handleCorrect,   // 정답일 때만 correctCount 증가
                    onAnswerIncorrect: _handleIncorrect, // 오답일 땐 증가 없이 넘어감
                  );
                } else if (contentType == 'VOWEL' || contentType == 'CONSONANT') {
                  return VowelConsonantView(
                    questionData: q,
                    cameraController: _cameraController,
                    isCameraInitialized: _isCameraInitialized,
                    onNext: _goToNext,
                  );
                } else {
                  return const Center(child: Text('알 수 없는 문제 유형입니다.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
