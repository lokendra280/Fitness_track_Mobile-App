import 'package:flutter/material.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';

/// One label + value input inside the Edit Profile form — matches the
/// reference's borderless, softly-tinted field style rather than Material's
/// default outlined TextField chrome.
class EditFieldTile extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const EditFieldTile({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSmall),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style:
                AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
              border: InputBorder.none,
              filled: false,
            ),
          ),
        ],
      ),
    );
  }
}
