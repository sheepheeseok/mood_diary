package com.example.mood_diary.service;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.example.mood_diary.entity.DiaryEntry;
import com.example.mood_diary.entity.User;
import com.example.mood_diary.repository.DiaryRepository;
import com.example.mood_diary.repository.UserRepository;

import jakarta.transaction.Transactional;

@Service
public class DiaryService {
    private final DiaryRepository diaryRepository;
    private final UserRepository userRepository;

    public DiaryService(DiaryRepository diaryRepository, UserRepository userRepository) {
        this.diaryRepository = diaryRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public DiaryEntry save(DiaryEntry diaryEntry) {
        // userRepository 조회는 컨트롤러나 호출하는 쪽에서 처리하는 게 일반적이므로
        // save 시에는 diaryEntry가 올바른 상태라고 가정하고 바로 저장합니다.
        return diaryRepository.save(diaryEntry);
    }

    public List<DiaryEntry> findAll() {
        return diaryRepository.findAll();
    }

    // 신규 추가: id로 단일 일기 조회
    public Optional<DiaryEntry> findById(Long id) {
        return diaryRepository.findById(id);
    }
}
