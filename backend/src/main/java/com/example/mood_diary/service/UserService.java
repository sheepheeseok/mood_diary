package com.example.mood_diary.service;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.example.mood_diary.entity.User;
import com.example.mood_diary.repository.UserRepository;

@Service
public class UserService {
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User save(User user) {
        return userRepository.save(user);
    }

    public List<User> findAll() {
        return userRepository.findAll();
    }

      public boolean isEmailDuplicate(String email) {
        return userRepository.existsByEmail(email);
    }

    public boolean changePassword(String email, String currentPassword, String newPassword) {
        Optional<User> optionalUser = userRepository.findByEmail(email);
        if (optionalUser.isEmpty()) {
            return false;
        }

        User user = optionalUser.get();

        // 현재 비밀번호 평문 비교
        if (!user.getPassword().equals(currentPassword)) {
            return false;
        }

        user.setPassword(newPassword); // 암호화 없이 평문 저장
        userRepository.save(user);
        return true;
    }
} 