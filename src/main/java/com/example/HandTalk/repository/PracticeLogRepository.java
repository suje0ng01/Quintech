package com.example.HandTalk.repository;


import com.example.HandTalk.domain.PracticeLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PracticeLogRepository extends JpaRepository<PracticeLog, Long> {
    List<PracticeLog> findByUserId(Long userId);
}
