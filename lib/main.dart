import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'state/login_state.dart'; // LoginState import
import 'constants/constants.dart'; // 색상 같은 상수 모음
import 'learning/learningpage.dart'; // 학습 페이지
 import 'settings/setting_page.dart'; // 설정 페이지
import 'dictionary/dictionary_page.dart'; // 단어장
import 'member/login.dart'; // 로그인 페이지
import 'member/profilepage.dart'; // 프로필 페이지

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginState()),
      ],
      child: const MyApp(),
    ),
  );
  print('Firebase Initialized');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: HomeScreen(),
    );
  }
}

// 홈 화면
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: const Text(
          '수어메이트',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                const SettingsPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
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
                  // MaterialPageRoute(builder: (context) => ProfilePage()),

                );
              }
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

// 커스텀 버튼 위젯
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
            // 추후 게임 페이지 연결
          } else if (text == '단어장') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DictionaryPage()),
            );
          } else if (text == '한국수어사전') {
            // 추후 사전 페이지 연결
          }
        },
        style: TextButton.styleFrom(foregroundColor: Colors.black),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}


//
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'constants/uploadpage.dart'; // ✅ 업로드하는 UploadPage import
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: UploadPage(
//         category: '인간',        // ✅ 업로드할 때 사용할 카테고리 이름
//         documentId: '예쁘다(곱다)',         // ✅ 업로드할 때 사용할 문서 ID (ex: ㄱ, ㄴ, ㄷ 같은 것)
//       ),
//     );
//   }
// }
