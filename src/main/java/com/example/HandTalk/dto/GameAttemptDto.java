package com.example.HandTalk.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class GameAttemptDto {
    private LocalDateTime playedAt;
    private int correctCount;
    private int totalCount;
    private double accuracy;
}
