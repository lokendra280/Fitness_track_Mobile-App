import 'package:flutter/material.dart';
import 'package:habitflow/core/common_widget/common_svg.dart';
import '../models/onboarding_page_data.dart';
import 'onboarding_bottom_card.dart';
import 'onboarding_floating_badges.dart';

class OnboardingPageView extends StatelessWidget {
  final OnboardingPageData data;
  final VoidCallback onCtaPressed;

  const OnboardingPageView({
    super.key,
    required this.data,
    required this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CommonSvgWidget(svgName: data.imagePath),

        // Badges/scan overlay sit on top of the image but stop short of
        // the card's vertical space, so they don't get hidden behind it.
        Positioned.fill(
          bottom: 30,
          child: data.variant == OnboardingVariant.photo
              ? OnboardingFloatingBadges(badges: data.badges)
              : const _ScanOverlay(),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: OnboardingBottomCard(
            title: data.title,
            subtitle: data.subtitle,
            ctaLabel: data.ctaLabel,
            onCtaPressed: onCtaPressed,
          ),
        ),
      ],
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RoundIconButton(icon: Icons.close_rounded, onTap: () {}),
                _RoundIconButton(icon: Icons.flash_on_rounded, onTap: () {}),
              ],
            ),
            const Spacer(),
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.35),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
