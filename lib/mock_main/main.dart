import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mock_main_page.dart'; // 임시 메인 페이지
import 'login_state.dart'; //로그인 상태

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LoginState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  //디버그 배너 제거
      home: const MockMainPage(),  //TODO : 테스트 메인 페이지 > 홈페이지로 수정
    );
  }
}

