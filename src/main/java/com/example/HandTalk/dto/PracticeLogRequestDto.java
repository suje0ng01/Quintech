package com.example.HandTalk.dto;

import com.example.HandTalk.domain.ContentType;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class PracticeLogRequestDto {

    private ContentType contentType; // CONSONANT, VOWEL, WORD
    private String chapter;          // WORD일 때만 사용, 나머지는 null 또는 빈 문자열 가능
    private int correctCount;
    private int totalCount;
    private double accuracy;
    private boolean completed;
    private LocalDateTime finishedAt;
}
