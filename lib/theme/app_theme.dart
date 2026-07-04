import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF3F6FB);
  static const cardBackground = Colors.white;
  static const navy = Color(0xFF0B2545);
  static const primaryBlue = Color(0xFF0B5FA8);
  static const primaryBlueDark = Color(0xFF084A85);
  static const subtitleGray = Color(0xFF5B6B7C);
  static const borderGray = Color(0xFFE1E7F0);
  static const trackBlue = Color(0xFFD7E4F5);
  static const riskOrange = Color(0xFFE07A2C);
  static const riskOrangeBg = Color(0xFFFBEAD9);
  static const tagBluebg = Color(0xFFE7F0FB);
  static const tagGreenBg = Color(0xFFE3F3E9);
  static const tagGreenText = Color(0xFF1E8E5A);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.navy),
        titleTextStyle: TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
