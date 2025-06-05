import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/constants.dart';
import 'wordlearning.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({Key? key}) : super(key: key);

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  final storage = FlutterSecureStorage();

  Map<String, bool> wordProgress = {};
  bool consonantProgress = false;
  bool vowelProgress = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProgress();
  }

  Future<void> fetchProgress() async {
    final jwt = await storage.read(key: 'jwt_token');

    if (jwt == null || jwt.isEmpty) {
      print('❌ JWT 토큰이 없습니다.');
      setState(() => isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse('http://223.130.136.121:8082/api/practice/progress'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        consonantProgress = data['consonantVowelProgress']['consonant'];
        vowelProgress = data['consonantVowelProgress']['vowel'];
        wordProgress = Map<String, bool>.from(data['wordProgress']);
        isLoading = false;
      });
    } else {
      print('API 오류: ${response.statusCode}');
      print('응답 본문: ${response.body}');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F1),
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: const Text(
          '학습',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBox(),
            const SizedBox(height: 20),
            _buildChapterCard(context, '모음', vowelProgress),
            _buildChapterCard(context, '자음', consonantProgress),
            ..._buildWordChapters(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWordChapters() {
    List<String> categories = [
      '주생활',
      '동물',
      '인간',
      '사회생활',
      '삶',
      '문화',
      '개념',
      '기타',
      '경제생활'
    ];

    return categories.map((title) {
      bool progress = wordProgress[title] ?? false;
      return _buildChapterCard(context, title, progress);
    }).toList();
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📌 이용 안내', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('• 각 챕터별 80% 이상 정답 시 학습 완료로 인정됩니다.'),
          Text('• 주제 진행도 = 해당 주제의 완료된 챕터 수 비율 (%)'),
        ],
      ),
    );
  }

  Widget _buildChapterCard(BuildContext context, String title, bool isCompleted) {
    String status;
    Color statusColor;

    if (!isCompleted) {
      status = '학습 전';
      statusColor = Colors.grey;
    } else {
      status = '학습 완료';
      statusColor = Colors.green;
    }

    return GestureDetector(
      onTap: () async {
        // 상세 페이지로 이동하고, 돌아올 때까지 기다린다.
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LearningDetailPage(category: title),
          ),
        );
        // 상세 페이지에서 뒤로 돌아오면, 최신 진행도를 다시 불러온다.
        await fetchProgress();
      },
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
