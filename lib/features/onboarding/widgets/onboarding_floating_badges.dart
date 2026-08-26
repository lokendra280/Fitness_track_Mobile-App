import 'package:flutter/material.dart';
import '../models/onboarding_page_data.dart';

class OnboardingFloatingBadges extends StatelessWidget {
  final List<OnboardingBadge> badges;

  const OnboardingFloatingBadges({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: badges
          .map(
            (badge) => Align(
              alignment: badge.alignment,
              child: Padding(
                padding: badge.offset,
                child: _BadgeCircle(emoji: badge.emoji),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BadgeCircle extends StatelessWidget {
  final String emoji;

  const _BadgeCircle({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 22)),
    );
  }
}
