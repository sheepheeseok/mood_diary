package com.example.mood_diary.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.mood_diary.entity.Activity;
import com.example.mood_diary.service.ActivityService;

@RestController
@RequestMapping("/api/activities")
public class ActivityController {

    private final ActivityService activityService;

    public ActivityController(ActivityService activityService) {
        this.activityService = activityService;
    }

    // 이메일을 쿼리 파라미터로 받고 활동 리스트 반환
    @GetMapping(value = "/list", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> getActivities(@RequestParam String email) {
        if (email == null || email.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Email is required");
        }

        try {
            List<Activity> activities = activityService.getActivitiesByUserEmail(email);
            return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).body(activities);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    // 이메일과 활동 데이터를 요청 바디 JSON으로 받음
    @PostMapping(value = "/save", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> saveActivities(@RequestBody Map<String, Object> requestBody) {
        Object emailObj = requestBody.get("email");
        Object activitiesObj = requestBody.get("activities");

        if (emailObj == null || !(emailObj instanceof String)) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Email is required");
        }

        if (activitiesObj == null || !(activitiesObj instanceof Map)) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Activities data is required");
        }

        String email = (String) emailObj;
        @SuppressWarnings("unchecked")
        Map<String, Boolean> activities = (Map<String, Boolean>) activitiesObj;

        try {
            activityService.saveOrUpdateActivities(email, activities);
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    // 삭제 API 추가
    @DeleteMapping("/delete")
    public ResponseEntity<?> deleteActivity(@RequestParam String email, @RequestParam String activityName) {
        if (email == null || email.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Email is required");
        }
        if (activityName == null || activityName.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Activity name is required");
        }

        try {
            System.out.println("DELETE 요청 activityName: " + activityName);
            activityService.deleteActivityByUserEmailAndName(email, activityName);
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }
}
