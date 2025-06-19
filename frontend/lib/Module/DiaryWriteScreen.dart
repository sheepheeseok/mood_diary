import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mood_diary/Animations/fade_scale_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/emotion_card.dart';
import 'My_Diary.dart';
import '../config.dart';
import 'package:mood_diary/l10n/app_localizations.dart';

class DiaryWriteScreen extends StatefulWidget {
  const DiaryWriteScreen({super.key});

  @override
  State<DiaryWriteScreen> createState() => _DiaryWriteScreenState();
}

class _DiaryWriteScreenState extends State<DiaryWriteScreen> {
  String username = '사용자명';
  String? userEmail;
  late DateTime selectedDate;
  late String displayDate;

  final TextEditingController _diaryController = TextEditingController();

  List<String> emotionKeys = [
    'cheerful', 'relaxed', 'neutral', 'confident', 'angry', 'tired',
    'sad', 'cry', 'serene', 'surprised', 'love'
  ];

  int selectedEmotionIndex = 0;
  int? diaryId;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _loadUserInfoAndFetchDiary();
  }

  void _updateDisplayDate() {
    final locale = Localizations.localeOf(context).toString();
    displayDate = DateFormat('MMMM d', locale).format(selectedDate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDisplayDate();
    _loadUserInfoAndFetchDiary();
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

  Future<void> _loadUserInfoAndFetchDiary() async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString('session_cookie');
    if (cookie == null) return;

    final usernameMatch = RegExp(r'username=([^;]+)').firstMatch(cookie);
    final emailMatch = RegExp(r'email=([^;]+)').firstMatch(cookie);

    if (usernameMatch != null) {
      final decodedUsername = Uri.decodeComponent(usernameMatch.group(1)!);
      setState(() {
        username = decodedUsername;
      });
    }

    if (emailMatch != null) {
      final decodedEmail = Uri.decodeComponent(emailMatch.group(1)!);
      setState(() {
        userEmail = decodedEmail;
      });
      await fetchDiaryDataForDate(selectedDate);
    }
  }

  Future<void> fetchDiaryDataForDate(DateTime date) async {
    if (userEmail == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final uri = Uri.http('$backendIp:8081', '/api/diaries/emotions/week', {
      'email': userEmail!, 'date': dateStr
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final selectedEntryJson = jsonData.firstWhere(
              (item) => item['date'] == dateStr,
          orElse: () => null,
        );

        if (selectedEntryJson != null) {
          final content = selectedEntryJson['content'] ?? '';
          final emotionName = selectedEntryJson['emotion'] ?? emotionKeys[0];
          setState(() {
            _diaryController.text = content;
            selectedEmotionIndex = emotionKeys.indexOf(emotionName);
            if (selectedEmotionIndex == -1) selectedEmotionIndex = 0;
          });
        } else {
          setState(() {
            _diaryController.text = '';
            selectedEmotionIndex = 0;
          });
        }
      } else {
        setState(() {
          _diaryController.text = '';
          selectedEmotionIndex = 0;
        });
      }
    } catch (_) {
      setState(() {
        _diaryController.text = '';
        selectedEmotionIndex = 0;
      });
    }
  }

  Future<void> fetchDiaryIdForDate(DateTime date) async {
    if (userEmail == null) {
      diaryId = null;
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final uri = Uri.parse('http://$backendIp:8081/api/diaries/edit/id?email=${Uri.encodeQueryComponent(userEmail!)}&date=${Uri.encodeQueryComponent(dateStr)}');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        diaryId = data['id'] as int?;
      } else {
        diaryId = null;
      }
    } catch (_) {
      diaryId = null;
    }
  }

  Future<bool> _saveDiaryEntry() async {
    if (userEmail == null) return false;

    final content = _diaryController.text.trim();
    if (content.isEmpty) return false;

    final emotionCode = emotionKeys[selectedEmotionIndex];
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    await fetchDiaryIdForDate(selectedDate);

    if (diaryId != null) {
      final uri = Uri.parse('http://$backendIp:8081/api/diaries/edit/$diaryId');
      final body = jsonEncode({
        'content': content, 'emotion': emotionCode
      });
      final response = await http.put(uri, headers: {'Content-Type': 'application/json'}, body: body);
      return response.statusCode >= 200 && response.statusCode < 300;
    } else {
      final uri = Uri.parse('http://$backendIp:8081/api/diaries');
      final body = jsonEncode({
        'user': {'email': userEmail},
        'content': content,
        'emotion': emotionCode,
        'date': formattedDate,
      });
      final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: body);
      return response.statusCode >= 200 && response.statusCode < 300;
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now(),
      locale: Localizations.localeOf(context),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _updateDisplayDate();
      });
      await fetchDiaryDataForDate(picked);
    }
  }

  @override
  void dispose() {
    _diaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.07,
            right: screenWidth * 0.05,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(createFadeScaleRoute(MyDiaryScreen())),
              child: Text(
                S.of(context)!.edit3,
                style: TextStyle(
                  color: const Color(0xFF7A70DD),
                  fontSize: screenWidth * 0.04,
                  fontFamily: 'Kufam',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.07,
            top: screenHeight * 0.175,
            child: SizedBox(
              width: screenWidth * 0.8,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${S.of(context)!.writescreen1} $userEmail\n',
                      style: TextStyle(
                        color: const Color(0xFF87898A),
                        fontSize: screenWidth * 0.05,
                        fontFamily: 'Kufam',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: S.of(context)!.writescreen2,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.28,
            top: screenHeight * 0.10,
            child: GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.008),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7A70DD)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Date: $displayDate',
                      style: TextStyle(
                        color: const Color(0xFF7A70DD),
                        fontSize: screenWidth * 0.05,
                        fontFamily: 'Kufam',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    const Icon(Icons.calendar_today, color: Color(0xFF7A70DD)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.07,
            top: screenHeight * 0.27,
            child: SizedBox(
              width: screenWidth * 0.86,
              height: screenWidth * 0.33,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: emotionKeys.length,
                itemBuilder: (context, index) {
                  final key = emotionKeys[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: EmotionCard(
                      label: getEmotionLabel(key),
                      assetPath: 'assets/images/emotions/$key.png',
                      isSelected: selectedEmotionIndex == index,
                      onSelected: (label, _) {
                        setState(() {
                          selectedEmotionIndex = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.07,
            top: screenHeight * 0.45,
            child: SizedBox(
              width: screenWidth * 0.85,
              child: Text(
                S.of(context)!.writescreen3,
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  color: Colors.black,
                  fontFamily: 'Kufam',
                ),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.07,
            top: screenHeight * 0.51,
            child: Container(
              width: screenWidth * 0.85,
              height: screenHeight * 0.30,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FF),
                borderRadius: BorderRadius.circular(0),
              ),
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: TextField(
                controller: _diaryController,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: const Color(0xFF59585D),
                  fontFamily: 'Grey Qo',
                ),
                decoration: InputDecoration.collapsed(
                  hintText: S.of(context)!.writescreen4,
                ),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.07,
            top: screenHeight * 0.85,
            child: GestureDetector(
              onTap: () async {
                if (userEmail == null || _diaryController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.of(context)!.diary_not_found)),
                  );
                  return;
                }
                final success = await _saveDiaryEntry();
                if (success && mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MyDiaryScreen()),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.of(context)!.write4)),
                  );
                }
              },
              child: Container(
                width: screenWidth * 0.85,
                height: screenHeight * 0.07,
                decoration: BoxDecoration(
                  color: const Color(0xFF7A70DD),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  S.of(context)!.write3,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.white,
                    fontFamily: 'Grey Qo',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
