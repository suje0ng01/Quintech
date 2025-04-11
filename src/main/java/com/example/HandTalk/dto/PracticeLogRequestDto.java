package com.example.HandTalk.dto;

import com.example.HandTalk.domain.ContentType;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class PracticeLogRequestDto {

    private ContentType contentType;      // CONSONANT, VOWEL, WORD
    private String topic;                 // ✅ 대주제 (단어 타입일 경우만)
    //private String word;               // ✅ 세부단어 (단어 타입일 경우만)
    private int correctCount;
    private int totalCount;
    private double accuracy;
    private boolean completed;
    private LocalDateTime finishedAt;
}
