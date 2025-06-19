// EmotionDayCard.dart - 가운데 중심 원형 애니메이션 (박스 전체 칠하기), 고정 크기, 정렬 및 간격 개선
import 'package:flutter/material.dart';

class EmotionDayCard extends StatefulWidget {
  final String dayOfWeek;
  final String dayOfMonth;
  final String imageAsset;
  final bool isSelected;
  final Function(Offset) onTap;

  const EmotionDayCard({
    super.key,
    required this.dayOfWeek,
    required this.dayOfMonth,
    required this.imageAsset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<EmotionDayCard> createState() => _EmotionDayCardState();
}

class _EmotionDayCardState extends State<EmotionDayCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Offset _center = Offset.zero;
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isSelected) {
        _startReveal();
      }
    });
  }

  void _startReveal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;
      setState(() {
        _center = size.center(Offset.zero);
        _animating = true;
      });
      _controller.forward(from: 0).whenComplete(() => setState(() => _animating = false));
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardWidth = screenWidth * 0.22;
    final cardHeight = screenHeight * 0.14;

    return GestureDetector(
      onTap: () {
        _startReveal();
        widget.onTap(_center);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
        width: cardWidth,
        height: cardHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FF),
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
              ),
            ),
            if (widget.isSelected || _animating)
              ClipRRect(
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (_, __) {
                    return CustomPaint(
                      painter: _RevealPainter(
                        center: _center,
                        fraction: _animation.value,
                        color: const Color(0xFF7A70DD),
                        maxRadius: cardWidth * 0.9, // ✅ 카드 내부 범위로 제한
                      ),
                      child: Container(width: cardWidth, height: cardHeight),
                    );
                  },
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.015),
                  child: Column(
                    children: [
                      Text(
                        widget.dayOfWeek,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: widget.isSelected ? Colors.white : const Color(0xFF87898A),
                          fontSize: screenWidth * 0.035,
                          fontFamily: 'Kufam',
                        ),
                      ),
                      Text(
                        widget.dayOfMonth,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: widget.isSelected ? Colors.white : Colors.black,
                          fontSize: screenWidth * 0.06,
                          fontFamily: 'Kufam',
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                  child: SizedBox(
                    width: screenWidth * 0.10,
                    height: screenWidth * 0.10,
                    child: Image.asset(
                      widget.imageAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _RevealPainter extends CustomPainter {
  final Offset center;
  final double fraction;
  final Color color;
  final double maxRadius;

  _RevealPainter({required this.center, required this.fraction, required this.color, required this.maxRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final radius = maxRadius * fraction;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RevealPainter oldDelegate) {
    return oldDelegate.fraction != fraction || oldDelegate.center != center || oldDelegate.maxRadius != maxRadius;
  }
}