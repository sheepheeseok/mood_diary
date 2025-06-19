package com.example.mood_diary.service;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.mood_diary.entity.Activity;
import com.example.mood_diary.entity.User;
import com.example.mood_diary.repository.ActivityRepository;
import com.example.mood_diary.repository.UserRepository;

@Service
@Transactional
public class ActivityService {

    private final ActivityRepository activityRepository;
    private final UserRepository userRepository;

    public ActivityService(ActivityRepository activityRepository, UserRepository userRepository) {
        this.activityRepository = activityRepository;
        this.userRepository = userRepository;
    }

    public List<Activity> getActivitiesByUserEmail(String email) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));
        return activityRepository.findByUser(user);
    }

    public void saveOrUpdateActivities(String email, Map<String, Boolean> activities) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));

        for (Map.Entry<String, Boolean> entry : activities.entrySet()) {
            String activityName = entry.getKey();
            boolean checked = entry.getValue();

            Optional<Activity> existingActivity = activityRepository.findByUserAndActivityName(user, activityName);

            if (existingActivity.isPresent()) {
                Activity activity = existingActivity.get();
                activity.setChecked(checked);
                activityRepository.save(activity);
            } else {
                Activity newActivity = new Activity();
                newActivity.setUser(user);
                newActivity.setActivityName(activityName);
                newActivity.setChecked(checked);
                activityRepository.save(newActivity);
            }
        }
    }
    
    @Transactional
    public void deleteActivityByUserEmailAndName(String email, String activityName) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));

        activityRepository.findByUserAndActivityName(user, activityName)
            .ifPresent(activityRepository::delete);
    }
}
