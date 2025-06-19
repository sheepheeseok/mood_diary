import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mood_diary/Module/My_Diary.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/EmotionData.dart';
import '../widgets/emotion_card.dart';
import '../widgets/emotion_list.dart';
import '../config.dart';
import 'package:mood_diary/l10n/app_localizations.dart';

class DiaryEdit extends StatefulWidget {
  final EmotionData entry;
  final List<EmotionData> emotionDataList;

  const DiaryEdit({
    super.key,
    required this.entry,
    required this.emotionDataList,
  });

  @override
  State<DiaryEdit> createState() => _DiaryEditState();
}

class _DiaryEditState extends State<DiaryEdit> {
  late String displayDate;
  late TextEditingController _diaryController;
  late int selectedCardIndex;
  String? email;
  late DateTime parsedDate;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    parsedDate = DateTime.parse(widget.entry.date);
    _diaryController = TextEditingController(text: widget.entry.content);
    selectedCardIndex = emotionList.indexWhere((e) => e[1] == widget.entry.emotion);
    if (selectedCardIndex == -1) selectedCardIndex = 0;
    _loadEmailFromCookie();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      displayDate = DateFormat('MMMM d', Localizations.localeOf(context).toString()).format(parsedDate);
      _initialized = true;
    }
  }

  Future<void> _loadEmailFromCookie() async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString('session_cookie');
    if (cookie == null) return;

    final match = RegExp(r'email=([^;]+)').firstMatch(cookie);
    if (match == null) return;

    final encodedEmail = match.group(1);
    if (encodedEmail == null) return;

    setState(() {
      email = Uri.decodeComponent(encodedEmail);
    });
  }

  @override
  void dispose() {
    _diaryController.dispose();
    super.dispose();
  }

  Future<int?> fetchDiaryId(String email, String date) async {
    final encodedEmail = Uri.encodeQueryComponent(email);
    final encodedDate = Uri.encodeQueryComponent(date);
    final url = Uri.parse('http://$backendIp:8081/api/diaries/edit/id?email=$encodedEmail&date=$encodedDate');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'] as int?;
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch diary ID');
    }
  }

  Future<bool> updateDiaryEntry(int id, String content, String emotion) async {
    try {
      final url = Uri.parse('http://$backendIp:8081/api/diaries/edit/$id');

      final body = jsonEncode({
        'content': content,
        'emotion': emotion,
      });

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  String getEmotionLabel(String key) {
    switch (key) {
      case 'cheerful': return S.of(context)!.cheerful;
      case 'relaxed': return S.of(context)!.relaxed;
      case 'neutral': return S.of(context)!.neutral;
      case 'confident': return S.of(context)!.confident;
      case 'angry': return S.of(context)!.angry;
      case 'tired': return S.of(context)!.tired;
      case 'sad': return S.of(context)!.sad;
      case 'cry': return S.of(context)!.cry;
      case 'serene': return S.of(context)!.serene;
      case 'surprised': return S.of(context)!.surprised;
      case 'love': return S.of(context)!.love;
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.05,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    S.of(context)!.edit3,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontFamily: 'Grey Qo',
                      color: const Color(0xDD7A70DD),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.001),
              Align(
                alignment: Alignment.center,
                child: Text(
                  S.of(context)!.edit1,
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontFamily: 'Grey Qo',
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Center(
                child: Text(
                  '${S.of(context)!.edit2} - $displayDate',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontFamily: 'Kufam',
                    color: const Color(0xFF87898A),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(emotionList.length, (index) {
                    final label = getEmotionLabel(emotionList[index][1]);
                    final asset = 'assets/images/emotions/${emotionList[index][1]}.png';

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: EmotionCard(
                        label: label,
                        assetPath: asset,
                        isSelected: selectedCardIndex == index,
                        onSelected: (label, _) {
                          setState(() {
                            selectedCardIndex = index;
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                S.of(context)!.writescreen3,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontFamily: 'Kufam',
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
              Container(
                height: 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _diaryController,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontFamily: 'Grey Qo',
                    color: const Color(0xFF59585D),
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: S.of(context)!.writescreen4,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (email == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.of(context)!.write4)),
                      );
                      return;
                    }

                    final content = _diaryController.text;
                    final selectedEmotionCode = emotionList[selectedCardIndex][1];

                    try {
                      final diaryId = await fetchDiaryId(email!, widget.entry.date);

                      if (diaryId == null) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(S.of(context)!.diary_not_found)),
                          );
                        }
                        return;
                      }

                      final success = await updateDiaryEntry(diaryId, content, selectedEmotionCode);

                      if (success) {
                        if (mounted) Navigator.of(context).pop(true);
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(S.of(context)!.save_failed)),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('오류발생')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A70DD),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.35,
                      vertical: screenHeight * 0.025,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    S.of(context)!.write3,
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontFamily: 'Grey Qo',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
