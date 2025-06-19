class EmotionData {
  final String date;
  final String emotion;
  final String imageUrl;
  final String content;

  EmotionData({
    required this.date,
    required this.emotion,
    required this.imageUrl,
    required this.content,
  });

  factory EmotionData.fromJson(Map<String, dynamic> json) {
    return EmotionData(
      date: json['date'] ?? '',
      emotion: json['emotion'] ?? '',
      imageUrl: (json['imageUrl'] ?? '').toString(),
      content: json['content'] ?? '',
    );
  }
}
