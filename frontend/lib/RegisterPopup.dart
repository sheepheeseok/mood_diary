import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              isDismissible: true,
              enableDrag: true,
              builder: (context) => const RegisterScreen(),
            );
          },
          child: Text(
            'Register',
            style: TextStyle(
              color: const Color(0xFFD8C0F8),
              fontSize: screenWidth * 0.04,
              fontFamily: 'Khula',
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String emailStatus = '';
  bool isEmailDuplicate = false;
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateEmail);
    firstNameController.addListener(_validateForm);
    lastNameController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  Future<void> _validateEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        emailStatus = '';
        isEmailDuplicate = false;
        _validateForm();
      });
      return;
    }

    final url = Uri.parse('http://$backendIp:8081/api/users/check-email?email=$email');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        isEmailDuplicate = result['duplicate'];
        emailStatus = emailController.text.trim().isEmpty
            ? ''
            : (isEmailDuplicate ? '중복된 이메일입니다.' : '사용 가능한 이메일입니다.');
        _validateForm();
      });
    }
  }

  void _validateForm() {
    setState(() {
      isFormValid =
          firstNameController.text.trim().isNotEmpty &&
              lastNameController.text.trim().isNotEmpty &&
              emailController.text.trim().isNotEmpty &&
              passwordController.text.trim().isNotEmpty &&
              !isEmailDuplicate;
    });
  }

  Future<void> registerUser() async {
    if (!isFormValid) {
      showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('입력 필요'),
          content: const Text('모든 정보를 기입해주세요.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('확인'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return; // showDialog 후에 함수 종료
    }

    final body = {
      "firstName": firstNameController.text.trim(),
      "lastName": lastNameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "username": "${lastNameController.text.trim()}${firstNameController.text.trim()}",
    };

    final url = Uri.parse('http://$backendIp:8081/api/users');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ 회원가입 성공");
      Navigator.of(context).pop();
    } else if (response.statusCode == 409) {
      setState(() {
        emailStatus = '이미 존재하는 이메일입니다.';
        isEmailDuplicate = true;
        _validateForm();
      });
    } else {
      print("❌ 회원가입 실패: ${response.statusCode}");
      print(response.body);
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        height: screenHeight * 1,
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {},
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            child: Container(
              width: screenWidth,
              height: screenHeight * 0.87,
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: screenHeight * 0.3,
                    child: Container(
                      width: screenWidth,
                      height: screenHeight * 1.7,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(screenWidth * 0.1),
                      ),
                    ),
                  ),
                  _buildText(context, 'Don\'t have any account?', 0.18, 0.80, 0.45, 0.035, Colors.black, 'Khula', FontWeight.w400, 1.5),
                  Positioned(
                    left: screenWidth * 0.63,
                    top: screenHeight * 0.80,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(); // 팝업 닫기
                      },
                      child: SizedBox(
                        width: screenWidth * 0.15,
                        child: Text(
                          'Sign in',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF7A70DD),
                            fontSize: screenWidth * 0.045,
                            fontFamily: 'Khula',
                            fontWeight: FontWeight.w300,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.067,
                    top: screenHeight * 0.7,
                    child: GestureDetector(
                      onTap: () => registerUser(),
                      child: Container(
                        width: screenWidth * 0.87,
                        height: screenHeight * 0.075,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7A70DD),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '가입하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildText(context, 'First Name', 0.06, 0.33, 0.3, 0.045, Colors.black, 'Kufam', FontWeight.w400, 1.2),
                  _buildContainer(context, 0.067, 0.36, 0.4, 0.06, Colors.white, 70),
                  Positioned(
                    left: screenWidth * 0.067,
                    top: screenHeight * 0.363,
                    child: SizedBox(
                      width: screenWidth * 0.4,
                      height: screenHeight * 0.06,
                      child: TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  _buildText(context, 'Email', 0.067, 0.45, 0.15, 0.045, Colors.black, 'Kufam', FontWeight.w400, 1.2),
                  _buildContainer(context, 0.067, 0.48, 0.87, 0.06, Colors.white, 70),
                  Positioned(
                    left: screenWidth * 0.067,
                    top: screenHeight * 0.485,
                    child: SizedBox(
                      width: screenWidth * 0.87,
                      height: screenHeight * 0.06,
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.22,
                    top: screenHeight * 0.451, // email 입력란(0.485 + 높이 0.06) 아래 위치
                    child: SizedBox(
                      width: screenWidth * 0.87,
                      child: Text(
                        emailStatus,
                        style: TextStyle(
                          color: isEmailDuplicate ? Colors.red : Colors.green,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ),
                  ),
                  _buildText(context, 'Password', 0.067, 0.57, 0.23, 0.045, Colors.black, 'Kufam', FontWeight.w400, 1.2),
                  _buildContainer(context, 0.067, 0.60, 0.87, 0.06, Colors.white, 70),
                  Positioned(
                    left: screenWidth * 0.067,
                    top: screenHeight * 0.602,
                    child: SizedBox(
                      width: screenWidth * 0.87,
                      height: screenHeight * 0.06,
                      child: TextField(
                        controller: passwordController,
                        obscureText: true, // 🔐 비밀번호 마스킹
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  _buildText(context, 'Last Name', 0.45, 0.33, 0.4, 0.045, Colors.black, 'Kufam', FontWeight.w400, 1.2),
                  _buildContainer(context, 0.53, 0.36, 0.4, 0.06, Colors.white, 70),
                  Positioned(
                    left: screenWidth * 0.53,
                    top: screenHeight * 0.363,
                    child: SizedBox(
                      width: screenWidth * 0.4,
                      height: screenHeight * 0.06,
                      child: TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.067,
                    top: screenHeight * 0.87,
                    child: Container(
                      width: screenWidth * 0.87,
                      height: 1,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Positioned(
                    left: screenWidth * 0.067,
                    top: screenHeight * 0.9,
                    child: Container(
                      width: screenWidth * 0.87,
                      height: screenHeight * 0.07,
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: const Color(0xFF7A70DD), width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/apple_logo.png',
                            width: screenWidth * 0.06,
                            height: screenWidth * 0.06,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          const Text(
                            'Apple ID 로그인',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context, String text, double left, double top, double width, double fontSize, Color color, String fontFamily, FontWeight weight, double height) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Positioned(
      left: screenWidth * left,
      top: screenHeight * top,
      child: SizedBox(
        width: screenWidth * width,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: screenWidth * fontSize,
            fontFamily: fontFamily,
            fontWeight: weight,
            height: height,
          ),
        ),
      ),
    );
  }

  Widget _buildContainer(BuildContext context, double left, double top, double width, double height, Color color, double radius) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Positioned(
      left: screenWidth * left,
      top: screenHeight * top,
      child: Container(
        width: screenWidth * width,
        height: screenHeight * height,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: const Color(0xFFD8C0F8), width: 1),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

