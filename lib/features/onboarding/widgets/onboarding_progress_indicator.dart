import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/app_theme.dart';

/// The pill-shaped progress indicator from the reference design: the active
/// segment stretches into a wide green pill, the rest stay as small grey dots.
class OnboardingProgressIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;

  const OnboardingProgressIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.calories
                : Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
