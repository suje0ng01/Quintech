package com.example.HandTalk.service;


import com.example.HandTalk.domain.CheckIn;
import com.example.HandTalk.domain.User;
import com.example.HandTalk.repository.CheckInRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor


public class CheckInService {

    private final CheckInRepository checkInRepository;


    // ✅ 오늘 출석 체크
    public String checkIn(User user) {
        LocalDate today = LocalDate.now();
        boolean alreadyCheckedIn = checkInRepository.existsByUserAndCheckInDate(user, today);

        if (alreadyCheckedIn) {
            return "이미 출석 체크 완료!";
        }

        CheckIn checkIn = new CheckIn();
        checkIn.setUser(user);
        checkIn.setCheckInDate(today);
        checkInRepository.save(checkIn);

        return "출석 체크 완료!";
    }

    // ✅ 연속 출석일 계산
    public int calculateStreak(User user) {
        List<CheckIn> checkIns = checkInRepository.findByUserOrderByCheckInDateDesc(user);

        int streak = 0;
        LocalDate today = LocalDate.now();

        for (CheckIn checkIn : checkIns) {
            if (checkIn.getCheckInDate().equals(today.minusDays(streak))) {
                streak++;
            } else {
                break; // 연속 출석이 끊기면 종료
            }
        }

        return streak;
    }


}
