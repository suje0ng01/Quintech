package com.example.HandTalk.repository;

import com.example.HandTalk.domain.GameLog;
import com.example.HandTalk.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface GameLogRepository extends JpaRepository<GameLog, Long> {

    // ✅ 특정 사용자의 전체 게임 로그 조회
    List<GameLog> findByUser(User user);

    // ✅ 가장 최근 게임 로그 (Optional로 반환)
    Optional<GameLog> findTopByUserOrderByPlayedAtDesc(User user);

    List<GameLog> findByUserAndPlayedAtAfter(User user, LocalDateTime after);
    List<GameLog> findByPlayedAtAfter(LocalDateTime after);


}
