import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color darkBackground = Color(0xFF0D0F12);
  static const Color darkSurface = Color(0xFF161A22);
  static const Color darkCardSurface = Color(0xFF1E2430);
  static const Color darkBorder = Color(0xFF2E3646);

  static const Color lightBackground = Color(0xFFF6F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardSurface = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Accents
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color emeraldGreenDark = Color(0xFF059669);
  static const Color electricViolet = Color(0xFF6366F1);
  static const Color amberGold = Color(0xFFF59E0B);
  static const Color skyBlue = Color(0xFF0EA5E9);
  static const Color coralRed = Color(0xFFEF4444);

  // Text colors
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: electricViolet,
        secondary: emeraldGreen,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        outline: darkBorder,
      ),
      cardTheme: CardThemeData(
        color: darkCardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      fontFamily: 'SF Pro Display',
      useMaterial3: true,
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: electricViolet,
        secondary: emeraldGreenDark,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        outline: lightBorder,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      fontFamily: 'SF Pro Display',
      useMaterial3: true,
    );
  }
}
