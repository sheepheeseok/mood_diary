class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final bool isGraph;
  final Map<String, int>? graphData;
  final Map<String, String>? graphImageMap;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.isGraph = false,
    this.graphData,
    this.graphImageMap,
  });

  // 🔹 JSON으로 변환
  Map<String, dynamic> toJson() => {
    'text': text,
    'isMe': isMe,
    'timestamp': timestamp.toIso8601String(),
    'isGraph' : isGraph,
    'graphData' : graphData,
    'graphImageMap' : graphImageMap,
  };

  // 🔹 JSON에서 객체로 복원
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'],
    isMe: json['isMe'],
    timestamp: DateTime.parse(json['timestamp']),
    isGraph: json['isGraph'] ?? false,
    graphData: json['graphData'] != null
      ? Map<String, int>.from(json['graphData'])
        :null,
    graphImageMap: json['graphImageMap'] != null
        ? Map<String, String>.from(json['graphImageMap'])
        : null,
  );
}
