import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amber[300],
        title: Text(
          '프로필',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            // 설정 페이지 이동
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // 홈으로
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 프로필 사진 및 정보
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/profile.jpg'), // 사용자 이미지 경로
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("email@email.com", style: TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),
            SizedBox(height: 30),

            // 학습 일수
            ProfileCard(
              icon: Icons.access_time,
              title: "57일",
              subtitle: "학습 일수",
            ),
            SizedBox(height: 15),

            // 현재 학습 단원
            ProfileCard(
              icon: Icons.menu_book,
              title: "현재 학습 단원",
              subtitle: "인사말과 기본 표현 (50%)",
              buttonText: "학습 바로 가기",
              onButtonPressed: () {
                // 학습 페이지로 이동
              },
            ),
            SizedBox(height: 15),

            // 게임 정답률
            ProfileCard(
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
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            textAlign: TextAlign.center,
          ),
          if (buttonText != null) ...[
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )),
              child: Text(buttonText!, style: TextStyle(color: Colors.black)),
            ),
          ]
        ],
      ),
    );
  }
}
