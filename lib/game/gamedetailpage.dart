import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    fetchQuestions();
    _initCamera();
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

    print('응답 코드: ${response.statusCode}');
    print('응답 본문: ${response.body}');

    if (response.statusCode == 200) {
      // *** 여기 수정! ***
      final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> questions = body['questions'];
      setState(() {
        _questions = List<Map<String, dynamic>>.from(questions);
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
    setState(() {
      correctCount++;
    });

    if (currentIndex == _questions.length - 1) {
      _savePracticeResult();
      _showCompleteDialog();
    } else {
      setState(() {
        currentIndex++;
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
      "correctCount": correctCount,
      "totalCount": _questions.length,
      "playedAt": now,
    };

    // 👇 여기서부터 로그!
    print('==== 서버에 보낼 데이터 ====');
    print(jsonEncode(result));
    print('==== 요청 URL ====');
    print('http://223.130.136.121:8082/api/game/save');
    print('=========================');

    final response = await http.post(
      Uri.parse('http://223.130.136.121:8082/api/game/save'),
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

    final String question = _questions[currentIndex]['question'] ?? '';

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double mainBoxSize = (constraints.maxWidth * 0.8).clamp(280.0, 400.0);
          return SingleChildScrollView(
            child: Column(
              children: [
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
                    ],
                  ),
                ),
                const SizedBox(height: 18),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 40),
                        onPressed: () {
                          setState(() {
                            if (currentIndex > 0) currentIndex--;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward, size: 40),
                        onPressed: _goToNext,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('정답 수: $correctCount / ${_questions.length}'),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
