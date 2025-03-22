package com.example.HandTalk.repository;

import com.example.HandTalk.domain.CheckIn;
import com.example.HandTalk.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface CheckInRepository extends JpaRepository<CheckIn, Long> {

    // 오늘 출석했는지 여부 확인
    boolean existsByUserAndCheckInDate(User user, LocalDate checkInDate);

    // 유저의 출석 기록을 날짜 기준 내림차순 정렬
    List<CheckIn> findByUserOrderByCheckInDateDesc(User user);
}