import 'package:flutter/material.dart';
import '../constants/constants.dart';

class LearningPage extends StatelessWidget {
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBox(),
            const SizedBox(height: 20),
            _buildChapterCard('모음', 0.0),
            _buildChapterCard('자음', 0.3),
            _buildChapterCard('식생활', 1.0),
            _buildChapterCard('주생활', 0.0),
            _buildChapterCard('동식물', 0.0),
            _buildChapterCard('인간', 0.0),
            _buildChapterCard('사회생활', 0.0),
            _buildChapterCard('삶', 0.0),
            _buildChapterCard('문화', 0.0),
            _buildChapterCard('개념', 0.0),
            _buildChapterCard('기타', 0.0),
            _buildChapterCard('경제생활', 0.0),
          ],
        ),
      ),
    );
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

  Widget _buildChapterCard(String title, double progress) {
    String status;
    Color statusColor;

    if (progress == 0.0) {
      status = '학습 전';
      statusColor = Colors.grey;
    } else if (progress < 1.0) {
      status = '학습 중';
      statusColor = Colors.orange;
    } else {
      status = '학습 완료';
      statusColor = Colors.green;
    }

    return Container(
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
    );
  }
}
