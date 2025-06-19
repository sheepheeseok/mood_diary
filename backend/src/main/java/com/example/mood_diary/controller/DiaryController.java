package com.example.mood_diary.controller;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.*;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.mood_diary.entity.DiaryEntry;
import com.example.mood_diary.entity.EmotionTag;
import com.example.mood_diary.entity.User;
import com.example.mood_diary.repository.DiaryRepository;
import com.example.mood_diary.repository.EmotionTagRepository;
import com.example.mood_diary.repository.UserRepository;
import com.example.mood_diary.service.DiaryService;

@RestController
@RequestMapping("/api/diaries")
public class DiaryController {

    private final DiaryService diaryService;
    private final DiaryRepository diaryRepository;
    private final UserRepository userRepository;
    private final EmotionTagRepository emotionTagRepository;

    public DiaryController(DiaryService diaryService,
                           DiaryRepository diaryRepository,
                           UserRepository userRepository,
                           EmotionTagRepository emotionTagRepository) {
        this.diaryService = diaryService;
        this.diaryRepository = diaryRepository;
        this.userRepository = userRepository;
        this.emotionTagRepository = emotionTagRepository;
    }

    // ✅ 일기 저장 - emotion name과 user.email 기반 수동 매핑
    @PostMapping
    public ResponseEntity<DiaryEntry> save(@RequestBody Map<String, Object> request) {
        try {
            // 1. 사용자 이메일 추출
            Map<String, String> userMap = (Map<String, String>) request.get("user");
            String email = userMap.get("email");

            // 2. 감정 이름, 일기 내용, 날짜 추출
            String emotionName = (String) request.get("emotion");
            String content = (String) request.get("content");
            String dateStr = (String) request.get("date");
            LocalDate date = LocalDate.parse(dateStr);

            // 3. 유저/감정 태그 조회
            User user = userRepository.findByEmail(email)
                    .orElseThrow(() -> new RuntimeException("❌ 사용자 정보 없음"));

            EmotionTag emotion = emotionTagRepository.findByName(emotionName)
                    .orElseThrow(() -> new RuntimeException("❌ 감정 태그 없음"));

            // 4. DiaryEntry 구성 및 저장
            DiaryEntry entry = DiaryEntry.builder()
                    .user(user)
                    .date(date)
                    .content(content)
                    .emotion(emotion)
                    .build();

            return ResponseEntity.ok(diaryService.save(entry));

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    // ✅ 전체 일기 조회
    @GetMapping
    public List<DiaryEntry> getAll() {
        return diaryService.findAll();
    }

    // ✅ 일기 중복 체크
    @GetMapping("/check")
    public Map<String, Boolean> checkDiaryExists(@RequestParam String email, @RequestParam String date) {
        Map<String, Boolean> response = new HashMap<>();
        try {
            LocalDate parsedDate = LocalDate.parse(date);
            boolean exists = diaryRepository.existsByEmailAndDate(email, parsedDate);
            response.put("exists", exists);
        } catch (Exception e) {
            e.printStackTrace();
            response.put("exists", false);
        }
        return response;
    }

    // ✅ 최근 4일 감정 상태 조회
   @GetMapping(value = "/emotions/week", produces = "application/json; charset=UTF-8")
public List<Map<String, String>> getWeeklyEmotions(
        @RequestParam String email,
        @RequestParam(required = false) String date) {

    LocalDate baseDate;

    // date 파라미터가 있으면 파싱, 없으면 오늘 날짜 사용
    if (date != null) {
        try {
            baseDate = LocalDate.parse(date);
        } catch (DateTimeParseException e) {
            baseDate = LocalDate.now();
        }
    } else {
        baseDate = LocalDate.now();
    }

    // 기준 날짜 전후 2일씩 범위 지정 (총 5일)
    LocalDate startDate = baseDate.minusDays(1);
    LocalDate endDate = baseDate.plusDays(3);

    List<Map<String, String>> result = new ArrayList<>();

    // 지정 범위 날짜별로 DB 조회 및 결과 구성
    for (LocalDate targetDate = startDate; !targetDate.isAfter(endDate); targetDate = targetDate.plusDays(1)) {
        DiaryEntry entry = diaryRepository.findByUserEmailAndDate(email, targetDate);

        String emotionName = (entry != null && entry.getEmotion() != null)
                ? entry.getEmotion().getName()
                : "neutral";

        String imageUrl = (entry != null && entry.getEmotion() != null)
        ? entry.getEmotion().getImageUrl()
        : null;

        Map<String, String> item = new HashMap<>();
        item.put("date", targetDate.toString());
        item.put("emotion", emotionName);
        item.put("imageUrl", imageUrl);
        item.put("content", entry != null ? entry.getContent() : "");
        result.add(item);
    }

    return result;
}

    // --- 신규 API 추가 시작 ---
@GetMapping("/edit/id")
public ResponseEntity<Map<String, Long>> getDiaryIdByEmailAndDate(
        @RequestParam String email,
        @RequestParam String date) {
    try {
        LocalDate parsedDate = LocalDate.parse(date);
        DiaryEntry entry = diaryRepository.findByUserEmailAndDate(email, parsedDate);

        if (entry == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        return ResponseEntity.ok(Collections.singletonMap("id", entry.getId()));

    } catch (DateTimeParseException e) {
        // 날짜 포맷 에러 등 구체적 예외 처리
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
    }
}

@PutMapping("/edit/{id}")
public ResponseEntity<DiaryEntry> updateDiaryEntry(
        @PathVariable Long id,
        @RequestBody Map<String, Object> request) {
    try {
        DiaryEntry existingEntry = diaryService.findById(id)
                .orElseThrow(() -> new NoSuchElementException("일기 항목 없음"));

        String emotionName = (String) request.get("emotion");
        String content = (String) request.get("content");

        EmotionTag emotion = emotionTagRepository.findByName(emotionName)
                .orElseThrow(() -> new NoSuchElementException("감정 태그 없음"));

        existingEntry.setContent(content);
        existingEntry.setEmotion(emotion);

        DiaryEntry updatedEntry = diaryService.save(existingEntry);
        return ResponseEntity.ok(updatedEntry);

    } catch (NoSuchElementException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
    } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
    }
}

@GetMapping("/emotions/summary")
public ResponseEntity<Map<String, Map<String, Object>>> getEmotionSummaryWithImage(@RequestParam String email) {
    try {
        List<DiaryEntry> entries = diaryRepository.findByUserEmail(email);

        // 감정 이름 -> (count, imageUrl)
        Map<String, Map<String, Object>> result = new HashMap<>();

        for (DiaryEntry entry : entries) {
            EmotionTag emotion = entry.getEmotion();
            String name = (emotion != null) ? emotion.getName() : "neutral";
            String imageUrl = (emotion != null && emotion.getImageUrl() != null) ? emotion.getImageUrl() : "neutral.png";

            Map<String, Object> detail = result.getOrDefault(name, new HashMap<>());
            Object countObj = detail.get("count");
            int currentCount = (countObj instanceof Integer) ? (Integer) countObj : 0;

            detail.put("count", currentCount + 1);
            detail.put("imageUrl", imageUrl);

            result.put(name, detail);
        }

        return ResponseEntity.ok(result);

    } catch (Exception e) {
        e.printStackTrace();
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
}

@DeleteMapping("/delete-all")
public ResponseEntity<String> deleteAllDiariesByEmail(@RequestParam String email) {
    try {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new NoSuchElementException("사용자를 찾을 수 없습니다."));

        List<DiaryEntry> entries = diaryRepository.findByUser(user);
        diaryRepository.deleteAll(entries);

        return ResponseEntity.ok("모든 일기가 삭제되었습니다.");
    } catch (NoSuchElementException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("해당 이메일의 사용자를 찾을 수 없습니다.");
    } catch (Exception e) {
        e.printStackTrace();
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("서버 오류로 삭제에 실패했습니다.");
    }
}
}
