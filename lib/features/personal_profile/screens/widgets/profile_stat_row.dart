import 'package:flutter/material.dart';
import 'package:habitflow/core/constants/app_topography.dart';

/// The Age / Gender / Height / Weight row inside a translucent strip on
/// the header card.
class ProfileStatRow extends StatelessWidget {
  final List<(String label, String value)> stats;

  const ProfileStatRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final (label, value) in stats)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
