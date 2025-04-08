import 'package:flutter/material.dart';

class LearningDetailPage extends StatelessWidget {
  const LearningDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 AppBar
            Container(
              color: Colors.amber[200],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.settings),
                  Text(
                    '자음',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.account_circle),
                ],
              ),
            ),

            // 진행도 표시
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: 2 / 14,
                    color: Colors.blue,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 4),
                  const Text('2/14'),
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
                    const Text(
                      'ㄴ',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 200,
                      height: 200,
                      color: Colors.amber[100],
                      child: const Center(
                        child: Icon(Icons.gesture, size: 100),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 실시간 손 인식 박스
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
                children: const [
                  Icon(Icons.arrow_back, size: 40),
                  Icon(Icons.arrow_forward, size: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
