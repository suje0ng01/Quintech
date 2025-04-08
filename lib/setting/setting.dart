import 'package:flutter/material.dart';

import '../constants/constants.dart';


class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: Text(
          '설정',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        children: [
          _buildSettingsItem('로그인 / 회원 가입', onTap: () {}),
          Divider(),
          _buildSettingsItem('공지사항', onTap: () {}),
          _buildSettingsItem('FAQ', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
