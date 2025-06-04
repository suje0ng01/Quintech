package com.example.HandTalk.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class WeeklyGameStatsDto {
    private int weeklyAttempts;
    private double weeklyAverageAccuracy;
    private double globalWeeklyAverageAccuracy;
    private List<GameAttemptDto> history;
}
