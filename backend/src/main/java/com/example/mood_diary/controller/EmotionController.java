package com.example.mood_diary.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.mood_diary.entity.EmotionTag;
import com.example.mood_diary.service.EmotionService;

@RestController
@RequestMapping("/api/emotions")
public class EmotionController {
    private final EmotionService emotionService;

    public EmotionController(EmotionService emotionService) {
        this.emotionService = emotionService;
    }

    @PostMapping
    public EmotionTag save(@RequestBody EmotionTag emotionTag) {
        return emotionService.save(emotionTag);
    }

    @GetMapping
    public List<EmotionTag> getAll() {
        return emotionService.findAll();
    }
}
