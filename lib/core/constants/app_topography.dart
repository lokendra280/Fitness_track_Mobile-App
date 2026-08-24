import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/app_theme.dart';

abstract class AppTypography {
  static const _fontFamily = 'Inter';

  static const _base = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );

  // Display
  static final displayLarge = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );
  static final displayMedium = _base.copyWith(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
  );

  // Headingsap
  static final h1 = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static final h2 = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );
  static final h3 = _base.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static final h4 = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body
  static final bodyLarge = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  static final body = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  static final bodySmall = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // Labels
  static final labelLarge = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  static final label = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );
  static final labelSmall = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: AppColors.textMuted,
  );

  // Caption
  static final caption = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textMuted,
  );
}
