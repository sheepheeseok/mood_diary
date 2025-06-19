package com.example.mood_diary.service;

import java.util.List;
import java.util.Map;

import org.springframework.http.HttpHeaders; 
import org.springframework.http.MediaType; 
import org.springframework.http.HttpEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ChatService {
    
    @Value("${openai.api.key}")
    private String openaiApiKey;
    
    private final RestTemplate restTemplate = new RestTemplate();

    public String getChatbotResponse(String userMessage) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(openaiApiKey);

        Map<String, Object> requestBody = Map.of(
            "model", "gpt-3.5-turbo",
            "temperature", 0.3,
            "max_tokens", 100,
            "messages", List.of(
                Map.of("role", "system", "content",   "당신은 'Mood Diary'라는 감정일기 앱의 감정들을 모아 나눠준다는 의미의 이름인 상담 챗봇 Emoa입니다. 이 앱은 사용자가 감정을 기록하고 자기이해를 돕는 것을 목표로 합니다. 감정 상태에 따라 감정 카드를 선택하고 일기를 쓰며, 당신은 공감과 위로를 주는 역할을 합니다. 답변은 2~3문장으로 따뜻하고 간결하게 마무리된 답변으로 작성하세요."),
                Map.of("role", "user", "content", userMessage)
            )
        );

         HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<String> response = restTemplate.postForEntity(
                "https://api.openai.com/v1/chat/completions",
                entity,
                String.class
            );
            return extractMessage(response.getBody());

        } catch (Exception e) {
            return "죄송해요. 답변 중 문제가 발생했어요.";
        }
    }

    private String extractMessage(String responseBody) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(responseBody);
            return root.path("choices").get(0).path("message").path("content").asText();
        } catch (Exception e) {
            return "답변을 이해하지 못했어요.";
        }
    }
}
