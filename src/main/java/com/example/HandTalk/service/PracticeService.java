package com.example.HandTalk.service;

import com.example.HandTalk.domain.ContentType;
import com.example.HandTalk.domain.PracticeLog;
import com.example.HandTalk.domain.User;
import com.example.HandTalk.dto.PracticeLogRequestDto;
import com.example.HandTalk.dto.PracticeStatsResponseDto;
import com.example.HandTalk.dto.WordProgressDto;
import com.example.HandTalk.repository.PracticeLogRepository;
import com.example.HandTalk.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@RequiredArgsConstructor
public class PracticeService {

    private final PracticeLogRepository practiceLogRepository;
    private final UserRepository userRepository;


    // Service 내 고정 맵
    private static final Map<String, Integer> TOTAL_CHAPTER_COUNT = Map.of(
            "인사말과 기본 표현", 4,
            "가족과 사람", 3,
            "음식과 식사", 2
            // 필요 시 추가
    );

    // ✅ 학습 결과 저장
    @Transactional
    public void savePractice(String email, PracticeLogRequestDto dto) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));

        PracticeLog log = new PracticeLog();
        log.setUser(user);
        log.setContentType(dto.getContentType());
        log.setChapter(dto.getChapter());
        log.setCorrectCount(dto.getCorrectCount());
        log.setTotalCount(dto.getTotalCount());
        log.setAccuracy(dto.getAccuracy());
        log.setCompleted(dto.isCompleted());
        log.setFinishedAt(dto.getFinishedAt());
        log.setTopic(dto.getTopic());

        practiceLogRepository.save(log);
    }

    // ✅ 진도율 조회
    public PracticeStatsResponseDto getProgressStats(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));

        // 자음/모음 완료 여부
        boolean consonantDone = practiceLogRepository.existsByUserAndContentTypeAndCompletedTrue(user, ContentType.CONSONANT);
        boolean vowelDone = practiceLogRepository.existsByUserAndContentTypeAndCompletedTrue(user, ContentType.VOWEL);

        // 단어 진도율 계산
        Map<String, WordProgressDto> wordProgressMap = new HashMap<>();

        // 완료된 WORD 로그
        List<PracticeLog> completedWordLogs = practiceLogRepository.findByUserAndContentTypeAndCompletedTrue(user, ContentType.WORD);
        Map<String, Set<String>> completedChaptersPerTopic = new HashMap<>();
        for (PracticeLog log : completedWordLogs) {
            if (log.getTopic() == null || log.getChapter() == null) continue;
            completedChaptersPerTopic
                    .computeIfAbsent(log.getTopic(), k -> new HashSet<>())
                    .add(log.getChapter());
        }

        // TOTAL_CHAPTER_COUNT 기준으로 진도율 계산
        for (Map.Entry<String, Integer> entry : TOTAL_CHAPTER_COUNT.entrySet()) {
            String topic = entry.getKey();
            int total = entry.getValue();
            int completed = completedChaptersPerTopic.getOrDefault(topic, Collections.emptySet()).size();
            int progress = total == 0 ? 0 : (int) Math.round((completed * 100.0) / total);

            wordProgressMap.put(topic, new WordProgressDto(completed, total, progress));
        }

        return new PracticeStatsResponseDto(consonantDone, vowelDone, wordProgressMap);
    }
}
