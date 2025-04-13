package com.example.HandTalk.service;

import com.example.HandTalk.domain.ContentType;
import com.example.HandTalk.domain.PracticeLog;
import com.example.HandTalk.domain.User;
import com.example.HandTalk.dto.GameQuestionDto;
import com.example.HandTalk.repository.PracticeLogRepository;
import com.example.HandTalk.repository.UserRepository;
import com.example.HandTalk.util.FirebaseVideoMapper;
import com.example.HandTalk.util.WordTopicLoader;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GameQuestionService {

    private final UserRepository userRepository;
    private final PracticeLogRepository practiceLogRepository;
    private final FirebaseVideoMapper firebaseVideoMapper;
    private final WordTopicLoader wordTopicLoader; // ✅ 단어 목록 불러오는 컴포넌트

    public List<GameQuestionDto> generateGameQuestions(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));

        // ✅ 1. 완료된 학습 항목 수집 (정답률 80% 이상)
        List<PracticeLog> completedLogs = practiceLogRepository.findByUserAndCompletedTrue(user);

        // ✅ 2. 단어 기준 문제 추출
        List<GameQuestionDto> questions = completedLogs.stream()
                .map(log -> toQuestionDto(log))
                .flatMap(List::stream)  // 여러 개의 단어가 있을 수 있으니 flatMap
                .filter(q -> q.getVideoUrl() != null)
                .collect(Collectors.toList());

        Collections.shuffle(questions);
        return questions.stream().limit(20).collect(Collectors.toList());
    }

    private List<GameQuestionDto> toQuestionDto(PracticeLog log) {
        ContentType type = log.getContentType();

        // 자음/모음 → 단일 문제로 반환
        if (type == ContentType.CONSONANT || type == ContentType.VOWEL) {
            String key = (type == ContentType.CONSONANT) ? "consonant" : "vowel";
            String url = firebaseVideoMapper.getVideoUrl(type, key);
            return Collections.singletonList(new GameQuestionDto(type, null, key, url));
        }

        // WORD 타입 → topic 하위 단어 중 1개 랜덤 선택
        String topic = log.getTopic();
        List<String> wordList = wordTopicLoader.getWordsByTopic(topic);
        if (wordList == null || wordList.isEmpty()) return Collections.emptyList();

        // 랜덤 단어 선택
        String randomWord = wordList.get(new Random().nextInt(wordList.size()));
        String url = firebaseVideoMapper.getVideoUrl(type, randomWord);
        return Collections.singletonList(new GameQuestionDto(type, topic, randomWord, url));
    }
}
