import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Indigo and Purple gradient
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color primaryPurple = Color(0xFF9333EA);
  
  // Status Colors
  static const Color statusDraft = Color(0xFFF3F4F6);
  static const Color statusDraftText = Color(0xFF374151);
  static const Color statusPublished = Color(0xFFDBEAFE);
  static const Color statusPublishedText = Color(0xFF1D4ED8);
  static const Color statusOngoing = Color(0xFFDCFCE7);
  static const Color statusOngoingText = Color(0xFF15803D);
  static const Color statusCompleted = Color(0xFFF3E8FF);
  static const Color statusCompletedText = Color(0xFF7E22CE);
  
  // Neutral Colors
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  
  // Accent Colors
  static const Color red500 = Color(0xFFEF4444);
  static const Color green600 = Color(0xFF16A34A);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color indigo100 = Color(0xFFE0E7FF);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo700 = Color(0xFF4338CA);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: ColorScheme.light(
        primary: primaryIndigo,
        secondary: primaryPurple,
        surface: Colors.white,
        error: red500,
      ),
      scaffoldBackgroundColor: gray50,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: gray900),
        titleTextStyle: TextStyle(
          color: gray900,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryIndigo,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: gray700,
          side: const BorderSide(color: gray300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryIndigo, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: gray900),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: gray900),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: gray900),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: gray900),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: gray900),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: gray900),
        bodyLarge: TextStyle(fontSize: 16, color: gray700),
        bodyMedium: TextStyle(fontSize: 14, color: gray600),
        bodySmall: TextStyle(fontSize: 12, color: gray500),
      ),
    );
  }
}
