import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final int selectedIndex;
  final void Function(int index)? onTap;

  const CustomBottomBar({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.selectedIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icons = [
      'assets/images/Smile.png',
      'assets/images/calender.png',
      'assets/images/Chatbot.png',
      'assets/images/User.png',
    ];

    return Container(
      width: screenWidth * 0.85,
      height: screenHeight * 0.07,
      margin: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: screenHeight * 0.08,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.15 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(icons.length, (index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              if (onTap != null) onTap!(index); // 외부 전달
            },
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isSelected ? Colors.white : Colors.grey.shade600,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                icons[index],
                width: screenWidth * 0.06,
                height: screenWidth * 0.06,
                fit: BoxFit.contain,
              ),
            ),
          );
        }),
      ),
    );
  }
}
