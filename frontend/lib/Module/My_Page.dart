import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:mood_diary/Animations/fade_scale_transition.dart';
import 'package:mood_diary/Chatbot/chat_storage.dart';
import 'package:mood_diary/Module/Chatbot.dart';
import 'package:mood_diary/Module/Login.dart';
import 'package:mood_diary/Module/My_Profile.dart';
import 'package:mood_diary/config.dart';
import '../widgets/bottom_nav_bar.dart';
import 'My_Diary.dart';
import 'DiaryWriteScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_diary/l10n/app_localizations.dart';
import 'package:mood_diary/main.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  int _selectedIndex = 3;
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? '';
    setState(() {
      userEmail = email;
    });
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(createFadeScaleRoute(const DiaryWriteScreen()));
        break;
      case 1:
        Navigator.of(context).pushReplacement(createFadeScaleRoute(const MyDiaryScreen()));
        break;
      case 2:
        Navigator.of(context).pushReplacement(createFadeScaleRoute(const ChatbotScreen()));
        break;
      case 3:
        Navigator.of(context).pushReplacement(createFadeScaleRoute(const MypageScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      bottomNavigationBar: CustomBottomBar(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        selectedIndex: 3,
        onTap: _onNavTap,
      ),
      body: Container(
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
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.0001,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.01),
                      child: Center(
                        child: Text(
                          S.of(context)!.settingTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.065,
                        vertical: screenHeight * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: screenWidth * 0.06,
                            backgroundImage: AssetImage('assets/images/Profile_img.png'),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Oliva',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  userEmail.isNotEmpty ? userEmail : 'Loading...',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  createFadeScaleRoute(const MyProfileScreen()),
                                );
                              },
                              child: Image.asset(
                                'assets/images/icons/Edit.png',
                                width: screenWidth * 0.06,
                                height: screenWidth * 0.06,
                                fit: BoxFit.contain,
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    _buildSettingGroup(context, [
                      _buildTile(context, 'assets/images/icons/Security.png', S.of(context)!.security),
                      _buildTile(context, 'assets/images/icons/Language.png', S.of(context)!.language, S.of(context)!.languageChange),
                      _buildTile(context, 'assets/images/icons/Notification.png', S.of(context)!.notifications),
                    ]),
                    SizedBox(height: screenHeight * 0.03),
                    _buildSettingGroup(context, [
                      _buildTile(context, 'assets/images/icons/ContactUs.png', S.of(context)!.contactUs),
                      _buildTile(context, 'assets/images/icons/GetHelp.png', S.of(context)!.getHelp),
                      _buildTile(context, 'assets/images/icons/Terms.png', S.of(context)!.termsConditions),
                      _buildTile(context, 'assets/images/icons/Format.png', S.of(context)!.formatMyDiary),
                      _buildTile(context, 'assets/images/icons/Logout.png', S.of(context)!.logout),
                    ]),
                    SizedBox(height: screenHeight * 0.15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingGroup(BuildContext context, List<Widget> tiles) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.010),
        child: Column(children: tiles),
      ),
    );
  }

  Widget _buildTile(BuildContext context, String imagePath, String title, [String? subtitle]) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
      leading: SizedBox(
        width: screenWidth * 0.06,
        height: screenWidth * 0.06,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: screenWidth * 0.035),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: TextStyle(fontSize: screenWidth * 0.025),
      )
          : null,
      trailing: Icon(Icons.arrow_forward_ios, size: screenWidth * 0.04),
      onTap: () async {
        if (title == S.of(context)!.language) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("언어 선택"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text("🇰🇷 한국어"),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('language_code', 'ko');
                      MyApp.setLocale(context, const Locale('ko'));
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text("🇺🇸 English"),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('language_code', 'en');
                      MyApp.setLocale(context, const Locale('en'));
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
          return;
        }

        if (title == S.of(context)!.termsConditions) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context)!.terms1,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 22, color: Colors.black54),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero, // 버튼 자체 간격 최소화
                            constraints: const BoxConstraints(), // 크기 최소화
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 16, thickness: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Text(
                        S.of(context)!.terms2,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
          return;
        }

        if (title == S.of(context)!.getHelp) {
          final TextEditingController _issueController = TextEditingController();

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text(S.of(context)!.report1),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      S.of(context)!.report2,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _issueController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: S.of(context)!.report3,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(S.of(context)!.edit3, style: TextStyle(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () {
                      final issueText = _issueController.text.trim();

                      if (issueText.isNotEmpty) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(S.of(context)!.report4)), // "문제 신고가 접수되었습니다"
                        );
                      } else {
                        // 팝업을 닫지 않음
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(S.of(context)!.write4)), // "내용을 입력해주세요"
                        );
                      }
                    },
                    child: Text(S.of(context)!.report5, style: TextStyle(color: Color(0xFF7A70DD))),
                  ),
                ],
              );
            },
          );
          return;
        }

        if (title == S.of(context)!.contactUs) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(S.of(context)!.contact1),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context)!.contact2,
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // 실제 앱에서는 URL launcher 사용 가능
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S.of(context)!.contact3)),
                    );
                  },
                  child: Text(S.of(context)!.contact4, style: TextStyle(color: Color(0xFF7A70DD))),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.of(context)!.contact5, style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          );
          return;
        }

        if (title == S.of(context)!.formatMyDiary) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(S.of(context)!.delete1),
              content: Text(S.of(context)!.delete2),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.of(context)!.edit3, style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context); // 팝업 닫기

                    final email = userEmail;
                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.of(context)!.diary_not_found)),
                      );
                      return;
                    }

                    final uri = Uri.http('$backendIp:$backendPort', '/api/diaries/delete-all', {
                      'email': email,
                    });

                    try {
                      final response = await http.delete(uri);
                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(S.of(context)!.delete3)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${S.of(context)!.delete4} (${response.statusCode})')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.of(context)!.delete5)),
                      );
                    }
                  },
                  child: Text(S.of(context)!.delete6, style: TextStyle(color: Color(0xFF7A70DD))),
                ),
              ],
            ),
          );
          return;
        }

        if (title == S.of(context)!.notifications) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(S.of(context)!.alert1),
              content: Text(S.of(context)!.alert2),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(S.of(context)!.alert3),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(
                    S.of(context)!.alert4,
                    style: TextStyle(color: Color(0xFF7A70DD)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(S.of(context)!.alert6),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(
                    S.of(context)!.alert5,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
          return;
        }

        if (title == S.of(context)!.security) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상단 제목 + 닫기 버튼
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context)!.privacy1,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 22, color: Colors.black54),
                              onPressed: () => Navigator.of(context).pop(),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 16, thickness: 1),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                          child: Text(
                            S.of(context)!.privacy2,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          return;
        }

        if (title == S.of(context)!.logout) {
          final shouldLogout = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Colors.white,
                title: Text(
                  '로그아웃 하시겠습니까?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                actionsAlignment: MainAxisAlignment.spaceEvenly,
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      '아니요',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      '예',
                      style: TextStyle(
                        color: Color(0xFF7A70DD),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            },
          );

          if (shouldLogout == true) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();

            await ChatStorage.clear();

            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen(showLogoutMessage: true)),
                  (Route<dynamic> route) => false,
            );
          }
        }
      },
    );
  }
}
