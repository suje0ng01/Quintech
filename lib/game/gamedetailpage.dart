import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import 'package:quintech/game/vowel_Consonant.dart';
import '../constants/constants.dart';
import '../constants/widget.dart';
import 'word_question.dart';

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

  // 정적 모드 캡처 상태
  bool _isCapturingFrames = false;
  bool _hasSentFrames = false;
  static const int STATIC_MAX = 20;

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
    setState(() => _isLoading = true);

    final response = await http.get(
      Uri.parse('http://223.130.136.121:8082/api/game/questions'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final questions = body['questions'] as List<dynamic>;
      setState(() {
        _questions = List<Map<String, dynamic>>.from(questions);
        _isAnswered = List<bool>.filled(_questions.length, false);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('문제 불러오기 실패: ${response.body}')),
      );
    }
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    final front = _cameras!.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );
    _cameraController = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    setState(() => _isCameraInitialized = true);
  }

  Future<Uint8List> _bgra8888ToJpeg(CameraImage image) async {
    final plane = image.planes[0];
    final bytes = plane.bytes;
    final buffer = bytes.buffer;
    final imgBuffer = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: buffer,
      order: img.ChannelOrder.bgra,
    );
    return Uint8List.fromList(img.encodeJpg(imgBuffer, quality: 70));
  }

  /// 자음/모음 퀴즈 인식 로직 (20장 캡처 → 서버 전송)
  Future<void> _recognizeQuiz() async {
    if (!_isCameraInitialized || _cameraController == null || _isCapturingFrames) return;
    setState(() {
      _isCapturingFrames = true;
      _hasSentFrames = false;
    });

    // 1) 20장 캡처
    List<Uint8List> frames = [];
    int captured = 0;
    await _cameraController!.startImageStream((imgData) async {
      if (!_isCapturingFrames) return;
      try {
        frames.add(await _bgra8888ToJpeg(imgData));
      } catch (_) {}
      if (++captured >= STATIC_MAX) {
        _isCapturingFrames = false;
        await _cameraController!.stopImageStream();
      }
    });
    while (_isCapturingFrames) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // 2) 서버 전송
    final uri = Uri.parse('https://5d9c-2001-2d8-6a80-efb7-b99f-498d-41fe-914f.ngrok-free.app/check-quiz');
    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'user_id') ?? '';
    final step = _questions[currentIndex]['question'] ?? '';

    var req = http.MultipartRequest('POST', uri)
      ..fields['user_id'] = userId
      ..fields['category'] = _questions[currentIndex]['contentType'] ?? ''
      ..fields['step'] = step;
    for (int i = 0; i < frames.length; i++) {
      req.files.add(
        http.MultipartFile.fromBytes(
          'images',
          frames[i],
          filename: 'frame_$i.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    try {
      final streamed = await req.send().timeout(const Duration(seconds: 15));
      final resp = await http.Response.fromStream(streamed);
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final bool ok = data['status'] == 'success' && data['result'] == 'O';

      // 3) 결과 다이얼로그
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text(ok ? '정답입니다!' : '틀렸습니다'),
          content: Text(ok ? '잘 하셨습니다.' : '다시 도전해 보세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (ok && !_isAnswered[currentIndex]) {
                  correctCount++;
                  _isAnswered[currentIndex] = true;
                }
                _goToNext();
              },
              child: const Text('다음'),
            ),
          ],
        ),
      );
    } catch (e) {
      // 타임아웃·네트워크 오류 처리 (원하시는 팝업 추가)
    } finally {
      setState(() {
        _hasSentFrames = true;
        _isCapturingFrames = false;
      });
    }
  }

  void _goToNext() {
    if (!_isAnswered[currentIndex]) {
      _isAnswered[currentIndex] = true;
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
      'correctCount': correctCount,
      'totalCount': _questions.length,
      'playedAt': now,
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
    ScaffoldMessenger.of(context).showSnackBar(
      response.statusCode == 200
          ? const SnackBar(content: Text('게임 결과가 저장되었습니다!'))
          : SnackBar(content: Text('저장 실패: ${response.body}')),
    );
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
        content: Text(
          '정답: $correctCount / ${_questions.length}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (mounted) Navigator.pop(context);
            },
            child: const Text(
              '닫기',
              style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
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

    final q = _questions[currentIndex];
    final contentType = q['contentType'] as String? ?? '';

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
              builder: (_) {
                if (contentType == 'WORD') {
                  return WordQuestionView(
                    questionData: q,
                    answerController: _answerController,
                    onAnswerCorrect: () {
                      if (!_isAnswered[currentIndex]) {
                        setState(() {
                          correctCount++;
                          _isAnswered[currentIndex] = true;
                        });
                      }
                      _goToNext();
                    },
                    onAnswerIncorrect: () {
                      if (!_isAnswered[currentIndex]) {
                        setState(() {
                          _isAnswered[currentIndex] = true;
                        });
                      }
                      _goToNext();
                    },
                  );
                } else if (contentType == 'VOWEL' || contentType == 'CONSONANT') {
                  return VowelConsonantView(
                    questionData: q,
                    cameraController: _cameraController,
                    isCameraInitialized: _isCameraInitialized,
                    isRecognizing: _isCapturingFrames,
                    hasRecognized: _hasSentFrames,
                    onRecognize: _recognizeQuiz,
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