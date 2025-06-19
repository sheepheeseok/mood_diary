import 'package:flutter/material.dart';

class EmotionCard extends StatefulWidget {
  final String label;
  final String assetPath;
  final bool isSelected;
  final Function(String, Offset) onSelected;

  const EmotionCard({
    super.key,
    required this.label,
    required this.assetPath,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<EmotionCard> createState() => _EmotionCardState();
}

class _EmotionCardState extends State<EmotionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radius;
  Offset _center = Offset.zero;
  bool _animating = false;
  bool _tapped = false;

  double _cardWidth = 0;
  double _cardHeight = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _radius = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // 초기 선택된 카드가 있으면 애니메이션 트리거
    if (widget.isSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final center = Offset(_cardWidth / 2, _cardHeight / 2);
        _triggerAnimation(center);
      });
    }
  }

  @override
  void didUpdateWidget(covariant EmotionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        final center = Offset(_cardWidth / 2, _cardHeight / 2);
        _triggerAnimation(center);
      } else {
        setState(() {
          _tapped = false;
          _animating = false;
        });
        _controller.reset();
      }
    }
  }

  void _triggerAnimation(Offset center) {
    setState(() {
      _center = center;
      _animating = true;
      _tapped = true;
    });
    _controller.forward(from: 0).whenComplete(() {
      if (mounted) {
        setState(() => _animating = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    _cardWidth = screenWidth * 0.29;
    _cardHeight = screenWidth * 0.33;

    final Color selectedColor = const Color(0xFF7A70DD);
    final Color unselectedColor = const Color(0xFFF7F5FF);
    final bool isVisible = widget.isSelected || _animating;

    final Color textColor = (widget.isSelected && _tapped)
        ? Colors.white
        : const Color(0xFF87898A);

    return GestureDetector(
      onTapDown: (details) {
        _triggerAnimation(details.localPosition);
        widget.onSelected(widget.label, details.globalPosition);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              width: _cardWidth,
              height: _cardHeight,
              color: isVisible ? selectedColor : unselectedColor,
            ),
            if (isVisible)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _radius,
                  builder: (_, __) {
                    return ClipOval(
                      clipper: _CircularClipper(
                        center: _center,
                        radiusPercent: _radius.value,
                      ),
                      child: Container(
                        color: selectedColor,
                      ),
                    );
                  },
                ),
              ),
            Container(
              width: _cardWidth,
              height: _cardHeight,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    widget.assetPath,
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.15,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: screenWidth * 0.045,
                      fontFamily: 'Kufam',
                    ),
                  ),
                ],
              ),
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

class _CircularClipper extends CustomClipper<Rect> {
  final Offset center;
  final double radiusPercent;

  _CircularClipper({required this.center, required this.radiusPercent});

  @override
  Rect getClip(Size size) {
    final maxRadius = size.longestSide * 0.9;
    return Rect.fromCircle(center: center, radius: maxRadius * radiusPercent);
  }

  @override
  bool shouldReclip(covariant _CircularClipper oldClipper) {
    return radiusPercent != oldClipper.radiusPercent || center != oldClipper.center;
  }
}
