import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'EmotionData.dart';
import 'EmotionDayCard.dart';
import 'package:mood_diary/l10n/app_localizations.dart';

class EmotionCardList extends StatefulWidget {
  final List<EmotionData> emotionDataList;
  final int selectedCardIndex;
  final Function(int, TapDownDetails) onCardTap;

  const EmotionCardList({
    super.key,
    required this.emotionDataList,
    required this.selectedCardIndex,
    required this.onCardTap,
  });

  @override
  State<EmotionCardList> createState() => _EmotionCardListState();
}

class _EmotionCardListState extends State<EmotionCardList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      left: screenWidth * 0.04,
      top: screenHeight * 0.25,
      child: SizedBox(
        width: screenWidth * 0.92,
        child: SingleChildScrollView(
          controller: _scrollController, // ✅ 스크롤 상태 유지
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(widget.emotionDataList.length, (index) {
              final data = widget.emotionDataList[index];
              final date = DateTime.parse(data.date);
              final locale = Localizations.localeOf(context).toString();
              final dayOfWeek = DateFormat.E(locale).format(date);
              final dayOfMonth = DateFormat.d().format(date).padLeft(2, '0');
              final isSelected = widget.selectedCardIndex == index;

              final hasImage = data.imageUrl != null && data.imageUrl.trim().isNotEmpty;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: hasImage
                    ? EmotionDayCard(
                  dayOfWeek: dayOfWeek,
                  dayOfMonth: dayOfMonth,
                  imageAsset: data.imageUrl,
                  isSelected: isSelected,
                  onTap: (Offset globalPosition) {
                    widget.onCardTap(index, TapDownDetails(globalPosition: globalPosition));
                  },
                )
                    : Container(
                  width: screenWidth * 0.16,
                  height: screenWidth * 0.26,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    S.of(context)!.noImage, // "없음" 또는 "No Image"
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black54,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
