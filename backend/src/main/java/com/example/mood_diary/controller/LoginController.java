package com.example.mood_diary.controller;

import com.example.mood_diary.entity.User;
import com.example.mood_diary.repository.UserRepository;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Optional;

@RestController
@RequestMapping("/api")
public class LoginController {

    private final UserRepository userRepository;

    public LoginController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody User loginRequest, HttpServletResponse response) {
        System.out.println("➡️ 로그인 시도: " + loginRequest.getEmail());

        Optional<User> userOpt = userRepository.findByEmail(loginRequest.getEmail());

        if (userOpt.isEmpty()) {
            System.out.println("❌ 사용자 없음");
            return ResponseEntity.status(401).body("이메일 또는 비밀번호가 올바르지 않습니다.");
        }

        User user = userOpt.get();

        if (!user.getPassword().equals(loginRequest.getPassword())) {
            System.out.println("❌ 비밀번호 불일치");
            return ResponseEntity.status(401).body("이메일 또는 비밀번호가 올바르지 않습니다.");
        }

        // 이메일 쿠키
        Cookie emailCookie = new Cookie("email", user.getEmail());
        emailCookie.setHttpOnly(true);
        emailCookie.setPath("/");
        emailCookie.setMaxAge(60 * 60); // 1시간
        response.addCookie(emailCookie);

        String encodedUsername = URLEncoder.encode(user.getUsername(), StandardCharsets.UTF_8);
        Cookie usernameCookie = new Cookie("username", encodedUsername);
        usernameCookie.setPath("/");
        usernameCookie.setMaxAge(60 * 60); // 1시간
        response.addCookie(usernameCookie);


        System.out.println("✅ 로그인 성공: " + user.getEmail() + ", 사용자명: " + user.getFirstName());
        return ResponseEntity.ok("로그인 성공");
    }
}
