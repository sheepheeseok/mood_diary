import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Module/Login.dart';
import 'Animations/fade_scale_transition.dart';
import 'package:mood_diary/l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) async {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode); // 언어 저장
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale(); // 앱 시작 시 저장된 언어 불러오기
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? langCode = prefs.getString('language_code');
    if (langCode != null) {
      setState(() {
        _locale = Locale(langCode);
      });
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: S.supportedLocales,
      localizationsDelegates: S.localizationsDelegates,
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF4B4876),
              Color(0xFF4B4876),
              Color(0xFF6862AF),
            ],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _buildEmotionCard(
              context,
              imagePath: 'assets/images/sad.png',
              left: screenWidth * -0.07,
              top: screenHeight * 0.20,
              rotate: 0,
              opacity: 1.0,
              widthRatio: 0.46,
            ),
            _buildEmotionCard(
              context,
              imagePath: 'assets/images/angry.png',
              left: screenWidth * 0.60,
              top: screenHeight * 0.20,
              rotate: 0,
              opacity: 1.0,
              widthRatio: 0.46,
            ),
            _buildEmotionCard(
              context,
              imagePath: 'assets/images/happy.png',
              left: screenWidth * 0.27,
              top: screenHeight * 0.12,
              rotate: 0,
              opacity: 1.0,
              widthRatio: 0.46,
            ),
            Positioned(
              left: screenWidth * 0.07,
              top: screenHeight * 0.47,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'mood\n',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.20,
                        fontWeight: FontWeight.w700,
                        height: 0.8,
                      ),
                    ),
                    TextSpan(
                      text: 'diary',
                      style: TextStyle(
                        color: Color(0xFFBCB8E2),
                        fontSize: screenWidth * 0.20,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.07,
              top: screenHeight * 0.70,
              child: SizedBox(
                width: screenWidth * 0.86,
                child: Text(
                  S.of(context)!.start2,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.07,
              top: screenHeight * 0.85,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    createFadeScaleRoute(const LoginScreen()),
                  );
                },
                child: Container(
                  width: screenWidth * 0.85,
                  height: screenHeight * 0.07,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    S.of(context)!.start,
                    style: TextStyle(
                      color: Color(0xFF5D5593),
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionCard(
      BuildContext context, {
        required String imagePath,
        required double left,
        required double top,
        required double rotate,
        required double opacity,
        required double widthRatio,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: rotate,
        child: Opacity(
          opacity: opacity,
          child: SizedBox(
            width: screenWidth * widthRatio,
            child: Image.asset(imagePath),
          ),
        ),
      ),
    );
  }
}
