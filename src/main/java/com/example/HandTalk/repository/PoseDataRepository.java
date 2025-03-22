package com.example.HandTalk.repository;

import com.example.HandTalk.domain.PoseData;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface PoseDataRepository extends JpaRepository<PoseData, Long> {
    List<PoseData> findByPracticeLogId(Long practiceLogId);
}
