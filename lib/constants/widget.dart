 import 'package:flutter/material.dart';

class CorrectCounter extends StatelessWidget {
  const CorrectCounter({
    super.key,
    required this.currentIndex,
    required this.questions,
    required this.correctCount,
  });

  final List<Map<String, dynamic>> questions;
  final int currentIndex;
  final int correctCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (currentIndex + 1) / questions.length,
            color: Colors.blue,
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 4),
          Text('${currentIndex + 1}/${questions.length}'),
          const SizedBox(height: 8),
          Text(
            '정답 수: $correctCount / ${questions.length}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
