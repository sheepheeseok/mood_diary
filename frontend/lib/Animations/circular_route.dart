import 'package:flutter/material.dart';

void navigateWithCircularReveal({
  required BuildContext context,
  required Widget targetScreen,
  required Offset center,
  Duration duration = const Duration(milliseconds: 1200),
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: true, // 반드시 true여야 애니메이션 뚜렷하게 보임
      transitionDuration: duration,
      pageBuilder: (_, __, ___) => CircleRevealTransition(
        targetScreen: targetScreen,
        center: center,
        duration: duration,
      ),
    ),
  );
}

class CircleRevealTransition extends StatefulWidget {
  final Widget targetScreen;
  final Offset center;
  final Duration duration;

  const CircleRevealTransition({
    super.key,
    required this.targetScreen,
    required this.center,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<CircleRevealTransition> createState() => _CircleRevealTransitionState();
}

class _CircleRevealTransitionState extends State<CircleRevealTransition> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc),
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black, // 배경 있어야 애니메이션 확실히 보임
      body: AnimatedBuilder(
        animation: _animation,
        builder: (_, __) {
          final radius = size.longestSide * 1.2 * _animation.value;
          return ClipPath(
            clipper: CircleRevealClipper(widget.center, radius),
            child: widget.targetScreen,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CircleRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  CircleRevealClipper(this.center, this.radius);

  @override
  Path getClip(Size size) =>
      Path()..addOval(Rect.fromCircle(center: center, radius: radius));

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) =>
      radius != oldClipper.radius || center != oldClipper.center;
}
