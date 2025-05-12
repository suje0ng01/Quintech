package com.example.HandTalk.service;

import com.example.HandTalk.domain.Role;
import com.example.HandTalk.domain.User;
import com.example.HandTalk.dto.UserRequestDto;
import com.example.HandTalk.dto.UserResponseDto;
import com.example.HandTalk.dto.UserUpdateRequestDto;
import com.example.HandTalk.repository.UserRepository;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final CheckInService checkInService; // ✅ 출석 계산용

    // ✅ 닉네임 자동 생성 로직 (중복 방지)
    private String generateUniqueNickname(String baseNickname) {
        String nickname = baseNickname;
        int suffix = 1;

        while (userRepository.existsByNickname(nickname)) {
            nickname = baseNickname + suffix;
            suffix++;
        }
        return nickname;
    }

    // ✅ 회원가입
    public UserResponseDto registerUser(@Valid UserRequestDto userRequestDto) {
        if (userRepository.findByEmail(userRequestDto.getEmail()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "이미 존재하는 이메일입니다.");
        }

        if (userRepository.existsByNickname(userRequestDto.getNickname())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "이미 존재하는 닉네임입니다.");
        }

        String encodedPassword = passwordEncoder.encode(userRequestDto.getPassword());

        User user = new User();
        user.setName(userRequestDto.getName());
        user.setEmail(userRequestDto.getEmail());
        user.setNickname(userRequestDto.getNickname());
        user.setPassword(encodedPassword);
        user.setRole(Role.USER);

        User savedUser = userRepository.save(user);

        return new UserResponseDto(savedUser, 0); // ✅ 가입 시 streak은 0
    }

    // ✅ 사용자 정보 조회 (이메일 기반, streak 포함)
    public UserResponseDto getUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."));

        int streak = checkInService.calculateStreak(user); // ✅ 출석일 계산
        return new UserResponseDto(user, streak);
    }

    // ✅ 사용자 닉네임 수정
    public UserResponseDto updateUserProfile(String email, UserUpdateRequestDto updateRequest) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."));

        if (userRepository.existsByNickname(updateRequest.getNickname())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "이미 존재하는 닉네임입니다.");
        }

        user.setNickname(updateRequest.getNickname());
        userRepository.save(user);

        int streak = checkInService.calculateStreak(user);
        return new UserResponseDto(user, streak);
    }

    // ✅ 엔티티 조회용
    public User getUserEntityByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."));
    }

    // ✅ 회원 탈퇴
    @Transactional
    public void deleteUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "사용자가 존재하지 않습니다."));

        // 연관 데이터 삭제 (추후 연동 필요 시 주석 해제)
        // practiceLogRepository.deleteByUser(user);
        // poseDataRepository.deleteByUser(user);

        userRepository.delete(user);
    }
}
