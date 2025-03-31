package com.example.HandTalk.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PracticeStatsResponseDto {

    // 자음 통계
    private int consonantTotalAttempts;

    // 모음 통계
    private int vowelTotalAttempts;

    // 단어 통계
    private int wordChapterCount;  // 총 완료한 챕터 수
}
