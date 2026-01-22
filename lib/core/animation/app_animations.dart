import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  /// Global page transition builder for [AnimatedSwitcher]
  static Widget pageTransitionBuilder(Widget child, Animation<double> animation) {
     final curveAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    );

    if (kIsWeb) {
      // Web: Subtle fade + minor scale for premium feel
      return FadeTransition(
        opacity: curveAnimation,
        child: ScaleTransition(
          scale: curveAnimation.drive(Tween(begin: 0.98, end: 1.0)),
          child: child,
        ),
      );
    } else {
      // Mobile: Slide up + Fade for professional mental model
      return FadeTransition(
        opacity: curveAnimation,
        child: SlideTransition(
          position: curveAnimation.drive(Tween(
            begin: const Offset(0.0, 0.03),
            end: Offset.zero,
          )),
          child: child,
        ),
      );
    }
  }

  /// Staggered entrance animation for list items
  static Widget staggeredEntrance(Widget child, int index, AnimationController controller) {
    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        (0.1 * index).clamp(0, 1.0),
        (0.1 * index + 0.5).clamp(0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(Tween(
          begin: const Offset(0.0, 0.1),
          end: Offset.zero,
        )),
        child: child,
      ),
    );
  }
}
