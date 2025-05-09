import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:quintech/constants/constants.dart';
import 'package:quintech/main.dart';
import '../member/login.dart';
import '../state/login_state.dart'; // 로그인 상태
import 'setting_info.dart';
import 'setting_faq.dart';
import 'setting_member.dart';
import 'package:provider/provider.dart';

//설정 페이지
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

Future<Map<String, dynamic>?> fetchUserDataFromFirestore() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return null;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .get();

  if (doc.exists) {
    return doc.data();
  } else {
    return null;
  }
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final data = await fetchUserDataFromFirestore();
    setState(() {
      userData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Provider.of<LoginState>(context).isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: const Text(
          '설정',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          },
        ),
      ),
      body: ListView(
        children: [
          if (isLoggedIn) ...[
            _buildListTile(
              '로그아웃',
              Icons.logout,
                  () {
                final loginState = Provider.of<LoginState>(context, listen: false);
                loginState.logOut();
              },
            ),
            _buildListTile('회원 정보', Icons.person, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MemberInfoPage()),
              );
            }),
          ] else ...[
            _buildListTile('로그인/회원가입', Icons.login, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            }),
          ],
          const Divider(),
          _buildListTile('공지사항', Icons.announcement, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NoticePage()),  //공지사항 페이지로 이동
            );
          }),
          _buildListTile('FAQ', Icons.help, () {
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FAQPage()), // FAQ 페이지로 이동동
            );
          }),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}