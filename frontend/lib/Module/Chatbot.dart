import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_diary/Animations/fade_scale_transition.dart';
import 'package:mood_diary/Module/DiaryWriteScreen.dart';
import 'package:mood_diary/Module/My_Diary.dart';
import 'package:mood_diary/Module/My_Page.dart';
import 'package:mood_diary/widgets/bottom_nav_bar.dart';
import 'package:mood_diary/Chatbot/input_box.dart';
import 'package:mood_diary/Chatbot/message_bubble.dart';
import 'package:mood_diary/Chatbot/chat_message.dart';
import 'package:mood_diary/Chatbot/chat_api.dart';
import 'package:mood_diary/Chatbot/chat_storage.dart';
import 'package:mood_diary/l10n/app_localizations.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  String userEmail = '';
  bool _isLoading = false;
  int _selectedIndex = 2;

  final Map<String, String> emotionAdviceMap = {
    'cheerful': '이 기분을 잘 유지하면서 주변 사람들과 좋은 시간을 보내보세요!',
    'sad': '지금 감정을 충분히 느끼되, 가까운 사람과 대화를 나눠보는 것도 좋아요.',
    'angry': '숨을 깊게 쉬고 잠시 산책해보는 건 어떨까요? 감정은 잠시 머물다 가는 손님이에요.',
    'confident': '자신감 있는 지금 모습 너무 보기 좋아요! 유지하도록 해요!',
    'love': '사랑스러운 마음을 모두에게 나눌 수 있는 모습을 보여주세요!',
    'relaxed': '진정된 이 마음을 유지하며 모든 일들을 잘 해쳐나갈 수 있도록 해요!',
    'cry': '마음껏 울어도 괜찮아요. 눈물은 감정을 정화하는 힘이 있어요.',
    'serene': '평온함은 큰 힘이 됩니다. 이 마음으로 일상을 조화롭게 채워보세요.',
    'surprised': '예상치 못한 일이 생겼나요? 열린 마음으로 받아들이면 좋은 기회가 될 수 있어요.',
    'tired': '휴식이 필요해 보여요. 잠시 쉬면서 스스로를 돌보는 시간을 가져보세요.',
    'neutral': '특별한 감정이 없을 때도 있어요. 오늘 하루를 가볍게 흘려보는 것도 좋아요.',
  };

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _restoreChat();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('user_email') ?? '';
    });
  }

  Future<void> _restoreChat() async {
    final restored = await ChatStorage.load();
    if (mounted) {
      setState(() {
        _messages.clear();
        _messages.addAll(restored);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage() async {
    if (_isLoading || userEmail.isEmpty) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _messages.add(ChatMessage(
        text: text,
        isMe: true,
        timestamp: DateTime.now(),
      ));
      _messages.add(ChatMessage(
        text: '...',
        isMe: false,
        timestamp: DateTime.now(),
      ));
    });

    _controller.clear();
    _scrollToBottom();

    try {
      if (text.contains("감정 분석")) {
        final summary = await fetchEmotionSummary(userEmail); // 감정 횟수
        final imageMap = await fetchEmotionImageMap(userEmail); // 감정별 이미지 경로

        final summaryText = summary.entries.map((e) => '${e.key}: ${e.value}회').join('\n');

        final topEmotion = summary.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        final advice = emotionAdviceMap[topEmotion] ?? '당신의 감정을 잘 이해했어요.';

        setState(() {
          _messages.removeLast();
          _messages.add(ChatMessage(
            text: '🧠 감정 분석 결과야!\n\n$summaryText',
            isMe: false,
            timestamp: DateTime.now(),
          ));
          _messages.add(ChatMessage(
            text: '[그래프 보기]',
            isMe: false,
            timestamp: DateTime.now(),
            isGraph: true, // 이 필드를 모델에 추가해서 그래프 위젯이 렌더링되도록 처리
            graphData: summary,
            graphImageMap: imageMap,
          ));
          _messages.add(ChatMessage(
            text: '📌 대체적으로 *$topEmotion*한 편이신 것 같아요.\n\n💡 $advice',
            isMe: false,
            timestamp: DateTime.now(),
          ));
        });
      } else {
        final botReply = await askChatbot(userEmail, text);
        final isError = botReply.startsWith('서버 오류');

        setState(() {
          _messages.removeLast();
          _messages.add(ChatMessage(
            text: isError ? '죄송해요, 답변을 가져오는 중 문제가 발생했어요.' : botReply,
            isMe: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(
          text: '알 수 없는 오류가 발생했어요.',
          isMe: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      await ChatStorage.save(_messages);
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }


  @override
  Widget build(BuildContext context) {
    final List<String> _suggestedPrompts = [
      S.of(context)!.suggested1,
      S.of(context)!.suggested2,
      S.of(context)!.suggested3,
      S.of(context)!.suggested4,
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      bottomNavigationBar: CustomBottomBar(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        selectedIndex: 2,
        onTap: _onNavTap,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: screenHeight * 0.17,
              child: Container(
                width: screenWidth * 0.866,
                height: screenHeight * 0.66,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.04,
                          left: screenWidth * 0.04,
                          right: screenHeight * 0.04,
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.only(
                            top: screenHeight * 0.06,
                            bottom: screenHeight * 0.02,
                            left: screenWidth * 0.04,
                            right: screenWidth * 0,
                          ),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return MessageBubble(
                              message: _messages[index],
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.01,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _suggestedPrompts.map((prompt) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7A70DD),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                onPressed: () {
                                  _controller.text = prompt;
                                  _handleSendMessage();
                                },
                                child: Text(prompt, style: const TextStyle(fontSize: 13)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      color: Colors.grey.shade300,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.015,
                      ),
                      child: InputBox(
                        controller: _controller,
                        onSend: _handleSendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.17,
              child: Container(
                width: screenWidth * 0.866,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF7A70DD),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.05,
              right: screenWidth * 0.05,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        S.of(context)!.chatbot1,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Kufam',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        S.of(context)!.chatbot2,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontFamily: 'Kufam',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  CircleAvatar(
                    radius: screenWidth * 0.1,
                    backgroundImage: const AssetImage('assets/images/Mainchatbot.png'),
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
