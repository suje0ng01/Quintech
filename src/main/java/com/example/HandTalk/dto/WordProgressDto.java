package com.example.HandTalk.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class WordProgressDto {
    private int completedChapterCount;
    private int totalChapterCount;
    private int progress;  // 0~100 정수
}
