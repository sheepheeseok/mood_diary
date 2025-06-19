package com.example.mood_diary.controller;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.mood_diary.entity.User;
import com.example.mood_diary.service.UserService;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

   @PostMapping
public ResponseEntity<?> save(@RequestBody User user) {
    System.out.println("➡️ 받은 사용자 정보:");
    System.out.println("firstName: " + user.getFirstName());
    System.out.println("lastName: " + user.getLastName());
    System.out.println("email: " + user.getEmail());
    System.out.println("password: " + user.getPassword());

    try {
        User savedUser = userService.save(user);
        return ResponseEntity.ok(savedUser);
    } catch (org.springframework.dao.DataIntegrityViolationException e) {
        System.out.println("⚠️ 이메일 중복 오류: " + e.getMessage());
        return ResponseEntity.status(409).body("이미 존재하는 이메일입니다.");
    }
}
    @GetMapping
    public List<User> getAll() {
        return userService.findAll();
    }

    @GetMapping("/check-email")
    public ResponseEntity<Map<String, Boolean>> checkEmailDuplicate(@RequestParam String email) {
        boolean isDuplicate = userService.isEmailDuplicate(email);
        return ResponseEntity.ok(Collections.singletonMap("duplicate", isDuplicate));
    }

     @PostMapping("/change-password")
    public ResponseEntity<Map<String, String>> changePassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String currentPassword = request.get("currentPassword");
        String newPassword = request.get("newPassword");

        boolean changed = userService.changePassword(email, currentPassword, newPassword);

        if (changed) {
            return ResponseEntity.ok(Collections.singletonMap("message", "Password changed successfully"));
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Collections.singletonMap("message", "Current password is incorrect or user not found"));
        }
    }
}

