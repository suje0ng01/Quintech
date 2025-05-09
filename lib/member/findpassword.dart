import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';
import 'login.dart';

class FindPasswordPage extends StatefulWidget {
  @override
  _FindPasswordPageState createState() => _FindPasswordPageState();
}

class _FindPasswordPageState extends State<FindPasswordPage> {
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  bool _isLoading = false;

  final http.Client _client = http.Client(); // 쿠키 기억용

  // 이메일 전송
  Future<void> sendPasswordReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('이메일을 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(
          'http://223.130.136.121:8082/api/password/forgot?email=${Uri.encodeComponent(email)}');

      final response = await _client.post(uri);

      print('📧 이메일 전송 요청: $uri');
      print('응답 상태: ${response.statusCode}');
      print('응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        _showCodeInputDialog(email);
      } else {
        _showMessage('이메일 전송 실패');
      }
    } catch (e) {
      _showMessage('오류 발생: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 인증번호 확인
  Future<void> _verifyCode(String email) async {
    final code = codeController.text.trim();
    if (code.isEmpty) {
      _showMessage('인증번호를 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(
          'http://223.130.136.121:8082/api/password/verify?email=${Uri.encodeComponent(email)}&code=${Uri.encodeComponent(code)}');

      final response = await _client.post(uri);

      print('🔢 인증 확인 요청: $uri');
      print('응답 상태: ${response.statusCode}');
      print('응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        _showPasswordResetDialog(email);
      } else {
        _showMessage('인증 실패');
      }
    } catch (e) {
      _showMessage('오류 발생: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 비밀번호 재설정
  Future<void> _resetPassword(String email) async {
    final newPassword = newPasswordController.text.trim();
    if (newPassword.length < 6) {
      _showMessage('비밀번호는 6자 이상이어야 합니다.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(
          'http://223.130.136.121:8082/api/password/reset?email=${Uri.encodeComponent(email)}');

      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'newPassword': newPassword,
          'confirmPassword': newPassword,
        }),
      );

      print('🔐 Reset 요청: $uri');
      print('응답 상태: ${response.statusCode}');
      print('응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        _showMessage('비밀번호 변경 실패');
      }
    } catch (e) {
      _showMessage('오류 발생: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 팝업: 인증번호 입력
  void _showCodeInputDialog(String email) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('인증번호 입력'),
        content: TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: '인증번호'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => _verifyCode(email),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  // 팝업: 비밀번호 입력
  void _showPasswordResetDialog(String email) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('새 비밀번호 입력'),
        content: TextField(
          controller: newPasswordController,
          obscureText: true,
          decoration: InputDecoration(hintText: '새 비밀번호'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => _resetPassword(email),
            child: Text('변경'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('비밀번호 변경 완료'),
        content: Text('비밀번호가 성공적으로 변경되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _client.close();
    emailController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: const Text(
          '비밀번호 찾기',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('이메일', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: '이메일 입력',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: _isLoading ? null : sendPasswordReset,
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Text('비밀번호 재설정', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
