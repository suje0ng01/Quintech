package com.example.HandTalk.repository;

import com.example.HandTalk.domain.GameProblem;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GameProblemRepository extends JpaRepository<GameProblem, Long> {
}

