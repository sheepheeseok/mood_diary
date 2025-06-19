package com.example.mood_diary.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.mood_diary.entity.Activity;
import com.example.mood_diary.entity.User;

public interface ActivityRepository extends JpaRepository<Activity, Long> {
    List<Activity> findByUser(User user);
    Optional<Activity> findByUserAndActivityName(User user, String activityName);
}

