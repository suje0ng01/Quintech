import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'state/login_state.dart';
import 'constants/constants.dart';
import 'learning/learningpage.dart';
import 'settings/setting_page.dart';
import 'dictionary/dictionary_page.dart';
import 'member/login.dart';
import 'member/profilepage.dart';
import 'dictionary/korean_dictionary_webview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) { 
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginState>(context);
    final isLoggedIn = loginState.isLoggedIn;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: const Text(
          '수어메이트',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const SettingsPage(),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(-1, 0), end: Offset.zero).chain(
                        CurveTween(curve: Curves.ease),
                      ),
                    ),
                    child: child,
                  );
                },
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => isLoggedIn ? const ProfilePage() : LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(icon: Icons.menu_book, text: '학습'),
            CustomButton(icon: Icons.sports_esports, text: '게임'),
            CustomButton(icon: Icons.bookmark, text: '단어장'),
            CustomButton(icon: Icons.public, text: '한국수어사전'),
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final IconData icon;
  final String text;

  const CustomButton({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber),
      ),
      child: TextButton(
        onPressed: () {
          if (text == '학습') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LearningPage()),
            );
          } else if (text == '게임') {
            // 추후 연결
          } else if (text == '단어장') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DictionaryPage()),
            );
          } else if (text == '한국수어사전') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DictionaryWebViewPage(
                  url: 'https://sldict.korean.go.kr/front/main/main.do',
                ),
              ),
            );
          }
        },
        style: TextButton.styleFrom(foregroundColor: Colors.black),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
