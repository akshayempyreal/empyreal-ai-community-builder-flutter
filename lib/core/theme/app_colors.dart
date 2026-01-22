import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Professional Modern Theme (Deep Blue with Teal Accent)
  static const Color primary = Color(0xFF0F4C75); // Deep Professional Blue
  static const Color primaryDark = Color(0xFF0A3A5C); // Darker Blue
  static const Color primaryLight = Color(0xFF1A6BA3); // Lighter Blue
  static const Color secondary = Color(0xFF14B8A6); // Modern Teal
  static const Color secondaryDark = Color(0xFF0D9488); // Darker Teal
  static const Color accent = Color(0xFF06B6D4); // Cyan Accent
  static const Color accentLight = Color(0xFF22D3EE); // Light Cyan

  // Neutral - Slate Palette (Premium feel)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // Functional Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Light Theme Specifics
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0);

  // Dark Theme Specifics
  static const Color bgDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);

  // Status Badge Colors (Professional & Modern)
  static const Color statusDraft = Color(0xFFF1F5F9);
  static const Color statusDraftText = Color(0xFF475569);
  static const Color statusPublished = Color(0xFFE0F2FE); // Cyan 50
  static const Color statusPublishedText = Color(0xFF0F4C75); // Primary Blue
  static const Color statusOngoing = Color(0xFFCCFBF1); // Teal 100
  static const Color statusOngoingText = Color(0xFF0D9488); // Teal 700
  static const Color statusCompleted = Color(0xFFD1FAE5); // Emerald 100
  static const Color statusCompletedText = Color(0xFF059669); // Emerald 700

  // Aliases for compatibility
  static const Color primaryIndigo = primary;
  static const Color primaryPurple = secondary;
  static const Color indigo100 = Color(0xFFE0E7FF);
  static const Color gray50 = slate50;
  static const Color gray100 = slate100;
  static const Color gray200 = slate200;
  static const Color gray300 = slate300;
  static const Color gray400 = slate400;
  static const Color gray500 = slate500;
  static const Color gray600 = slate600;
  static const Color gray700 = slate700;
  static const Color gray800 = slate800;
  static const Color gray900 = slate900;

  // Dark mode specialized aliases
  static const Color darkText = slate50;
  static const Color darkBorder = borderDark;
}
