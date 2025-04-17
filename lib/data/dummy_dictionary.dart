import 'dart:math';
//TODO : 더미데이터 - firebase 연동 시 삭제

class DummyDictionary {
  // 더미 단어 리스트
  static final List<String> words = [
    '감사', '강아지', '건물', '고양이',
    '나비', '낙지', '너구리',
    '다리', '달걀',
    '마늘', '망고',
    '사랑', '사자',
    '안녕하세요', '양파',
    '자동차', '잠자리',
    '학교', '행복', '호랑이',
    '꽃', '딸기', '가을', '가위'
  ];

  // 샘플 영상 경로 (추후 Firebase로 대체 예정)
  static final List<String> sampleVideoPaths = [
    'assets/videos/test_video1.mp4',
    'assets/videos/test_video2.mp4',
  ];

  // 단어-영상 매핑
  static final Map<String, String> wordToVideoMap = {
    for (var word in words)
      word: sampleVideoPaths[Random().nextInt(sampleVideoPaths.length)]
  };
}
