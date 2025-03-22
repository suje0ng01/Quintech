package com.example.HandTalk.domain;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "check_in", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"user_id", "check_in_date"})
})// 하루에 한 번만 출석 체크 가능하도록 설정
public class CheckIn {


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;  // ✅ User와 연관 관계 설정 (ManyToOne)

    @Column(name = "check_in_date", nullable = false)
    private LocalDate checkInDate;


}