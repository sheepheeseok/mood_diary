import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mood_diary/config.dart';

Future<String> askChatbot(String email, String message) async {
  try {
    final response = await http.post(
      Uri.parse('http://$backendIp:$backendPort/api/chat/ask'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'message': message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['response'] ?? '응답이 없습니다.';
    } else if (response.statusCode >= 500) {
      return '💥 서버 오류가 발생했어요. 나중에 다시 시도해 주세요.';
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      return '🚫 인증 정보가 만료되었거나 잘못되었습니다.';
    } else {
      return '⚠️ 요청이 실패했어요 (${response.statusCode}).';
    }
  } catch (e) {
    return '🌐 네트워크 오류: 인터넷 연결을 확인해 주세요.';
  }
}

/// ✅ 감정 이름 -> 카운트
Future<Map<String, int>> fetchEmotionSummary(String email) async {
  try {
    final uri = Uri.parse('http://$backendIp:$backendPort/api/diaries/emotions/summary?email=$email');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> raw = json.decode(utf8.decode(response.bodyBytes));
      return raw.map((key, value) => MapEntry(key, value['count'] as int));
    } else {
      throw Exception('⚠️ 감정 요약 데이터를 불러올 수 없습니다. (${response.statusCode})');
    }
  } catch (e) {
    throw Exception('🌐 네트워크 오류: ${e.toString()}');
  }
}

/// ✅ 감정 이름 -> 이미지 경로
Future<Map<String, String>> fetchEmotionImageMap(String email) async {
  try {
    final uri = Uri.parse('http://$backendIp:$backendPort/api/diaries/emotions/summary?email=$email');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> raw = json.decode(utf8.decode(response.bodyBytes));
      return raw.map((key, value) {
        final imageName = value['imageUrl'] ?? 'neutral.png';
        return MapEntry(key, imageName);
      });
    } else {
      throw Exception('⚠️ 감정 이미지 정보를 불러올 수 없습니다. (${response.statusCode})');
    }
  } catch (e) {
    throw Exception('🌐 이미지 경로 요청 오류: ${e.toString()}');
  }
}

/// ✅ 텍스트 요약 (감정 이름 + 횟수)
Future<String> fetchEmotionSummaryAsText(String email) async {
  try {
    final uri = Uri.parse('http://$backendIp:$backendPort/api/diaries/emotions/summary?email=$email');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data.isEmpty) return '분석할 감정 데이터가 없어요. 먼저 일기를 작성해 주세요.';

      final summary = data.entries.map((e) {
        final count = e.value['count'] ?? 0;
        return '${e.key}: ${count}회';
      }).join('\n');

      return '🧠 지금까지의 감정 분석 결과예요:\n\n$summary';
    } else {
      return '⚠️ 감정 데이터를 불러오는 데 실패했어요. (${response.statusCode})';
    }
  } catch (e) {
    return '🌐 감정 분석 요청 중 오류가 발생했어요: ${e.toString()}';
  }
}
