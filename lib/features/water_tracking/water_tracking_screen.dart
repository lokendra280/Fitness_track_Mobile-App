import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/features/water_tracking/providers/water_tracking_provider.dart';
import 'package:habitflow/features/water_tracking/widgets/water_droplets_grid.dart';
import 'package:habitflow/features/water_tracking/widgets/water_goal_card.dart';

/// Number of glasses that make up the daily goal, and the ml each glass
/// tap adds. TODO: replace these constants with a persisted user setting
/// once a "daily goal" provider exists — currently hardcoded to match
/// the reference design (15 glasses/day).
const int kDailyGlassGoal = 15;
const int kMlPerGlass = 250;

class WaterTrackingScreen extends ConsumerWidget {
  const WaterTrackingScreen({super.key, this.userName = ''});

  /// Shown in the "Keep going" message, e.g. "Taigo, you drunk...".
  /// TODO: wire to the real user-profile provider instead of a param.
final String userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(waterProgressProvider).clamp(0.0, 1.0);
    final consumedGlasses = (progress * kDailyGlassGoal).round();
    final remainingGlasses =
        (kDailyGlassGoal - consumedGlasses).clamp(0, kDailyGlassGoal);

    return Scaffold(
      backgroundColor: AppColors.background,
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
              '$consumedGlasses of $kDailyGlassGoal glasses',
              style: AppTypography.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              remainingGlasses > 0
                  ? '${userName.isNotEmpty ? '$userName, y' : 'Y'}ou drunk '
                      '$consumedGlasses/$kDailyGlassGoal glasses of water. '
                      'Keep going only $remainingGlasses glasses left for today'
                  : '${userName.isNotEmpty ? '$userName, y' : 'Y'}ou hit your '
                      'water goal for today. Nice work!',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 20),
            WaterDropletsGrid(
              totalGlasses: kDailyGlassGoal,
              consumedGlasses: consumedGlasses,
              onAddGlass: () => ref
                  .read(waterControllerProvider.notifier)
                  .quickAdd(kMlPerGlass),
            ),
            const SizedBox(height: 32),
            Text('Notification', style: AppTypography.h2),
            const SizedBox(height: 12),
            // WaterNotificationSection(
            //   onReminderEnabled: () async {
            //     await ref
            //         .read(notificationServiceProvider)
            //         .scheduleWaterReminder();
            //     if (context.mounted) {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text('Water reminders enabled')),
            //       );
            //     }
            //   },
            // ),
            const SizedBox(height: 24),
            WaterGoalCard(dailyGoalGlasses: kDailyGlassGoal),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () {
                  // TODO: open a "change daily goal" flow once that
                  // settings screen/provider exists.
                },
                child: Text(
                  'Change daily goal',
                  style: AppTypography.labelLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
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
