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
    private Map<String, Boolean> consonantVowelProgress; // "consonant", "vowel"
    private int overallConsonantVowelProgress;

    private Map<String, Boolean> wordProgress;           // topic -> 완료 여부
    private int overallWordProgress;
}
