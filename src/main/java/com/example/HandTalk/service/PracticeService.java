package com.example.HandTalk.service;

import com.example.HandTalk.domain.ContentType;
import com.example.HandTalk.domain.PracticeLog;
import com.example.HandTalk.domain.User;
import com.example.HandTalk.dto.PracticeLogRequestDto;
import com.example.HandTalk.dto.PracticeStatsResponseDto;
import com.example.HandTalk.dto.WordProgressDto;
import com.example.HandTalk.repository.PracticeLogRepository;
import com.example.HandTalk.repository.UserRepository;
import com.example.HandTalk.util.WordTopicLoader;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@RequiredArgsConstructor
public class PracticeService {

    private final PracticeLogRepository practiceLogRepository;
    private final UserRepository userRepository;
    private final WordTopicLoader wordTopicLoader;

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

        boolean consonantDone = practiceLogRepository.existsByUserAndContentTypeAndCompletedTrue(user, ContentType.CONSONANT);
        boolean vowelDone = practiceLogRepository.existsByUserAndContentTypeAndCompletedTrue(user, ContentType.VOWEL);

        Map<String, WordProgressDto> wordProgressMap = new HashMap<>();

        List<PracticeLog> completedWordLogs = practiceLogRepository.findByUserAndContentTypeAndCompletedTrue(user, ContentType.WORD);
        Map<String, Set<String>> completedChaptersPerTopic = new HashMap<>();

        for (PracticeLog log : completedWordLogs) {
            if (log.getTopic() != null && log.getChapter() != null) {
                completedChaptersPerTopic
                        .computeIfAbsent(log.getTopic(), k -> new HashSet<>())
                        .add(log.getChapter());
            }
        }

        // JSON 기반 총 챕터 수 사용
        for (Map.Entry<String, Integer> entry : wordTopicLoader.getTopicToChapterCount().entrySet()) {
            String topic = entry.getKey();
            int total = entry.getValue();
            int completed = completedChaptersPerTopic.getOrDefault(topic, Collections.emptySet()).size();
            int progress = total == 0 ? 0 : (int) Math.round((completed * 100.0) / total);

            wordProgressMap.put(topic, new WordProgressDto(completed, total, progress));
        }

        return new PracticeStatsResponseDto(consonantDone, vowelDone, wordProgressMap);
    }
}
