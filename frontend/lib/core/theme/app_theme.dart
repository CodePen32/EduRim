import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        // ignore: deprecated_member_use
        background: AppColors.background,
      ),
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
        hintStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textLight),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: AppColors.primary.withValues(alpha: 0.1),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        headlineMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        titleLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        bodyLarge: TextStyle(fontFamily: 'Cairo', color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
      ),
    );
  }

  // ألوان الوضع الداكن (أسطح/بطاقات/نصوص). تبقى الهوية الزرقاء كما هي.
  static const Color _dSurface = Color(0xFF1A2232);
  static const Color _dBg = Color(0xFF0F1420);
  static const Color _dText = Color(0xFFE8EAF0);
  static const Color _dText2 = Color(0xFFAAB2C5);
  static const Color _dBorder = Color(0xFF2A3446);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.accent,
        surface: _dSurface,
        onSurface: _dText,
        error: AppColors.error,
      ),
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: _dBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _dSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _dBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _dBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        labelStyle: const TextStyle(fontFamily: 'Cairo', color: _dText2),
        hintStyle: const TextStyle(fontFamily: 'Cairo', color: _dText2),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: _dSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
      dividerColor: _dBorder,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: _dText),
        headlineMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: _dText),
        titleLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: _dText),
        titleMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w500, color: _dText),
        bodyLarge: TextStyle(fontFamily: 'Cairo', color: _dText),
        bodyMedium: TextStyle(fontFamily: 'Cairo', color: _dText2),
      ),
    );
  }
}
