import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chat_message.dart';
import 'package:mood_diary/Chatbot/emotion_summary_chart.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final time = DateFormat('h:mm a').format(message.timestamp);

    // 🔹 감정 그래프 메시지일 경우
    if (message.isGraph && message.graphData != null) {
      final data = message.graphData!;
      final imageMap = message.graphImageMap ?? {};

      final sortedKeys = data.keys.toList()
        ..sort((a, b) => data[b]!.compareTo(data[a]!)); // 내림차순

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: EmotionSummaryChart(
                emotionData: data,
                emotionImageUrls: imageMap,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    // 🔹 일반 텍스트 메시지일 경우
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                gradient: isMe
                    ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF7A70DD),
                    Color(0xFF837BFF),
                    Color(0xFF5245FF),
                    Color(0xFF8C53D0),
                  ],
                )
                    : null,
                color: isMe ? null : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
