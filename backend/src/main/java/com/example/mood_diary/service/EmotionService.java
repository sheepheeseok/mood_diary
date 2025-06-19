package com.example.mood_diary.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.mood_diary.entity.EmotionTag;
import com.example.mood_diary.repository.EmotionRepository;

@Service
public class EmotionService {
    private final EmotionRepository emotionRepository;

    public EmotionService(EmotionRepository emotionRepository) {
        this.emotionRepository = emotionRepository;
    }

    public EmotionTag save(EmotionTag emotionTag) {
        return emotionRepository.save(emotionTag);
    }

    public List<EmotionTag> findAll() {
        return emotionRepository.findAll();
    }
}
