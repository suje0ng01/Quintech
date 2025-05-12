package com.example.HandTalk.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class GameStatsResponseDto {
    private double myAccuracy;       // 내 평균 정답률
    private double globalAccuracy;   // 전체 사용자 평균 정답률
}
