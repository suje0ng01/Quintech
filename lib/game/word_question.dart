// lib/pages/game_word_question_view.dart
import 'package:flutter/material.dart';
import 'package:quintech/game/video_playerwidget.dart' show VideoPlayerWidget;

class WordQuestionView extends StatelessWidget {
  final Map<String, dynamic> questionData;
  final TextEditingController answerController;
  final VoidCallback onAnswerCorrect;
  final VoidCallback onAnswerIncorrect;

  const WordQuestionView({
    required this.questionData,
    required this.answerController,
    required this.onAnswerCorrect,
    required this.onAnswerIncorrect,
    Key? key,
  }) : super(key: key);

  bool isVideoUrl(String? url) {
    if (url == null) return false;
    final lowerUrl = url.toLowerCase();
    final path = lowerUrl.split('?').first;
    return path.endsWith('.mp4') || path.endsWith('.mov');
  }

  @override
  Widget build(BuildContext context) {
    final String? videoUrl = questionData['videoUrl'];
    final String question = questionData['question'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '수어 영상을 보고 단어를 입력하세요',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (videoUrl != null && videoUrl.isNotEmpty)
            isVideoUrl(videoUrl)
                ? AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayerWidget(url: videoUrl),
            )
                : Image.network(
              videoUrl,
              width: 300,
              height: 200,
              fit: BoxFit.contain,
            )
          else
            const Text('미디어 없음'),
          const SizedBox(height: 20),
          TextField(
            controller: answerController,
            decoration: const InputDecoration(
              labelText: "정답을 입력하세요",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final userInput = answerController.text.trim().toLowerCase();
                final correctAnswer = question.trim().toLowerCase();
                if (userInput == correctAnswer) {
                  onAnswerCorrect();
                } else {
                  onAnswerIncorrect();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "정답 확인",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
