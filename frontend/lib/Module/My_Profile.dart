import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mood_diary/Animations/fade_scale_transition.dart';
import 'package:mood_diary/Module/My_Page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:mood_diary/l10n/app_localizations.dart';
import 'package:mood_diary/config.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  String userEmail = '';
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    loadEmail();
  }

  Future<void> loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? '';
    setState(() {
      userEmail = email;
    });
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        String errorText = '';

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _submitPasswordChange() async {
              if (newPasswordController.text != confirmPasswordController.text) {
                setState(() {
                  errorText = S.of(context)!.passwordConfirmMismatch;
                });
                return;
              }

              final prefs = await SharedPreferences.getInstance();
              final email = prefs.getString('user_email');

              final response = await http.post(
                Uri.parse('http://$backendIp:$backendPort/api/users/change-password'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'email': email,
                  'currentPassword': currentPasswordController.text,
                  'newPassword': newPasswordController.text,
                }),
              );

              if (response.statusCode == 200) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.of(context)!.passwordChangeSuccess)),
                );
              } else {
                setState(() {
                  errorText = S.of(context)!.wrongCurrentPassword;
                });
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(S.of(context)!.changePassword),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: currentPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: S.of(context)!.currentPassword),
                    ),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: S.of(context)!.newPassword),
                    ),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: S.of(context)!.confirmPassword),
                    ),
                    if (errorText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          errorText,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.of(context)!.edit3),
                ),
                ElevatedButton(
                  onPressed: _submitPasswordChange,
                  child: Text(S.of(context)!.submit),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final List<Map<String, String>> faqList = [
      {
        'question': S.of(context)!.faqbox1,
        'answer': S.of(context)!.faqanswer1,
      },
      {
        'question': S.of(context)!.faqbox2,
        'answer': S.of(context)!.faqanswer2,
      },
      {
        'question': S.of(context)!.faqbox3,
        'answer': S.of(context)!.faqanswer3,
      },
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Color(0xFF4B4876),
              Color(0xFF4B4876),
              Color(0xFF6862AF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            children: [
              SizedBox(
                height: screenHeight * 0.06,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            createFadeScaleRoute(const MypageScreen()),
                          );
                        },
                        child: SizedBox(
                          width: screenWidth * 0.06,
                          height: screenWidth * 0.06,
                          child: Image.asset(
                            'assets/images/icons/Arrow.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        S.of(context)!.profileTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Kufam',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: screenWidth * 0.13),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.04,
                      horizontal: screenWidth * 0.05,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: screenWidth * 0.08),
                        Text(
                          userEmail.isNotEmpty ? userEmail : 'Loading...',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          S.of(context)!.emailbox1,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Color(0xFF87898A),
                            fontFamily: 'Kufam',
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFE0E0E0)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _showChangePasswordDialog(context),
                          child: Text(
                            S.of(context)!.changePassword,
                            style: TextStyle(
                              fontSize: screenWidth * 0.038,
                              color: const Color(0xFF7A70DD),
                              decoration: TextDecoration.underline,
                              fontFamily: 'Kufam',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: screenWidth * 0.13,
                    backgroundImage: AssetImage('assets/images/Profile_img.png'),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Container(
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context)!.faq,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    ExpansionPanelList.radio(
                      elevation: 0,
                      dividerColor: Colors.transparent,
                      expandedHeaderPadding: EdgeInsets.zero,
                      animationDuration: Duration(milliseconds: 300),
                      children: faqList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        return ExpansionPanelRadio(
                          value: index,
                          headerBuilder: (context, isExpanded) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: screenWidth * 0.08,
                                height: screenWidth * 0.08,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF7A70DD),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                              ),
                              title: Text(
                                item['question']!,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                          body: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                              vertical: screenHeight * 0.01,
                            ),
                            child: Text(
                              item['answer']!,
                              style: TextStyle(
                                fontSize: screenWidth * 0.033,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
