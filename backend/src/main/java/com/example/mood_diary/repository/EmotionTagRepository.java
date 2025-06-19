package com.example.mood_diary.repository;

import com.example.mood_diary.entity.EmotionTag;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface EmotionTagRepository extends JpaRepository<EmotionTag, Long> {
    Optional<EmotionTag> findByName(String name);
}
