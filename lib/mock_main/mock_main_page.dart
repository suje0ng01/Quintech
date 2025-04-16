import 'package:flutter/material.dart';
import '../settings/setting_page.dart'; //설정 클래스
import '../dictionary/dictionary_page.dart'; //사전 페이지

//TODO : 테스트 위한 임시 메인 페이지 >> 추후 삭제
class MockMainPage extends StatelessWidget {
  const MockMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title: const Text(
          '메인 페이지 (임시)',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
              child: const Text('설정'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DictionaryPage()));
              },
              child: const Text('단어장'),
            ),
          ],
        ),
      ),
    );
  }
}