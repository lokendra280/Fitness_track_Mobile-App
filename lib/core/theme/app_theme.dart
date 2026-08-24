import 'package:flutter/material.dart';
import 'package:habitflow/core/constants/app_topography.dart';

class AppColors {
  AppColors._();

  static const journeyGradientTop = Color(0xFF1E4D42);
  static const journeyGradientBottom = Color(0xFF163A32);

  static const calories = Color(0xFFF6A23A);
  static const caloriesBg = Color(0xFFFDEEDA);
  static const water = Color(0xFF3B9EDB);
  static const waterBg = Color(0xFFDCEEFA);
  static const steps = Color(0xFF3FAE6A);
  static const stepsBg = Color(0xFFDCF3E4);
  static const exercise = Color(0xFF8C6FE0);
  static const exerciseBg = Color(0xFFE9E2FB);
  static const sleep = Color(0xFF6C6FDA);
  static const sleepBg = Color(0xFFE6E6FB);

  static const insightBg = Color(0xFFE3F3EA);
  static const milestoneBg = Color(0xFFE3F3EA);
  static const stepsTrack =
      Color(0xFFDCF3E4); // light ring/bar track (reuses stepsBg tone)
  static const chartGridline =
      Color(0xFFEFF1F2); // faint horizontal chart lines
  static const chartBarMuted = Color(0xFFA9DCBB);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed:
          const Color(0xFF2E7D6B), // calm teal — health/wellness tone
      scaffoldBackgroundColor: const Color(0xFFF6F7F8),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
      ),
    );

    return AppTypography.applyTo(base).copyWith(
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: Colors.black87,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: base.colorScheme.primary,
        linearTrackColor: Colors.grey.shade200,
        circularTrackColor: Colors.grey.shade200,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: base.colorScheme.primary,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
