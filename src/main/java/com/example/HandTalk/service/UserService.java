package com.example.HandTalk.service;

import com.example.HandTalk.repository.UserRepository;
import com.example.HandTalk.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;


    public User registerUser(String name, String email, String password) {
        // ✅ 이메일 중복 검사 추가
        if (userRepository.findByEmail(email).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "이미 존재하는 이메일입니다.");
        }

        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setPassword(password); // TODO: 실제 서비스에서는 비밀번호 암호화 필요
        return userRepository.save(user);
    }
}
