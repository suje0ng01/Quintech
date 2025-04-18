import 'package:flutter/material.dart';
import '../data/dummy_member.dart'; //TODO : 예시 사용자 정보 >> 추후 삭제
// TODO: Firebase 연동 시 아래 import 주석 해제
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

//회원 정보 페이지
class MemberInfoPage extends StatelessWidget {
  const MemberInfoPage({super.key});

  // 현재는 테스트용 더미 데이터를 사용하고 있음
  // TODO: Firebase 연동 완료 후 false로 바꾸고 아래 _getUserInfo 함수 수정
  final bool useDummyData = true;

  // 더미 or Firebase 에서 사용자 정보 가져오기
  Future<DummyUser> _getUserInfo() async {
    if (useDummyData) {
      // 🔹 더미 데이터 반환
      return DummyUser.example;
    } else {
      // 🔹 Firebase 연동 예시
      // final user = FirebaseAuth.instance.currentUser;
      // if (user != null) {
      //   final doc = await FirebaseFirestore.instance
      //       .collection('users')
      //       .doc(user.uid)
      //       .get();
      //   final data = doc.data();
      //   if (data != null) {
      //     // API 명세 필드명에 맞춰서 fromApi 로 매핑
      //     return DummyMember.fromApi(data);
      //   }
      // }
      // 회원 정보 없으면 예외 처리
      throw Exception('회원 정보가 없습니다.');
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DummyUser>(
        future: _getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final msg = snapshot.error.toString();
            if (msg.contains('회원 정보가 없습니다')) {
              return const Center(child: Text('회원 정보가 없습니다.'));
            }
            return const Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
          }
          final user = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('이름', user.name),
                _buildInfoRow('닉네임', user.nickname),
                _buildInfoRow('이메일', user.email),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[600],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
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