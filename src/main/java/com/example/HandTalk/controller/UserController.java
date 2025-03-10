package com.example.HandTalk.controller;

import com.example.HandTalk.dto.UserRequestDto;
import com.example.HandTalk.dto.UserResponseDto;
import com.example.HandTalk.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping("/register")
    public ResponseEntity<UserResponseDto> registerUser(@RequestBody UserRequestDto userRequestDto) {
        UserResponseDto savedUser = userService.registerUser(userRequestDto);
        return ResponseEntity.ok(savedUser);
    }
}
