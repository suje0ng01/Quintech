package com.example.HandTalk.repository;

import com.example.HandTalk.domain.PoseData;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PoseDataRepository extends JpaRepository<PoseData, Long> {
    List<PoseData> findByPracticeLogId(Long practiceLogId);
}
