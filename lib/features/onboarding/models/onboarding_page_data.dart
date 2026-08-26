import 'package:flutter/widgets.dart';
import 'package:habitflow/core/constants/constant_assets.dart';

enum OnboardingVariant { photo, scan }

class OnboardingBadge {
  final String emoji;
  final Alignment alignment;
  final EdgeInsets offset;

  const OnboardingBadge({
    required this.emoji,
    required this.alignment,
    this.offset = EdgeInsets.zero,
  });
}

class OnboardingPageData {
  final OnboardingVariant variant;
  final String imagePath;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final List<OnboardingBadge> badges;

  const OnboardingPageData({
    required this.variant,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    this.badges = const [],
  });
}

const List<OnboardingPageData> onboardingPages = [
  OnboardingPageData(
    variant: OnboardingVariant.photo,
    imagePath: Assets.onBoardingOne,
    title: 'Start Today, Success Is\nOne Track Away',
    subtitle:
        'Log meals, track progress, fuel your fitness journey with daily motivation.',
    ctaLabel: 'Continue',
    badges: [
      OnboardingBadge(emoji: '💪', alignment: Alignment(-0.7, -0.35)),
      OnboardingBadge(emoji: '🔥', alignment: Alignment(0.7, -0.05)),
      OnboardingBadge(emoji: '❤️', alignment: Alignment(-0.75, 0.35)),
    ],
  ),
  OnboardingPageData(
    variant: OnboardingVariant.scan,
    imagePath: Assets.onBoardingTwo,
    title: 'Smarter Meals, Healthier\nYou – Powered By AI.',
    subtitle:
        'AI helps you log smarter meals, track nutrition, improve daily health.',
    ctaLabel: 'Continue',
  ),
  OnboardingPageData(
    variant: OnboardingVariant.photo,
    imagePath: Assets.onboardingThree,
    title: 'Food Insights Meet Better\nBody Performance.',
    subtitle:
        'Track meals, thrive personalized guidance on your wellness journey.',
    ctaLabel: 'Get Started',
    badges: [
      OnboardingBadge(emoji: '🔥', alignment: Alignment(-0.75, -0.55)),
      OnboardingBadge(emoji: '🥑', alignment: Alignment(-0.8, 0.15)),
      OnboardingBadge(emoji: '📈', alignment: Alignment(0.75, 0.05)),
    ],
  ),
];
