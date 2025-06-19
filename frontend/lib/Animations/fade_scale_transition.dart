// lib/routes/fade_scale_transition.dart
import 'package:flutter/material.dart';

Route createFadeScaleRoute(Widget targetScreen, {Duration duration = const Duration(milliseconds: 600)}) {
  return PageRouteBuilder(
    transitionDuration: duration,
    pageBuilder: (_, __, ___) => targetScreen,
    transitionsBuilder: (context, animation, secondary, child) {
      final fade = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      );
      final scale = Tween(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
      );
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(
          scale: scale,
          child: child,
        ),
      );
    },
  );
}
