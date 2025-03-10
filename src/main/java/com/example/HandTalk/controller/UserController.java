package com.example.HandTalk.controller;

import com.example.HandTalk.service.UserService;
import com.example.HandTalk.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController // ✅ 여기 확인!
@RequiredArgsConstructor
@RequestMapping("/api/user")
public class UserController {

    private final UserService userService;

    @PostMapping("/register")
    public ResponseEntity<User> registerUser(@RequestBody User user) { // ✅ @RequestBody 추가
        User savedUser = userService.registerUser(user.getName(), user.getEmail(), user.getPassword());
        return ResponseEntity.ok(savedUser);
    }
}
