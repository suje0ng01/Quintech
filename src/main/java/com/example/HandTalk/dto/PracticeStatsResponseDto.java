package com.example.HandTalk.dto;

import com.example.HandTalk.domain.ContentType;
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
    private Map<String, Boolean> wordProgress;           // topic -> 완료 여부

    private ContentType latestContentType; // ✅ 최근 학습 유형
    private String latestTopic;            // ✅ 최근 학습 주제 (WORD일 경우만)
}
