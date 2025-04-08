import 'package:flutter/material.dart';
import 'package:quintech/member/signUp.dart';
import 'package:quintech/constants/constants.dart'; // 파일 경로에 맞게 조정

import '../main.dart';
import 'findpassword.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: Text(
          '로그인',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // 현재 페이지 닫고 이전 페이지로 이동
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                    Text('이메일', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 5),
                    TextField(
                      decoration: InputDecoration(
                        hintText: '입력',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5), // 모서리 둥글게
                          borderSide: BorderSide(color: Colors.grey, width: 1), // 테두리 연한 회색
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1), // 기본 테두리 연한 회색
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.black, width: 2), // 클릭 시 검은색 테두리
                        ),
                      ),
                    ),

                    SizedBox(height: 15),
                    Text('비밀번호', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 5),
                    TextField(
                      decoration: InputDecoration(
                        hintText: '입력',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5), // 모서리 둥글게
                          borderSide: BorderSide(color: Colors.grey, width: 1), // 테두리 연한 회색
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1), // 기본 테두리 연한 회색
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.black, width: 2), // 클릭 시 검은색 테두리
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                        ),
                        onPressed: () {},
                        child: Text('로그인', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FindPasswordPage()),
                              );
                          },
                          child: Text('비밀번호 찾기', style: TextStyle(color: Colors.black)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpPage()),
                            );
                          },
                          child: Text('회원 가입', style: TextStyle(color: Colors.black)),
                        ),
                      ],
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
