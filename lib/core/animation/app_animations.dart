import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppAnimations {
  // Animation Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 800);

  // Animation Curves
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.easeOutBack;
  static const Curve smoothCurve = Curves.easeOutQuart;

  /// Global page transition builder for [AnimatedSwitcher]
  static Widget pageTransitionBuilder(Widget child, Animation<double> animation) {
    final curveAnimation = CurvedAnimation(
      parent: animation,
      curve: defaultCurve,
    );

    if (kIsWeb) {
      // Web: Smooth fade + scale for premium feel
      return FadeTransition(
        opacity: curveAnimation,
        child: ScaleTransition(
          scale: curveAnimation.drive(Tween(begin: 0.96, end: 1.0)),
          child: child,
        ),
      );
    } else {
      // Mobile: Slide up + Fade for professional feel
      return FadeTransition(
        opacity: curveAnimation,
        child: SlideTransition(
          position: curveAnimation.drive(Tween(
            begin: const Offset(0.0, 0.05),
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
        (0.08 * index).clamp(0, 1.0),
        (0.08 * index + 0.6).clamp(0, 1.0),
        curve: smoothCurve,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(Tween(
          begin: const Offset(0.0, 0.15),
          end: Offset.zero,
        )),
        child: ScaleTransition(
          scale: animation.drive(Tween(begin: 0.95, end: 1.0)),
          child: child,
        ),
      ),
    );
  }

  /// Smooth scale animation for buttons and interactive elements
  static Widget scaleAnimation({
    required Widget child,
    required AnimationController controller,
    double begin = 0.95,
    double end = 1.0,
  }) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: smoothCurve,
    );
    return ScaleTransition(
      scale: animation.drive(Tween(begin: begin, end: end)),
      child: child,
    );
  }

  /// Pulse animation for loading states
  static Widget pulseAnimation({
    required Widget child,
    required AnimationController controller,
  }) {
    final animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }

  /// Slide in from right animation
  static Widget slideInRight(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: animation.drive(Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Slide in from left animation
  static Widget slideInLeft(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: animation.drive(Tween(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Bounce animation for success states
  static Widget bounceAnimation(Widget child, Animation<double> animation) {
    final curveAnimation = CurvedAnimation(
      parent: animation,
      curve: bounceCurve,
    );
    return ScaleTransition(
      scale: curveAnimation.drive(Tween(begin: 0.0, end: 1.0)),
      child: child,
    );
  }
}
