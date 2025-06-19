import 'package:flutter/material.dart';
import 'package:mood_diary/l10n/app_localizations.dart';

class InputBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const InputBox({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(60),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration.collapsed(
                hintText: S.of(context)!.inputbox,
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 12),
          Image.asset(
            'assets/images/icons/Upload.png',
            width: screenWidth * 0.055,
            height: screenWidth * 0.055,
          ),
          const SizedBox(width: 12),

          GestureDetector(
            onTap: onSend,
            child: Image.asset(
              'assets/images/icons/Send.png',
              width: screenWidth * 0.09,
              height: screenWidth * 0.09,
            ),
          ),
        ],
      ),
    );
  }
}
