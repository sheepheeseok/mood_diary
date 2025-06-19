package com.example.mood_diary.repository;


import org.springframework.data.jpa.repository.JpaRepository;
import com.example.mood_diary.entity.EmotionTag;

public interface EmotionRepository extends JpaRepository<EmotionTag, Long> {
 
}
