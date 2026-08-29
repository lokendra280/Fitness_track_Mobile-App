import 'package:flutter/material.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/features/personal_profile/models/personal_model.dart';
import 'profile_avatar.dart';
import 'profile_pill_chip.dart';
import 'profile_stat_row.dart';

class ProfileHeaderCard extends StatelessWidget {
  final ProfileViewData data;
  final VoidCallback onEditTap;

  const ProfileHeaderCard({
    super.key,
    required this.data,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.journeyGradientTop,
            AppColors.journeyGradientBottom,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.journeyGradientBottom.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(imageUrl: data.avatarUrl, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.fullName,
                      style: AppTypography.h3.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${data.username}',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEditTap,
                icon: const Icon(Icons.edit_outlined,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Flexible(
                child: ProfilePillChip(
                  icon: Icons.bar_chart_rounded,
                  label: data.fitnessLevel,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: ProfilePillChip(
                  icon: Icons.autorenew_rounded,
                  label: 'Progress ${(data.progressPercent * 100).round()}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ProfileStatRow(
            stats: [
              ('Age', data.age != null ? '${data.age}' : '—'),
              ('Gender', data.gender ?? '—'),
              (
                'Height',
                data.heightCm != null ? '${data.heightCm!.round()} cm' : '—'
              ),
              (
                'Weight',
                data.weightKg != null ? '${data.weightKg!.round()} kg' : '—'
              ),
            ],
          ),
        ],
      ),
    );
  }
}
