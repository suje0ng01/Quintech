import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔥 Firestore 추가
import '../constants/constants.dart';

class FindPasswordPage extends StatefulWidget {
  @override
  _FindPasswordPageState createState() => _FindPasswordPageState();
}

class _FindPasswordPageState extends State<FindPasswordPage> {
  final emailController = TextEditingController();
  bool _isLoading = false;

  // ✅ 비밀번호 재설정 메일 전송 함수 (Firestore에서 이메일 존재 여부 확인)
  Future<void> sendPasswordReset() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('이메일을 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 🔍 Firestore에서 해당 이메일로 가입된 유저가 있는지 확인
      final snapshot = await FirebaseFirestore.instance
          .collection('users') // ⚠️ 컬렉션 이름이 실제와 다를 경우 수정
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _showSnackBar('해당 이메일로 가입된 계정이 없습니다.');
      } else {
        // 📤 비밀번호 재설정 이메일 전송
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        _showSnackBar('비밀번호 재설정 메일을 보냈습니다!\n메일함을 확인해주세요.');
      }
    } catch (e) {
      _showSnackBar('오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: const Text(
          '비밀번호 찾기',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
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
                            : const Text(
                          '비밀번호 재설정',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
