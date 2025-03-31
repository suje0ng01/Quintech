package com.example.HandTalk.service;

import com.example.HandTalk.domain.ContentType;
import com.example.HandTalk.domain.PracticeLog;
import com.example.HandTalk.domain.User;
import com.example.HandTalk.dto.PracticeLogRequestDto;
import com.example.HandTalk.dto.PracticeStatsResponseDto;
import com.example.HandTalk.repository.PracticeLogRepository;
import com.example.HandTalk.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PracticeService {

    private final PracticeLogRepository practiceLogRepository;
    private final UserRepository userRepository;

    // ✅ 학습 결과 저장
    @Transactional
    public void savePractice(String email, PracticeLogRequestDto dto) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));

        PracticeLog log = new PracticeLog();
        log.setUser(user);
        log.setContentType(dto.getContentType());
        log.setChapter(dto.getChapter()); // 단어 유형일 경우만 있음
        log.setCorrectCount(dto.getCorrectCount());
        log.setTotalCount(dto.getTotalCount());
        log.setAccuracy(dto.getAccuracy());
        log.setCompleted(dto.isCompleted());
        log.setFinishedAt(dto.getFinishedAt());

        practiceLogRepository.save(log);
    }


    public int getConsonantRepeatCount(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));
        return (int) practiceLogRepository.countByUserAndContentType(user, ContentType.CONSONANT);
    }

    public int getVowelRepeatCount(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));
        return (int) practiceLogRepository.countByUserAndContentType(user, ContentType.VOWEL);
    }




    // ✅ 진도율 조회
    public PracticeStatsResponseDto getProgressStats(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));

        long consonantTotal = practiceLogRepository.countByUserAndContentType(user, ContentType.CONSONANT);
        long vowelTotal = practiceLogRepository.countByUserAndContentType(user, ContentType.VOWEL);
        long wordCompleted = practiceLogRepository.countByUserAndContentTypeAndCompletedTrue(user, ContentType.WORD);

        return new PracticeStatsResponseDto((int) consonantTotal, (int) vowelTotal, (int) wordCompleted);
    }
}
