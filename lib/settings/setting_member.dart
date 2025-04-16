import 'package:flutter/material.dart';
// TODO: Firebase 연동 시 아래 import 주석 해제
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

//회원 정보 페이지
class MemberInfoPage extends StatelessWidget {
  const MemberInfoPage({super.key});

  // 현재는 테스트용 더미 데이터를 사용하고 있음
  // TODO: Firebase 연동 완료 후 false로 바꾸고 아래 _getUserInfo 함수 수정
  final bool useDummyData = true;

  //사용자 정보를 가져오는 함수 (더미 or 실제 Firebase)
  Future<Map<String, dynamic>> _getUserInfo() async {
    if (useDummyData) {
      // 🔹 테스트용 더미 데이터
      return {
        'name': '홍길동',
        'nickname': '길동이',
        'email': 'gildong@example.com',
      };
    } else {
      // TODO: Firebase 연동 시 여기를 사용
      // final user = FirebaseAuth.instance.currentUser;
      // if (user != null) {
      //   final doc = await FirebaseFirestore.instance
      //       .collection('users')
      //       .doc(user.uid)
      //       .get();
      //   return doc.data() ?? {};
      // }
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title: const Text(
          '회원정보',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // 이전 페이지(설정 페이지)로 이동
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 🔹 로딩 중 표시
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            // 🔹 에러 또는 데이터 없음 처리
            return const Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
          }

          final userInfo = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('이름', userInfo['name'] ?? '이름 없음'),
                _buildInfoRow('닉네임', userInfo['nickname'] ?? '닉네임 없음'),
                _buildInfoRow('이메일', userInfo['email'] ?? '이메일 없음'),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // 설정 페이지로 이동
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[600],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: const Text('확인'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  //회원 정보 한 줄을 표시하는 위젯
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}