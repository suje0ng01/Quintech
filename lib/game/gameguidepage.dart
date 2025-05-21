import 'package:flutter/material.dart';
import '../constants/constants.dart';

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
        child: _buildGameInfoBox(),
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
          Text('• 카메라가 사용자의 손 동작을 인식하여 정답 여부를 판단합니다.'),
          Text('• 정확하게 수어를 표현하면 점수를 얻습니다.'),

          SizedBox(height: 16),
          Text('⏱️ 게임 흐름'),
          SizedBox(height: 4),
          Text('1. 단어가 화면에 표시됩니다.'),
          Text('2. 제한 시간 안에 수어를 손으로 표현합니다.'),
          Text('3. 인식이 완료되면 다음 문제로 넘어갑니다.'),

          SizedBox(height: 16),
          Text('🎯 목표'),
          SizedBox(height: 4),
          Text('• 최대한 많은 단어를 정확하게 표현하세요.'),
          Text('• 일정 점수를 넘기면 별 ⭐ 보상을 받을 수 있어요.'),

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
