package com.example.mood_diary.controller;
import com.example.mood_diary.service.ChatService;
import com.example.mood_diary.request.ChatRequest;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;


@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {
    
    private final ChatService chatService;

    @PostMapping("/ask")
    public ResponseEntity<Map<String, String>> ask(@RequestBody ChatRequest request) {
        String reply = chatService.getChatbotResponse(request.getMessage());
        return ResponseEntity.ok(Map.of("response", reply));
    }
    
}
