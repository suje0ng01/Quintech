import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'gamedetailpage.dart'; // 실제 파일명에 맞게 import

class GameGuidePage extends StatelessWidget {
  const GameGuidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F1),
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: const Text(
          '게임 가이드',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGameInfoBox(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.quiz, color: Colors.white),
                label: const Text(
                  '오늘의 퀴즈 풀기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GameDetailPage(), // category 없이 이동
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameInfoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✋ 수어 게임 안내', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),

          Text('📌 게임 방식'),
          SizedBox(height: 4),
          Text('• 화면에 제시된 단어를 손으로 수어로 표현하세요.'),
          Text('• 카메라가 사용자의 손 동작을 인식하여 \n   정답 여부를 판단합니다.'),
          Text('• 정확하게 수어를 표현하면 점수를 얻습니다.'),
          SizedBox(height: 4),

          SizedBox(height: 16),
          Text('💡 팁'),
          SizedBox(height: 4),
          Text('• 손 모양은 정면에서 카메라에 잘 보이게 표현하세요.'),
          Text('• 조명이 밝은 환경에서 인식률이 높아집니다.'),
          Text('• 수어를 정확하게 외운 후 게임을 진행하면 더 좋아요!'),
        ],
      ),
    );
  }

}
