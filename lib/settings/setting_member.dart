import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';
import '../state/login_state.dart';
import '../main.dart'; // 홈 or 로그인 페이지로 이동할 때 필요

class MemberInfoPage extends StatefulWidget {
  const MemberInfoPage({super.key});

  @override
  State<MemberInfoPage> createState() => _MemberInfoPageState();
}

class _MemberInfoPageState extends State<MemberInfoPage> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isLoading = true;
  late LoginState _loginState;

  @override
  void initState() {
    super.initState();
    _loginState = Provider.of<LoginState>(context, listen: false);
    _nicknameController.text = _loginState.nickname ?? '';
    _isLoading = false;
  }

  Future<void> _saveNickname() async {
    final newNickname = _nicknameController.text.trim();
    print('현재 토큰: ${_loginState.token}');

    try {
      final response = await http.put(
        Uri.parse('http://223.130.136.121:8082/api/user/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_loginState.token}',
        },
        body: jsonEncode({'nickname': newNickname}),
      );

      print('응답 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        _loginState.updateNickname(newNickname);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('닉네임이 수정되었습니다.')),
        );
        Navigator.pop(context);
      } else {
        final message = response.body.isNotEmpty
            ? (jsonDecode(response.body)['message'] ?? '닉네임 수정 실패')
            : '닉네임 수정 실패';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    }
  }

  Future<void> _withdrawUser() async {
    try {
      final response = await http.delete(
        Uri.parse('http://223.130.136.121:8082/api/user/delete'),
        headers: {
          'Authorization': 'Bearer ${_loginState.token}',
        },
      );

      print('회원 탈퇴 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        await _loginState.logOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원 탈퇴가 완료되었습니다.')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MyApp()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원 탈퇴 실패')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  void _confirmWithdraw() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정말 탈퇴하시겠습니까?'),
        content: const Text('회원 탈퇴 시 모든 정보가 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _withdrawUser();
            },
            child: const Text('탈퇴', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _loginState.name ?? '';
    final email = _loginState.email ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: const Text('회원정보', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('이름', name),
            _buildNicknameField(),
            _buildInfoRow('이메일', email),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveNickname,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appbarcolor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        )
                      ),
                      child: const Text('저장', style: TextStyle(fontSize: 16,color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _confirmWithdraw,
                    child: const Text('회원 탈퇴', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildNicknameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          const SizedBox(width: 80, child: Text('닉네임', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
