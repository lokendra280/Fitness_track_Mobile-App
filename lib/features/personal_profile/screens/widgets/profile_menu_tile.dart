import 'package:flutter/material.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';

/// One row in the menu list — "Subscription", "Connected Device", "Settings",
/// and the destructive "Log Out" variant.
class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showChevron;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isDestructive ? Colors.white : AppColors.textPrimary;
    final bg = isDestructive
        ? const Color(0xFFE8555A)
        : AppColors.primary.withValues(alpha: 0.08);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 19, color: fg),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelLarge.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (showChevron)
                Icon(Icons.chevron_right_rounded,
                    color: fg.withValues(alpha: 0.6), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
