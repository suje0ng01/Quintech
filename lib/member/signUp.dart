import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _emailChecked = false;

  String? _emailCheckMessage;
  Color _emailCheckColor = Colors.grey;

  void _signUp() async {
    if (_isLoading) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('모든 항목을 입력해주세요.');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('비밀번호가 일치하지 않습니다.');
      return;
    }

    if (!_emailChecked || _emailCheckColor == Colors.red) {
      _showMessage('중복된 이메일입니다. 다른 이메일로 가입해주세요');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://223.130.136.121:8082/api/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'nickname': name,
        }),
      );

      print('응답 상태: ${response.statusCode}');
      print('응답 내용: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        String errorMessage = '회원가입 실패';
        try {
          if (response.body.isNotEmpty) {
            final resBody = jsonDecode(response.body);
            errorMessage = resBody['message'] ?? errorMessage;
          }
        } catch (_) {}
        _showMessage(errorMessage);
      }
    } catch (e) {
      _showMessage('오류 발생: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _checkEmailDuplicate() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('이메일을 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _emailChecked = false;
    });

    try {
      final uri = Uri.parse('http://223.130.136.121:8082/api/user/check-email?email=$email');
      final response = await http.get(uri);

      print('응답 상태: ${response.statusCode}');
      print('응답 내용: ${response.body}');

      if (response.body.isEmpty) {
        setState(() {
          _emailCheckMessage = '서버 응답이 없습니다.';
          _emailCheckColor = Colors.red;
        });
        return;
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['available'] == true) {
        setState(() {
          _emailCheckMessage = data['message'] ?? '사용 가능한 이메일입니다.';
          _emailCheckColor = Colors.green;
          _emailChecked = true;
        });
      } else {
        setState(() {
          _emailCheckMessage = data['message'] ?? '이미 사용 중인 이메일입니다.';
          _emailCheckColor = Colors.red;
          _emailChecked = false;
        });
      }
    } catch (e) {
      setState(() {
        _emailCheckMessage = '오류 발생: $e';
        _emailCheckColor = Colors.red;
        _emailChecked = false;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('회원가입 완료'),
          content: Text('회원가입이 성공적으로 완료되었습니다.'),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: Text(
          '회원가입',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField('이름', _nameController),
                      SizedBox(height: 15),
                      _buildTextField('이메일', _emailController, isEmail: true),
                      SizedBox(height: 15),
                      _buildTextField('비밀번호', _passwordController, obscureText: true),
                      SizedBox(height: 15),
                      _buildTextField('비밀번호 확인', _confirmPasswordController, obscureText: true),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: _isLoading ? null : _signUp,
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('회원가입', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, bool isEmail = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                decoration: InputDecoration(
                  hintText: '입력',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                onChanged: isEmail
                    ? (_) {
                  setState(() {
                    _emailChecked = false;
                    _emailCheckMessage = null;
                    _emailCheckColor = Colors.grey;
                  });
                }
                    : null,
              ),
            ),
            if (isEmail) SizedBox(width: 10),
            if (isEmail)
              ElevatedButton(
                onPressed: _isLoading ? null : _checkEmailDuplicate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text('중복 확인'),
              ),
          ],
        ),
        if (isEmail && _emailCheckMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _emailCheckMessage!,
              style: TextStyle(color: _emailCheckColor),
            ),
          ),
      ],
    );
  }
}
