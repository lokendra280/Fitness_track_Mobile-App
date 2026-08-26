import 'package:flutter/material.dart';
import 'package:habitflow/core/constants/app_topography.dart';

class AppColors {
  AppColors._();

  static const journeyGradientTop = Color(0xFF1E4D42);
  static const journeyGradientBottom = Color(0xFF163A32);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const background = Color(0xFFF7F3E9);

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
  static const textMuted = Color(0xFF9CA3AF);
  static const surfaceMuted = Color(0xFFEFEAE0);

  static const goalStepsColor = Color(0xFFF4A73C);
  static const goalCardioColor = Color(0xFFE8555A);
  static const goalStrengthColor = Color(0xFF4E8FDB);
  static const goalCardBorder = Color(0xFFEDEDED);
  static const insightBg = Color(0xFFE3F3EA);
  static const milestoneBg = Color(0xFFE3F3EA);
  static const stepsTrack = Color(0xFFDCF3E4);
  static const chartGridline = Color(0xFFEFF1F2);
  static const chartBarMuted = Color(0xFFA9DCBB);
}

class AppTheme {
  /// Maps AppTypography's named styles onto Flutter's TextTheme slots,
  /// so every `Theme.of(context).textTheme.*` call across the app picks
  /// up Montserrat + the custom scale instead of the Material default.
  static TextTheme get _textTheme => TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.h1,
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
        titleLarge: AppTypography.h3,
        titleMedium: AppTypography.h4,
        titleSmall: AppTypography.labelLarge,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.label,
        labelSmall: AppTypography.labelSmall,
      );

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

    return base.copyWith(
      textTheme: _textTheme,
      primaryTextTheme: _textTheme,
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTypography.h2,
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
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          color: base.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelSmall,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
