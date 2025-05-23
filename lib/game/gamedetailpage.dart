import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';

class GameDetailPage extends StatefulWidget {
  final String category;

  const GameDetailPage({Key? key, required this.category}) : super(key: key);

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  List<DocumentSnapshot> _questions = [];
  bool _isLoading = true;
  int currentIndex = 0;

  int correctCount = 0;
  int totalCount = 0;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('gamedata') // 'learningdata' → 'gamedata'로 변경 (원하는 컬렉션명으로!)
        .doc('category')
        .collection(widget.category)
        .orderBy('question')
        .get();

    setState(() {
      _questions = snapshot.docs;
      totalCount = snapshot.docs.length;
      _isLoading = false;
    });
  }

  void _goToPrevious() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  void _goToNext() {
    if (currentIndex == _questions.length - 1) {
      setState(() {
        correctCount++;
      });
      _showCompleteDialog();
      return;
    }
    setState(() {
      currentIndex++;
      correctCount++;
    });
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
            const Text(
              '게임이 끝났어요!\n수고하셨습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              '점수: $correctCount / $totalCount',
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
            onPressed: () {
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

    final doc = _questions[currentIndex];
    final String question = doc['question'] ?? '';

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
                    value: (currentIndex + 1) / _questions.length,
                    color: Colors.blue,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 4),
                  Text('${currentIndex + 1}/${_questions.length}'),
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
                    const Text('문제를 풀어보세요', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(
                      question,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    // 이미지, 영상 등은 없음!
                  ],
                ),
              ),
            ),
            // 카메라 박스가 필요 없다면 아래 삭제
            // (만약 게임에서도 카메라 필요하면 여기에 추가)
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
            const SizedBox(height: 16),
            Text('점수: $correctCount / $totalCount'),
          ],
        ),
      ),
    );
  }
}
