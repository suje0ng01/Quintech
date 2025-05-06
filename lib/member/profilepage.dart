import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../state/login_state.dart';
import '../settings/setting_member.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginState>(context);

    // ✅ 아직 초기화 안 됐으면 로딩
    if (!loginState.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final nickname = loginState.nickname ?? '닉네임 없음';
    final email = loginState.email ?? '이메일 없음';
    final streak = 0; // 나중에 서버에서 받아오게 수정 가능

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: const Text(
          '프로필',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nickname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(email, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black),
                  tooltip: '회원정보 수정',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MemberInfoPage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            ProfileCard(
              icon: Icons.access_time,
              title: '$streak일',
              subtitle: "학습 일수",
            ),
            const SizedBox(height: 15),
            ProfileCard(
              icon: Icons.menu_book,
              title: "현재 학습 단원",
              subtitle: "인사말과 기본 표현 (50%)",
              buttonText: "학습 바로 가기",
              onButtonPressed: () {
                // TODO: 학습 페이지로 이동
              },
            ),
            const SizedBox(height: 15),
            const ProfileCard(
              icon: Icons.sports_esports,
              title: "게임 정답률",
              subtitle: "63.7%\n다른 사용자들의 평균 정답률 : 79%",
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const ProfileCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.black),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            textAlign: TextAlign.center,
          ),
          if (buttonText != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(buttonText!, style: const TextStyle(color: Colors.black)),
            ),
          ]
        ],
      ),
    );
  }
}
