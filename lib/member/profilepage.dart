import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/constants.dart';
import '../state/login_state.dart';
import '../settings/setting_member.dart';
import '../learning/learningpage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = FlutterSecureStorage();
  String? latestTopic;
  String? latestType;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final loginState = Provider.of<LoginState>(context, listen: false);
      loginState.fetchStreak();

      try {
        await fetchLearningProgress();
      } catch (e) {
        print('⚠️ fetchLearningProgress 에러: $e');
      }
    });
  }

  Future<void> fetchLearningProgress() async {
    final token = await storage.read(key: 'jwt_token');  // 언더바!
    print('🔑 JWT Token: $token');

    if (token == null) {
      print('❌ JWT 토큰 없음');
      return;
    }

    final response = await http.get(
      Uri.parse('http://223.130.136.121:8082/api/practice/progress'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('📡 응답 상태 코드: ${response.statusCode}');
    print('📦 응답 본문: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        latestType = data['latestContentType'];
        latestTopic = data['latestTopic'];
      });
    } else {
      print('❌ API 호출 실패: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginState>(context);

    if (!loginState.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final nickname = loginState.nickname ?? '닉네임 없음';
    final email = loginState.email ?? '이메일 없음';
    final streak = loginState.streak;
    final currentUnit = latestTopic != null
        ? '$latestTopic'
        : '최근 학습한 단원이 없습니다';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: const Text('프로필',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
                      Text(nickname,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(email,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black),
                  tooltip: '회원정보 수정',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MemberInfoPage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            ProfileCard(
              icon: Icons.access_time,
              title: '${streak != null ? '$streak일' : '로딩 중...'}',
              subtitle: "학습 일수",
            ),
            const SizedBox(height: 15),
            ProfileCard(
              icon: Icons.menu_book,
              title: "현재 학습 단원",
              subtitle: currentUnit,
              buttonText: "학습 바로 가기",
              onButtonPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LearningPage()));
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
            style:
            const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
              child: Text(buttonText!,
                  style: const TextStyle(color: Colors.black)),
            ),
          ]
        ],
      ),
    );
  }
}
