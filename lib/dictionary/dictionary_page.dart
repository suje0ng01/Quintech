import 'package:flutter/material.dart';
import 'package:quintech/main.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../member/profilepage.dart';
import '../state/login_state.dart';
import '../settings/setting_page.dart';
import 'package:quintech/constants/constants.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/dummy_member.dart'; //TODO : 더미 사용자 정보 > 추후 삭제

//단어장 페이지
class DictionaryPage extends StatefulWidget {
  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  bool isLoading = true;

  final FocusNode searchFocusNode = FocusNode();
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String searchText = '';
  List<Map<String, String>> firestoreWords = [];
  List<String> filteredWords = [];
  late Map<String, GlobalKey> sectionKeys;

  @override
  void initState() {
    super.initState();
    fetchWordsFromFirebase();

    // 강제로 키보드 포커스 제거 (키보드 내려가게 하기)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.unfocus();
      searchController.clear();
    });

    // 자음별 위치 저장용 Key 초기화
    sectionKeys = {
      for (var ch in ['ㄱ','ㄴ','ㄷ','ㄹ','ㅁ','ㅂ','ㅅ','ㅇ','ㅈ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ'])
        ch: GlobalKey()
    };
  }

  Future<void> fetchWordsFromFirebase() async {
    List<String> categories = [
      '개념', '경제생활', '기타', '동식물', '모음',
      '문화', '사회생활', '삶', '식생활', '인간',
      '자음', '주생활'
    ];

    List<Map<String, String>> allWords = [];

    for (final category in categories) {
      final snapshot = await FirebaseFirestore.instance
          .collection('learningdata')
          .doc('category')
          .collection(category)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data == null || !data.containsKey('question') || !data.containsKey('imageUrl')) continue;

        final word = data['question'];
        final videoUrl = data['imageUrl'];

        if (videoUrl != null && videoUrl != '' && word != null) {
          allWords.add({'word': word, 'videoUrl': videoUrl});
        }
      }
    }

    setState(() {
      firestoreWords = allWords;
      filteredWords = allWords
        .expand((e) => e['word']!.split(',').map((w) => w.trim()))
        .toSet()
        .toList();
        isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Provider.of<LoginState>(context).isLoggedIn;
    final groupedWords = groupByInitialConsonant(filteredWords); // 정렬 및 자음 그룹화
    final user = DummyUser.example; //더미 회원 정보

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          FocusManager.instance.primaryFocus?.unfocus(); // 뒤로가기 시 키보드 내려주기
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appbarcolor,
          centerTitle: true,
          title: const Text(
            '단어장',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
          actions: [
            IconButton(
              icon: isLoggedIn
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(user.profileImageUrl),
                    )
                  : const Icon(Icons.account_circle, size: 30, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: SafeArea( // 🔐 SafeArea로 전체 감싸기 (디버그 레이아웃 방지)
          child: Column(
            children: [
              // 검색창
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    hintText: '검색어를 입력하세요',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                      filteredWords = firestoreWords
                        .where((e) => e['word']!.contains(searchText))
                        .map((e) => e['word']!)
                        .toList();
                    });
                  },
                ),
              ),
              // 자음 바 + 단어 리스트
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 자음 바 (왼쪽) - 고정된 너비와 안정적인 높이 확보
                        Expanded(
                          flex: 0, // 고정된 너비만큼만 차지
                          child: SizedBox(
                            width: 40,
                            child: Container(
                              color: Colors.white, // 디버그 무늬 방지
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: sectionKeys.keys.map((ch) {
                                  return GestureDetector(
                                    onTap: () {
                                      final keyContext = sectionKeys[ch]!.currentContext;
                                      if (keyContext != null) {
                                        Scrollable.ensureVisible(
                                          keyContext,
                                          duration: const Duration(milliseconds: 300),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        ch,
                                        style: const TextStyle(fontSize: 14, color: Colors.blue),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        // 단어 리스트 (오른쪽)
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: groupedWords.length,
                            itemBuilder: (context, index) {
                              final initial = groupedWords.keys.elementAt(index);
                              final words = groupedWords[initial]!;

                              if (words.isEmpty) return const SizedBox();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    key: sectionKeys[initial],
                                    width: double.infinity,
                                    color: Colors.blue[100],
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  ...words.map((word) {
                                    final videoUrl = firestoreWords.firstWhere(
                                      (e) => e['word']!.split(',').contains(word),
                                      orElse: () => {'videoUrl': ''}, // 예외 방지용
                                    )['videoUrl']!;

                                    return ListTile(
                                      title: Text(word),
                                      trailing: TextButton(
                                        child: const Text('수어 >'),
                                        onPressed: () {
                                          print('📹 $word의 영상 URL: $videoUrl');

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => WordDetailPage(word: word, videoUrl: videoUrl),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ), 
        bottomNavigationBar: BottomAppBar(
          child: IconButton(
            icon: const Icon(Icons.home, size: 30),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus(); // 홈 이동 전 키보드 내리기
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
              );
            },
          ),
        ),
      ),
    );
  }

  //자음 추출 및 정렬
  Map<String, List<String>> groupByInitialConsonant(List<String> words) {
    Map<String, List<String>> grouped = {
      for (var ch in ['ㄱ','ㄴ','ㄷ','ㄹ','ㅁ','ㅂ','ㅅ','ㅇ','ㅈ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ']) ch: []
    };

    for (var word in words) {
      if (word.isEmpty) continue; //빈 문자열 방지

      final firstChar = word.characters.first;
      final rawInitial = _getInitialConsonant(firstChar);
      final normalizedInitial = _normalizeInitial(rawInitial);
      if (grouped.containsKey(normalizedInitial)) {
        grouped[normalizedInitial]!.add(word);
      }
    }

    for (var list in grouped.values) {
      list.sort();
    }

    return grouped;
  }

  String _getInitialConsonant(String char) {
    int codeUnit = char.codeUnitAt(0) - 0xAC00;
    if (codeUnit < 0 || codeUnit > 11171) return char;
    int initialIndex = codeUnit ~/ 588;
    const initials = [
      'ㄱ','ㄲ','ㄴ','ㄷ','ㄸ','ㄹ','ㅁ','ㅂ','ㅃ','ㅅ','ㅆ',
      'ㅇ','ㅈ','ㅉ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ'
    ];
    return initials[initialIndex];
  }

  String _normalizeInitial(String initial) {
    const mapping = {
      'ㄲ': 'ㄱ',
      'ㄸ': 'ㄷ',
      'ㅃ': 'ㅂ',
      'ㅆ': 'ㅅ',
      'ㅉ': 'ㅈ',
    };
    return mapping[initial] ?? initial;
  }
}

//단어장 상세 페이지
class WordDetailPage extends StatefulWidget {
  final String word;
  final String videoUrl;

  const WordDetailPage({
    super.key,
    required this.word,
    required this.videoUrl,
  });
  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  late VideoPlayerController _controller;
  bool isVideo = false;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    isVideo = widget.videoUrl.toLowerCase().contains('.mp4') || widget.videoUrl.toLowerCase().contains('.mov');

    if (isVideo) {
      _controller = VideoPlayerController.network(widget.videoUrl)
        ..initialize().then((_) {
          setState(() {
            isInitialized = true;
          });
          _controller.play();
          _controller.setLooping(true);
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mediaWidget;

    if (isVideo) {
      mediaWidget = AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      );
    } else {
      mediaWidget = Image.network(
        widget.videoUrl,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Text('영상을 불러올 수 없습니다.'),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: AppColors.appbarcolor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            mediaWidget,
            const SizedBox(height: 30),
            Text(
              widget.word,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
