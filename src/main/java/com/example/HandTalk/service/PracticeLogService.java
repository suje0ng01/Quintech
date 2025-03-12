package com.example.HandTalk.service;


import com.example.HandTalk.repository.PoseDataRepository;
import com.example.HandTalk.repository.PracticeLogRepository;
import com.example.HandTalk.domain.PoseData;
import com.example.HandTalk.domain.PracticeLog;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class PracticeLogService {

    private final PracticeLogRepository practiceLogRepository;
    private final PoseDataRepository poseDataRepository;


    // 연습 기록 저장
    public PracticeLog savePracticeLog(PracticeLog practiceLog) {
        return practiceLogRepository.save(practiceLog);
    }

    // 특정 유저의 연습 기록 조회
    public List<PracticeLog> getPracticeLogsByUserId(Long userId) {
        return practiceLogRepository.findByUserId(userId);
    }

    // 특정 연습 기록의 포즈 데이터 조회
    public List<PoseData> getPoseDataByPracticeLogId(Long practiceLogId) {
        return poseDataRepository.findByPracticeLogId(practiceLogId);
    }

}
