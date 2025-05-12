package com.example.HandTalk.repository;

import com.example.HandTalk.domain.ContentType;
import com.example.HandTalk.domain.PracticeLog;
import com.example.HandTalk.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PracticeLogRepository extends JpaRepository<PracticeLog, Long> {

    // 자음/모음 완료 여부 체크용
    boolean existsByUserAndContentTypeAndCompletedTrue(User user, ContentType contentType);

    // 단어 전체 학습 로그 (진도율 계산 시 사용)
    List<PracticeLog> findByUserAndContentType(User user, ContentType contentType);

    // 단어 완료된 로그만 조회 (진도율 계산 시 사용)
    List<PracticeLog> findByUserAndContentTypeAndCompletedTrue(User user, ContentType contentType);

    // ✅ 전체 완료된 학습 로그 (게임 출제용)
    List<PracticeLog> findByUserAndCompletedTrue(User user);

    // ✅ 가장 마지막에 저장된 학습 로그 (현재 학습 단원 판단용)
    Optional<PracticeLog> findTopByUserOrderByFinishedAtDesc(User user);
}
