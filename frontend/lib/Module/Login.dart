import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../RegisterPopup.dart';
import 'Emotion_Picker.dart';
import 'My_Diary.dart';
import '../Animations/fade_scale_transition.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'package:mood_diary/Chatbot/chat_storage.dart';
import 'package:mood_diary/l10n/app_localizations.dart';


void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final bool showLogoutMessage;
  const LoginScreen({super.key, this.showLogoutMessage = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.showLogoutMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            content: Text(
              S.of(context)!.logoutmsg,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).pop();
        });
      });
    }
  }

  Future<void> _handleLogin() async {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text(S.of(context)!.loginmain),
          content: Text(S.of(context)!.logininfo1),
          actions: [
            CupertinoDialogAction(
              child: Text(S.of(context)!.logininfo2),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    final url = Uri.parse('http://$backendIp:8081/api/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        // 세션 쿠키만 추출 (ex: "JSESSIONID=xxxxx")
        final sessionCookie = rawCookie.split(';').first;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_cookie', sessionCookie);
        print('✅ 세션 쿠키 저장 완료: $sessionCookie');
        await ChatStorage.clear();
      } else {
        print('⚠️ set-cookie 헤더가 없습니다.');
      }

      final today = DateTime.now();
      final todayStr = "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final checkUrl = Uri.parse('http://$backendIp:8081/api/diaries/check?email=$email&date=$todayStr');

      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie') ?? '';
      await prefs.setString('user_email', email);

      final checkResponse = await http.get(
        checkUrl,
        headers: {
          'Cookie': sessionCookie,
          'Content-Type': 'application/json',
        },
      );

      if (checkResponse.statusCode == 200) {
        final contentType = checkResponse.headers['content-type'];
        if (contentType != null && contentType.contains('application/json')) {
          final Map<String, dynamic> result = jsonDecode(checkResponse.body);
          final bool exists = result['exists'] as bool;
          if (exists) {
            Navigator.of(context).push(createFadeScaleRoute(const MyDiaryScreen()));
          } else {
            Navigator.of(context).push(createFadeScaleRoute(const EmotionPickerScreen()));
          }
        } else {
          print('⚠️ JSON 응답이 아닙니다: ${checkResponse.body}');
        }
      } else {
        print('❌ 일기 확인 실패: ${checkResponse.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('일기 확인 실패. 다시 시도해주세요.')),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('로그인 실패'),
          content: const Text('이메일 또는 비밀번호가 올바르지 않습니다.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('확인'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF4B4876),
              Color(0xFF4B4876),
              Color(0xFF6862AF),
            ],
          ),
          borderRadius: BorderRadius.circular(screenWidth * 0.1),
        ),
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(0, -0.7),
              child: SizedBox(
                width: screenWidth * 0.6,
                height: screenWidth * 0.6,
                child: Image.asset(
                  'assets/images/mainlogo_empty.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.065,
              top: screenHeight * 0.41,
              child: Container(
                width: screenWidth * 0.85,
                height: screenHeight * 0.08,
                padding: EdgeInsets.only(right: screenWidth * 0.05),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.centerRight,
                child: Image.asset(
                  'assets/images/email_icon.png',
                  width: screenWidth * 0.07,
                  height: screenWidth * 0.07,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.14,
              top: screenHeight * 0.418,
              child: Text(
                S.of(context)!.login1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.045,
                  fontFamily: 'Kufam',
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.15,
              top: screenHeight * 0.448,
              child: SizedBox(
                width: screenWidth * 0.65,
                height: screenHeight * 0.035,
                child: TextField(
                  controller: loginEmailController,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.065,
              top: screenHeight * 0.51,
              child: Container(
                width: screenWidth * 0.85,
                height: screenHeight * 0.08,
                padding: EdgeInsets.only(right: screenWidth * 0.05),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  child: Image.asset(
                    _obscurePassword
                        ? 'assets/images/password_icon_open.png'
                        : 'assets/images/password_icon.png',
                    width: screenWidth * 0.07,
                    height: screenWidth * 0.07,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.14,
              top: screenHeight * 0.518,
              child: Text(
                S.of(context)!.login2,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.045,
                  fontFamily: 'Kufam',
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.15,
              top: screenHeight * 0.548,
              child: SizedBox(
                width: screenWidth * 0.65,
                height: screenHeight * 0.035,
                child: TextField(
                  controller: loginPasswordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.36),
              child: GestureDetector(
                onTap: _handleLogin,
                child: Container(
                  width: screenWidth * 0.85,
                  height: screenHeight * 0.07,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    S.of(context)!.login3,
                    style: TextStyle(
                      color: const Color(0xFF5D5593),
                      fontSize: screenWidth * 0.045,
                      fontFamily: 'Grey Qo',
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(-0.008, 0.48),
              child: Text(
                S.of(context)!.login4,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                  fontFamily: 'Khula',
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    S.of(context)!.login5,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                      fontFamily: 'Khula',
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => RegisterScreen(),
                      );
                    },
                    child: Text(
                      S.of(context)!.login6,
                      style: TextStyle(
                        color: const Color(0xFFD8C0F8),
                        fontSize: screenWidth * 0.04,
                        fontFamily: 'Khula',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
