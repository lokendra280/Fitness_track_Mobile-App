import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/features/water_tracking/providers/water_tracking_provider.dart';
import 'package:habitflow/features/water_tracking/widgets/water_droplets_grid.dart';
import 'package:habitflow/features/water_tracking/widgets/water_goal_card.dart';

class WaterTrackingScreen extends ConsumerWidget {
  const WaterTrackingScreen({super.key, this.userName = ''});

  /// TODO: wire to the real user-profile provider instead of a param.
  final String userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(waterProgressProvider);
    final targetMl = ref.watch(waterTargetProvider);
    final glassGoal = ref.watch(waterGlassGoalProvider);
    final consumedMl = ref.watch(waterControllerProvider);

    final consumedGlasses = (progress * glassGoal).round();
    final remainingGlasses = (glassGoal - consumedGlasses).clamp(0, glassGoal);
    final remainingMl = (targetMl - consumedMl).clamp(0, targetMl);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _TopBar(
              onClose: () => Navigator.of(context).maybePop(),
              onConfirm: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 24),
            Text('Water today', style: AppTypography.body),
            const SizedBox(height: 4),
            Text(
              '$consumedMl / $targetMl ml',
              style: AppTypography.displayLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '$consumedGlasses of $glassGoal glasses',
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              remainingGlasses > 0
                  ? '${userName.isNotEmpty ? '$userName, y' : 'Y'}ou\'ve had '
                      '$consumedMl of $targetMl ml today. '
                      'Keep going — $remainingMl ml left to hit your goal.'
                  : '${userName.isNotEmpty ? '$userName, y' : 'Y'}ou hit your '
                      'water goal for today. Nice work!',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 20),
            WaterDropletsGrid(
              totalGlasses: glassGoal,
              consumedGlasses: consumedGlasses,
              onAddGlass: () => ref
                  .read(waterControllerProvider.notifier)
                  .quickAdd(kMlPerGlass),
            ),
            const SizedBox(height: 32),
            Text('Notification', style: AppTypography.h2),
            const SizedBox(height: 12),
            // WaterNotificationSection(...) — unchanged, still commented
            const SizedBox(height: 24),
            WaterGoalCard(dailyGoalGlasses: glassGoal),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose, required this.onConfirm});

  final VoidCallback onClose;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(icon: Icons.close, onTap: onClose, dashed: true),
        Expanded(
          child: Text(
            'Water tracking',
            textAlign: TextAlign.center,
            style: AppTypography.h3,
          ),
        ),
        _CircleIconButton(icon: Icons.check, onTap: onConfirm, dashed: false),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.dashed,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: dashed ? Colors.transparent : AppColors.surfaceMuted,
      shape: CircleBorder(
        side: dashed
            ? BorderSide(color: AppColors.textMuted.withValues(alpha: 0.4))
            : BorderSide.none,
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
