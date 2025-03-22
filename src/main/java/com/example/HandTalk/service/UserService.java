package com.example.HandTalk.service;

import com.example.HandTalk.dto.UserRequestDto;
import com.example.HandTalk.dto.UserResponseDto;
import com.example.HandTalk.repository.UserRepository;
import com.example.HandTalk.domain.Role;
import com.example.HandTalk.domain.User;
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


    public UserResponseDto registerUser(@Valid UserRequestDto userRequestDto) {
        // ✅ 이메일 중복 검사
        if (userRepository.findByEmail(userRequestDto.getEmail()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "이미 존재하는 이메일입니다.");
        }

        // ✅ 닉네임 중복 검사 (자동 생성 없이 에러 반환)
        if (userRepository.existsByNickname(userRequestDto.getNickname())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "이미 존재하는 닉네임입니다.");
        }

        // ✅ 비밀번호 암호화
        String encodedPassword = passwordEncoder.encode(userRequestDto.getPassword());

        // ✅ 유저 생성
        User user = new User();
        user.setName(userRequestDto.getName());
        user.setEmail(userRequestDto.getEmail());
        user.setNickname(userRequestDto.getNickname());
        user.setPassword(encodedPassword);
        user.setRole(Role.USER);

        User savedUser = userRepository.save(user);
        return new UserResponseDto(savedUser);
    }

    //이메일을 통한 회원조회
    public UserResponseDto getUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."));

        return new UserResponseDto(user);
    }
    public UserResponseDto updateNickname(String email, String newNickname) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

        // 닉네임 중복 검사
        if (userRepository.existsByNickname(newNickname)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "이미 사용 중인 닉네임입니다.");
        }

        user.setNickname(newNickname);
        User updatedUser = userRepository.save(user);

        return new UserResponseDto(updatedUser);
    }

    // ✅ 회원 탈퇴 서비스
    public void deleteUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "사용자가 존재하지 않습니다."));


        // ✅ 사용자 관련 데이터 삭제(추후 필드)
        //practiceLogRepository.deleteByUser(user);  // 학습 기록 삭제
        //poseDataRepository.deleteByUser(user);  // 손동작 데이터 삭제 (추후 사용 가능)

        userRepository.delete(user);
    }



}
