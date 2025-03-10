package com.example.HandTalk.api;


import com.example.HandTalk.service.PracticeLogService;
import com.example.HandTalk.user.PoseData;
import com.example.HandTalk.user.PracticeLog;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@AllArgsConstructor
@RequestMapping("/api/practice")
public class PracticeLogController {

    private final PracticeLogService practiceLogService;


    //연습기록 저장
    @PostMapping("/save")
    public ResponseEntity<PracticeLog> savePracticeLog(@RequestBody PracticeLog practiceLog) {
        PracticeLog savedLog = practiceLogService.savePracticeLog(practiceLog);
        return ResponseEntity.ok(savedLog);
    }

    // 2️⃣ 특정 유저의 연습 기록 조회 API
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<PracticeLog>> getUserPracticeLogs(@PathVariable Long userId) {
        List<PracticeLog> logs = practiceLogService.getPracticeLogsByUserId(userId);
        return ResponseEntity.ok(logs);
    }

    // 3️⃣ 특정 연습 기록의 포즈 데이터 조회
    @GetMapping("/{practiceLogId}/pose")
    public ResponseEntity<List<PoseData>> getPoseDataByPracticeLog(@PathVariable Long practiceLogId) {
        List<PoseData> poseDataList = practiceLogService.getPoseDataByPracticeLogId(practiceLogId);
        return ResponseEntity.ok(poseDataList);
    }

}
