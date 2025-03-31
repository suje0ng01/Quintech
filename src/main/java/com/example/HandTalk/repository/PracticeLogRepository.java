package com.example.HandTalk.repository;

import com.example.HandTalk.domain.ContentType;
import com.example.HandTalk.domain.PracticeLog;
import com.example.HandTalk.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PracticeLogRepository extends JpaRepository<PracticeLog, Long> {

    // 자음/모음 반복 학습 수 조회
    List<PracticeLog> findByUserAndContentTypeIn(User user, List<ContentType> contentTypes);

    // contentType별 총 학습 횟수 (자음/모음)
    long countByUserAndContentType(User user, ContentType contentType);

    // 단어 중 completed = true 인 챕터 수
    long countByUserAndContentTypeAndCompletedTrue(User user, ContentType contentType);
}
