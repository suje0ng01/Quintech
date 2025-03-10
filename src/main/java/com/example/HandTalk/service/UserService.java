package com.example.HandTalk.service;

import com.example.HandTalk.dto.UserRequestDto;
import com.example.HandTalk.dto.UserResponseDto;
import com.example.HandTalk.repository.UserRepository;
import com.example.HandTalk.user.Role;
import com.example.HandTalk.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder; // 비밀번호 암호화를 위한 필드 추가

    public UserResponseDto registerUser(UserRequestDto userRequestDto) {
        // ✅ 이메일 중복 검사 추가
        if (userRepository.findByEmail(userRequestDto.getEmail()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "이미 존재하는 이메일입니다.");
        }

        // 비밀번호 암호화
        String encodedPassword = passwordEncoder.encode(userRequestDto.getPassword());

        User user = new User();
        user.setName(userRequestDto.getName());
        user.setEmail(userRequestDto.getEmail());
        user.setPassword(encodedPassword);
        user.setRole(Role.USER);

        User savedUser = userRepository.save(user);
        return new UserResponseDto(savedUser);
    }
}
