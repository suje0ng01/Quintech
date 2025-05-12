package com.example.HandTalk.service;

import com.example.HandTalk.domain.ContentType;
import com.example.HandTalk.domain.PracticeLog;
import com.example.HandTalk.domain.User;
import com.example.HandTalk.dto.GameQuestionDto;
import com.example.HandTalk.repository.PracticeLogRepository;
import com.example.HandTalk.repository.UserRepository;
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
    private final WordTopicLoader wordTopicLoader;

    public List<GameQuestionDto> generateGameQuestions(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));

        List<PracticeLog> completedLogs = practiceLogRepository.findByUserAndCompletedTrue(user);

        boolean hasConsonant = false;
        boolean hasVowel = false;
        List<PracticeLog> wordLogs = new ArrayList<>();

        for (PracticeLog log : completedLogs) {
            if (log.getContentType() == ContentType.CONSONANT) {
                hasConsonant = true;
            } else if (log.getContentType() == ContentType.VOWEL) {
                hasVowel = true;
            } else if (log.getContentType() == ContentType.WORD) {
                wordLogs.add(log);
            }
        }

        List<GameQuestionDto> allQuestions = new ArrayList<>();

        // ✅ 자음 1개 랜덤 포함
        if (hasConsonant) {
            List<String> consonants = new ArrayList<>(List.of("ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"));
            Collections.shuffle(consonants);
            allQuestions.add(new GameQuestionDto(ContentType.CONSONANT, null, consonants.get(0)));
        }

        // ✅ 모음 1개 랜덤 포함
        if (hasVowel) {
            List<String> vowels = new ArrayList<>(List.of("ㅏ", "ㅑ", "ㅓ", "ㅕ", "ㅗ", "ㅛ", "ㅜ", "ㅠ", "ㅡ", "ㅣ", "ㅐ", "ㅔ", "ㅚ", "ㅟ", "ㅢ"));
            Collections.shuffle(vowels);
            allQuestions.add(new GameQuestionDto(ContentType.VOWEL, null, vowels.get(0)));
        }

        // ✅ 단어 문제 생성
        for (PracticeLog wordLog : wordLogs) {
            allQuestions.addAll(toQuestionDto(wordLog));
        }

        Collections.shuffle(allQuestions);
        return allQuestions.stream()
                .limit(20)
                .collect(Collectors.toList());
    }

    private List<GameQuestionDto> toQuestionDto(PracticeLog log) {
        if (log.getContentType() != ContentType.WORD) return Collections.emptyList();

        String topic = log.getTopic();
        List<String> words = wordTopicLoader.getWordsByTopic(topic);
        if (words == null || words.isEmpty()) return Collections.emptyList();

        return words.stream()
                .map(word -> new GameQuestionDto(ContentType.WORD, topic, word))
                .collect(Collectors.toList());
    }
}
