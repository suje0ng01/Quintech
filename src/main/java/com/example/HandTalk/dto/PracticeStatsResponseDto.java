package com.example.HandTalk.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Map;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PracticeStatsResponseDto {
    private boolean consonantCompleted;
    private boolean vowelCompleted;
    private Map<String, WordProgressDto> wordProgress;  // topic -> 진행률 정보
}
