import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mood_diary/Module/Chatbot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/bottom_nav_bar.dart';
import 'package:mood_diary/widgets/EmotionData.dart';
import 'package:mood_diary/widgets/EmotionCardList.dart';
import '../Animations/fade_scale_transition.dart';
import 'DiaryEdit.dart';
import 'My_Page.dart';
import 'DiaryWriteScreen.dart';
import '../config.dart';
import 'package:mood_diary/l10n/app_localizations.dart';


class ActivityApi {
  static Future<Map<String, bool>> fetchActivities(String email) async {
    final uri = Uri.http('$backendIp:$backendPort', '/api/activities/list', {'email': email});
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(decodedBody);
      final Map<String, bool> result = {};
      for (var item in data) {
        String name = item['activityName'];
        bool checked = item['checked'] ?? false;
        result[name] = checked;
      }
      return result;
    } else {
      throw Exception('Failed to load activities: ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> saveActivities(String email, Map<String, bool> activities) async {
    final uri = Uri.http('$backendIp:8081', '/api/activities/save');
    final body = json.encode({'email': email, 'activities': activities});
    final response = await http.post(uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to save activities');
    }
  }

  static Future<void> deleteActivity(String email, String activityName) async {
    final uri = Uri.http('$backendIp:8081', '/api/activities/delete', {
      'email': email,
      'activityName': activityName,
    });
    final response = await http.delete(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete activity');
    }
  }
}

class MyDiaryScreen extends StatefulWidget {
  const MyDiaryScreen({super.key});
  @override
  State<MyDiaryScreen> createState() => _MyDiaryScreenState();
}

class _MyDiaryScreenState extends State<MyDiaryScreen> with SingleTickerProviderStateMixin {
  List<String> activityNames = [];
  Map<String, bool> activityChecked = {};
  List<EmotionData> emotionDataList = [];
  int selectedCardIndex = -1;
  DateTime selectedDate = DateTime.now();
  int _selectedIndex = 1;

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
            createFadeScaleRoute(const DiaryWriteScreen()));
        break;
      case 1:
        Navigator.of(context).pushReplacement(
            createFadeScaleRoute(const MyDiaryScreen()));
        break;
      case 2:
        Navigator.of(context).pushReplacement(createFadeScaleRoute(const ChatbotScreen()));
        break;
      case 3:
        Navigator.of(context).pushReplacement(
            createFadeScaleRoute(const MypageScreen()));
        break;
    }
  }

  late AnimationController _revealController;
  late Animation<double> _revealAnimation;
  Offset _revealCenter = Offset.zero;
  bool _isRevealing = false;

  final GlobalKey _diaryContentKey = GlobalKey();
  double _diaryContentHeight = 0;

  final TextEditingController _newActivityController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String email;
  @override
  void initState() {
    super.initState();
    _initEmailAndLoad();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _revealAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOut),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isRevealing = false;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  Future<void> _initEmailAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString('session_cookie') ?? '';
    final match = RegExp(r'email=([^;]+)').firstMatch(cookie);
    if (match == null) return;
    email = Uri.decodeComponent(match.group(1)!);
    await _reloadDiaryList();
    await _loadActivitiesFromServer();
  }

  Future<void> _loadActivitiesFromServer() async {
    try {
      final serverActivities = await ActivityApi.fetchActivities(email);
      setState(() {
        activityNames = serverActivities.keys.toList();
        activityChecked = Map<String, bool>.from(serverActivities);
      });
    } catch (e) {
      debugPrint('활동 로드 실패: $e');
    }
  }

  Future<void> _saveActivitiesToServer() async {
    try {
      await ActivityApi.saveActivities(email, activityChecked);
    } catch (e) {
      debugPrint('활동 저장 실패: $e');
    }
  }

  void _onActivityChanged(String activity, bool? value) {
    if (value == null) return;
    setState(() {
      activityChecked[activity] = value;
    });
    _saveActivitiesToServer();
  }

  void _addActivity(String newActivity) {
    if (activityNames.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)!.diary7)),
      );
      return;
    }

    if (newActivity.isEmpty || activityNames.contains(newActivity)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)!.diary8)),
      );
      return;
    }

    setState(() {
      activityNames.insert(0, newActivity);
      activityChecked[newActivity] = false;
    });
    _newActivityController.clear();
    _saveActivitiesToServer();
  }

  void _removeActivity(int index) async {
    final removedActivity = activityNames[index];
    try {
      await ActivityApi.deleteActivity(email, removedActivity);
      setState(() {
        activityNames.removeAt(index);
        activityChecked.remove(removedActivity);
      });
      _saveActivitiesToServer();
    } catch (e) {
      debugPrint('삭제 실패: $e');
    }
  }

  Future<void> fetchEmotionData({DateTime? dateToFetch}) async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString('session_cookie');
    if (cookie == null) return;

    final match = RegExp(r'email=([^;]+)').firstMatch(cookie);
    if (match == null) return;

    final emailLocal = Uri.decodeComponent(match.group(1)!);
    final dateStr = (dateToFetch ?? DateTime.now()).toIso8601String().substring(0, 10);

    final queryParameters = {'email': emailLocal, 'date': dateStr};
    final uri = Uri.http('$backendIp:8081', '/api/diaries/emotions/week', queryParameters);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(decodedBody);
        setState(() {
          emotionDataList = jsonData.map((item) => EmotionData.fromJson(item)).toList();
          final selectedIndex = emotionDataList.indexWhere((e) => e.date == dateStr);
          selectedCardIndex = selectedIndex != -1 ? selectedIndex : -1;
        });
      }
    } catch (e) {
      debugPrint('감정 불러오기 실패: $e');
    }
  }

  Future<void> _reloadDiaryList({DateTime? dateToSelect}) async {
    if (dateToSelect != null) selectedDate = dateToSelect;
    await fetchEmotionData(dateToFetch: selectedDate);
  }

  void _onPrevMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, selectedDate.day);
    });
    _reloadDiaryList();
  }

  void _onNextMonth() {
    final now = DateTime.now();
    final nextMonthCandidate = DateTime(selectedDate.year, selectedDate.month + 1, selectedDate.day);
    if (nextMonthCandidate.isAfter(DateTime(now.year, now.month, now.day))) return;
    setState(() {
      selectedDate = nextMonthCandidate;
    });
    _reloadDiaryList();
  }
  @override
  void dispose() {
    _scrollController.dispose();
    _revealController.dispose();
    _newActivityController.dispose();
    super.dispose();
  }

  void _updateDiaryContentHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox = _diaryContentKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final newHeight = renderBox.size.height;
        if (_diaryContentHeight != newHeight) {
          setState(() {
            _diaryContentHeight = newHeight;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final locale = Localizations.localeOf(context).toString();
    final monthDisplay = DateFormat.MMMM(locale).format(selectedDate);
    final bool hasDiary = emotionDataList.isNotEmpty &&
        selectedCardIndex != -1 &&
        emotionDataList[selectedCardIndex].content.trim().isNotEmpty;

    final double baseDiaryTop = screenHeight * 0.5;
    const double marginBelowDiary = 20;
    final double moodTipsTop = baseDiaryTop + _diaryContentHeight + marginBelowDiary;

    _updateDiaryContentHeight();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      bottomNavigationBar: CustomBottomBar(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        selectedIndex: 1,
        onTap: _onNavTap,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          height: screenHeight * 1.2,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(screenWidth * 0.1),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: screenHeight * 0.14,
                child: Container(
                  width: screenWidth,
                  height: screenHeight * 1.85,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.1),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.07,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    S.of(context)!.diarytitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.05,
                      fontFamily: 'Grey Qo',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.18,
                left: 0,
                right: 0,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _onPrevMonth,
                        child: Icon(Icons.chevron_left, color: Color(0xFF87898A), size: screenWidth * 0.07),
                      ),
                      SizedBox(width: screenWidth * 0.1),
                      GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Color(0xFF7A70DD),
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(foregroundColor: Color(0xFF7A70DD)),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            await _reloadDiaryList(dateToSelect: picked);
                          }
                        },
                        child: Text(
                          monthDisplay,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.045,
                            fontFamily: 'Kufam',
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF7A70DD),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.1),
                      GestureDetector(
                        onTap: _onNextMonth,
                        child: Icon(Icons.chevron_right, color: Color(0xFF87898A), size: screenWidth * 0.07),
                      ),
                    ],
                  ),
                ),
              ),
              EmotionCardList(
                key: const ValueKey("emotionCardList"),
                emotionDataList: emotionDataList,
                selectedCardIndex: selectedCardIndex,
                onCardTap: (index, details) {
                  setState(() {
                    _revealCenter = details.localPosition;
                    selectedCardIndex = index;
                    _isRevealing = true;
                  });
                  _revealController.forward(from: 0);
                },
              ),
              Positioned(
                left: screenWidth * 0.07,
                top: screenHeight * 0.43,
                child: SizedBox(
                  width: screenWidth * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context)!.diary1,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.05,
                          fontFamily: 'Grey Qo',
                        ),
                      ),
                      GestureDetector(
                        onTap: hasDiary
                            ? () async {
                          final selectedEntry = emotionDataList[selectedCardIndex];
                          final result = await Navigator.of(context).push(
                            createFadeScaleRoute(DiaryEdit(
                              entry: selectedEntry,
                              emotionDataList: emotionDataList,
                            )),
                          );
                          if (result == true) {
                            await _reloadDiaryList(dateToSelect: DateTime.parse(selectedEntry.date));
                          }
                        }
                            : null,
                        child: Opacity(
                          opacity: hasDiary ? 1.0 : 0.4,
                          child: Image.asset(
                            'assets/images/Edit_icon.png',
                            width: screenWidth * 0.05,
                            height: screenWidth * 0.05,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: screenWidth * 0.07,
                top: baseDiaryTop,
                child: SizedBox(
                  width: screenWidth * 0.85,
                  child: Container(
                    key: _diaryContentKey,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hasDiary ? emotionDataList[selectedCardIndex].content : S.of(context)!.diary2,
                      key: ValueKey(selectedCardIndex),
                      style: TextStyle(
                        color: const Color(0xFF59585D),
                        fontSize: screenWidth * 0.045,
                        fontFamily: 'Grey Qo',
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: screenWidth * 0.07,
                top: moodTipsTop,
                width: screenWidth * 0.85,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context)!.diary3,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.05,
                        fontFamily: 'Kufam',
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (activityNames.isEmpty)
                      Text(
                       S.of(context)!.diary4,
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          activityNames.length.clamp(0, 10), // 최대 10개까지만 렌더링
                              (index) {
                            final activity = activityNames[index];
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                final offsetAnimation = Tween<Offset>(
                                  begin: const Offset(0.0, 0.2),
                                  end: Offset.zero,
                                ).animate(animation);
                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                key: ValueKey(activity), // 중요: 고유 키
                                constraints: const BoxConstraints(maxHeight: 40),
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Transform.scale(
                                      scale: 1.5, // 🔧 원하는 배율 (1.0 = 기본, 1.3 ~ 1.5 추천)
                                      child: Checkbox(
                                        value: activityChecked[activity] ?? false,
                                        activeColor: const Color(0xFF7A70DD),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: const VisualDensity(horizontal: -2, vertical: -4),
                                        onChanged: (bool? newValue) {
                                          _onActivityChanged(activity, newValue);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        activity,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontFamily: 'Kufam',
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _removeActivity(index), // 🔄 서버와 동기화 포함한 삭제 방식
                                      child: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newActivityController,
                            decoration: InputDecoration(
                              hintText: S.of(context)!.diary5,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Color(0xFF7A70DD)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Color(0xFF7A70DD), width: 2),
                              ),
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _addActivity(_newActivityController.text.trim()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7A70DD),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              S.of(context)!.diary6,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
