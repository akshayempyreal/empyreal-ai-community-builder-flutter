import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class DashboardEntryAnimation extends StatefulWidget {
  final Widget child;

  const DashboardEntryAnimation({
    super.key,
    required this.child,
  });

  @override
  State<DashboardEntryAnimation> createState() => _DashboardEntryAnimationState();
}

class _DashboardEntryAnimationState extends State<DashboardEntryAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Platform-specific slide logic
    if (kIsWeb) {
      // WEB: Slide from right to center + Subtle scaling
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0.05, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));

      _scaleAnimation = Tween<double>(
        begin: 0.99,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
    } else {
      // MOBILE: Slide from bottom to center
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0.0, 0.05),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      
      _scaleAnimation = const AlwaysStoppedAnimation(1.0);
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
