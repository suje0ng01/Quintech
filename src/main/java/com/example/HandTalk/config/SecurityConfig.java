package com.example.HandTalk.config;

import com.example.HandTalk.service.CustomUserDetailsService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {


    private final CustomUserDetailsService customUserDetailsService;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable()) // 개발용: CSRF 비활성화
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/", "/login", "/join","/api/user/register","/auth/login").permitAll() // 로그인, 회원가입은 모두 허용
                        .anyRequest().authenticated() // 나머지는 인증 필요
                )
                .formLogin(form -> form
                        .loginPage("/login")  // 로그인 페이지 설정
                        .loginProcessingUrl("/loginProc") // 로그인 요청 URL
                        .defaultSuccessUrl("/") // 로그인 성공 시 이동할 페이지
                        .failureUrl("/login?error=true") // 로그인 실패 시 이동할 페이지
                        .usernameParameter("email") // 로그인 시 사용할 아이디 파라미터
                        .passwordParameter("password") // 로그인 시 사용할 비밀번호 파라미터
                        .permitAll()
                )
                .logout(logout -> logout
                        .logoutUrl("/logout")
                        .logoutSuccessUrl("/login") // 로그아웃 후 이동할 페이지
                        .invalidateHttpSession(true) // 세션 삭제
                        .deleteCookies("JSESSIONID") // 쿠키 삭제
                        .permitAll()
                );


        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
