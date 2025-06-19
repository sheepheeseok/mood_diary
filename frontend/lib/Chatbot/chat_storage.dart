import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_message.dart';

class ChatStorage {
  static const _key = 'chat_temp_messages';

  static Future<void> save(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(messages.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<List<ChatMessage>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final decoded = jsonDecode(data) as List;
    return decoded.map((e) => ChatMessage.fromJson(e)).toList();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
