// lib/pages/game_vowel_consonant_view.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class VowelConsonantView extends StatelessWidget {
  final Map<String, dynamic> questionData;
  final CameraController? cameraController;
  final bool isCameraInitialized;
  final VoidCallback onNext;

  const VowelConsonantView({
    required this.questionData,
    required this.cameraController,
    required this.isCameraInitialized,
    required this.onNext,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String question = questionData['question'] ?? '';
    final double mainBoxSize = MediaQuery.of(context).size.width * 0.8 > 400
        ? 400
        : MediaQuery.of(context).size.width * 0.8;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '아래 적힌 단어를 손으로 표현해보세요',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: mainBoxSize,
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueAccent.shade100, width: 2),
              ),
              child: Text(
                question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: mainBoxSize,
            height: mainBoxSize,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: isCameraInitialized && cameraController != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: cameraController!.value.previewSize!.height,
                    height: cameraController!.value.previewSize!.width,
                    child: CameraPreview(cameraController!),
                  ),
                ),
              ),
            )
                : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onNext,
            child: const Text('다음 문제'),
          ),
        ],
      ),
    );
  }
}
