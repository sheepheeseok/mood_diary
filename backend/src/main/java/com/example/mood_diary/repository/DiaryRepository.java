package com.example.mood_diary.repository;

import com.example.mood_diary.entity.DiaryEntry;
import com.example.mood_diary.entity.User;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface DiaryRepository extends JpaRepository<DiaryEntry, Long> {

    @Query("SELECT COUNT(d) > 0 FROM DiaryEntry d WHERE d.user.email = :email AND d.date = :date")
    boolean existsByEmailAndDate(@Param("email") String email, @Param("date") LocalDate date);

    @Query("SELECT d FROM DiaryEntry d WHERE d.user.email = :email AND d.date = :date")
    DiaryEntry findByUserEmailAndDate(@Param("email") String email, @Param("date") LocalDate date);

    @Query("SELECT d FROM DiaryEntry d WHERE d.user.email = :email")
    List<DiaryEntry> findByUserEmail(@Param("email") String email);

    List<DiaryEntry> findByUser(User user);
}
