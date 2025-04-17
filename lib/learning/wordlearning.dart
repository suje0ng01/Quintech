import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';

class LearningDetailPage extends StatefulWidget {
  final String category; // ✅ 카테고리 받기

  const LearningDetailPage({Key? key, required this.category}) : super(key: key);

  @override
  State<LearningDetailPage> createState() => _LearningDetailPageState();
}

class _LearningDetailPageState extends State<LearningDetailPage> {
  List<DocumentSnapshot> _letters = [];
  bool _isLoading = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchLetters();
  }

  Future<void> fetchLetters() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('learningdata')     // 최상위 컬렉션
        .doc('category')                // category 문서
        .collection(widget.category)    // 넘겨받은 카테고리
        .orderBy('name')
        .get();

    setState(() {
      _letters = snapshot.docs;
      _isLoading = false;
    });
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
            // 진행도 표시
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
                ],
              ),
            ),

            // 수어 학습 카드
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      '따라 해보세요',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
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
                  ],
                ),
              ),
            ),

            // 실시간 손 인식 박스 (임시 박스)
            Container(
              width: 200,
              height: 200,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.grey[300],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      '사용자의 손 모양을\n실시간으로 인식',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            // 페이지 이동 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 40),
                    onPressed: currentIndex > 0
                        ? () {
                      setState(() {
                        currentIndex--;
                      });
                    }
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 40),
                    onPressed: currentIndex < _letters.length - 1
                        ? () {
                      setState(() {
                        currentIndex++;
                      });
                    }
                        : null,
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
