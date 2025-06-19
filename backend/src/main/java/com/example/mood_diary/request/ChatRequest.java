package com.example.mood_diary.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ChatRequest {
    private String email;
    private String message;
}
