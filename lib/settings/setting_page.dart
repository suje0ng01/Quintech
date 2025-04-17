import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; //LoginState 사용을 위한 provider

import 'package:quintech/main.dart';
import '../member/profilepage.dart';
import '../member/login.dart';
import '../state/login_state.dart'; // 로그인 상태
import 'setting_info.dart';
import 'setting_faq.dart';
import 'setting_member.dart';

import '../data/dummy_member.dart'; //TODO : 더미 회원정보 추후 삭제

//설정 페이지
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Provider.of<LoginState>(context).isLoggedIn;
    final user = DummyUser.example; //더미 회원 정보

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title: const Text(
          '설정',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen())); 
          },
        ),
        actions: [
          IconButton(
            icon: isLoggedIn
                ? CircleAvatar(
                    backgroundImage: NetworkImage(user.profileImageUrl),
                  )
                : const Icon(Icons.account_circle, size: 36, color: Colors.black), // 로그아웃 상태일 때 아이콘 변경
             onPressed: () {  
              final isLoggedIn = Provider.of<LoginState>(context, listen: false).isLoggedIn;

              if (isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              }
            },
          ),
          const SizedBox(width: 10),
        ],
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