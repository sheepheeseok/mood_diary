import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/emotion_card.dart';
import 'My_Diary.dart';
import 'package:intl/intl.dart';
import '../config.dart';
import 'package:mood_diary/l10n/app_localizations.dart';

class EmotionPickerScreen extends StatefulWidget {
  const EmotionPickerScreen({super.key});

  @override
  State<EmotionPickerScreen> createState() => _EmotionPickerScreenState();
}

class _EmotionPickerScreenState extends State<EmotionPickerScreen> {
  String username = '사용자명';
  String selectedEmotion = 'cheerful';
  late String todayDate;
  late String displayDate;
  final TextEditingController _diaryController = TextEditingController();
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUsernameFromCookie();

    final now = DateTime.now();
    todayDate = DateFormat('yyyy-MM-dd').format(now);
    displayDate = DateFormat('MMMM d', 'en_US').format(now);
  }

  Future<void> _loadUsernameFromCookie() async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString('session_cookie');

    if (cookie != null) {
      final usernameMatch = RegExp(r'username=([^;]+)').firstMatch(cookie);
      final emailMatch = RegExp(r'email=([^;]+)').firstMatch(cookie);
      if (usernameMatch != null) {
        final encoded = usernameMatch.group(1)!;
        final decoded = Uri.decodeComponent(encoded);
        setState(() {
          username = decoded;
        });
      }
      if (emailMatch != null) {
        final encodedEmail = emailMatch.group(1)!;
        final decodedEmail = Uri.decodeComponent(encodedEmail);
        userEmail = decodedEmail;
      }
    }
  }

  Future<void> _submitDiaryEntry() async {
    final content = _diaryController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)!.write4)),
      );
      return;
    }

    final uri = Uri.parse('http://$backendIp:8081/api/diaries');
    final diaryData = {
      "user": {"email": userEmail},
      'content': content,
      'emotion': selectedEmotion,
      'date': todayDate,
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(diaryData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.of(context).push(_createFadeScaleRoute());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 실패. 다시 시도하세요.')),
      );
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

  List<Widget> _buildEmotionCards(BuildContext context) {
    final emotions = [
      'cheerful', 'relaxed', 'neutral', 'confident', 'angry',
      'tired', 'sad', 'cry', 'serene', 'surprised', 'love',
    ];

    return emotions.map((e) => Row(
      children: [
        EmotionCard(
          label: getEmotionLabel(e),    // 화면에 표시할 한글
          assetPath: 'assets/images/emotions/$e.png',
          isSelected: selectedEmotion == e,   // key 비교
          onSelected: (_, __) {
            setState(() => selectedEmotion = e);  // key 저장
          },
        ),
        const SizedBox(width: 12),
      ],
    )).toList();
  }

  Route _createFadeScaleRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) => const MyDiaryScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        );
        final scale = Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            child: child,
          ),
        );
      },
    );
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
              onTap: () => Navigator.of(context).push(_createFadeScaleRoute()),
              child: Text(
                S.of(context)!.write1,
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
            left: screenWidth * 0.28,
            top: screenHeight * 0.10,
            child: SizedBox(
              width: screenWidth * 0.45,
              child: Text(
                'Today - $displayDate',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF87898A),
                  fontSize: screenWidth * 0.05,
                  fontFamily: 'Kufam',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.07,
            top: screenHeight * 0.19,
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
                      text: S.of(context)!.write2,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.05,
                        fontFamily: 'Kufam',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.07,
            top: screenHeight * 0.28,
            child: SizedBox(
              width: screenWidth * 0.86,
              height: screenWidth * 0.33,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _buildEmotionCards(context),
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
              onTap: _submitDiaryEntry,
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
