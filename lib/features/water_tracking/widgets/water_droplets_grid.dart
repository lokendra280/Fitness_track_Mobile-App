import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/app_theme.dart';

/// The glass grid from the reference design: one filled glass icon per
/// glass already drunk, and an outline "+" glass for each remaining
/// glass — tapping an empty glass logs one.
class WaterDropletsGrid extends StatelessWidget {
  const WaterDropletsGrid({
    super.key,
    required this.totalGlasses,
    required this.consumedGlasses,
    required this.onAddGlass,
    this.columns = 7,
  });

  final int totalGlasses;
  final int consumedGlasses;
  final VoidCallback onAddGlass;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(totalGlasses, (i) {
        final filled = i < consumedGlasses;
        return _WaterGlass(filled: filled, onTap: filled ? null : onAddGlass);
      }),
    );
  }
}

class _WaterGlass extends StatelessWidget {
  const _WaterGlass({required this.filled, required this.onTap});

  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                filled ? Icons.local_drink : Icons.local_drink_outlined,
                size: 32,
                color: filled ? AppColors.water : AppColors.waterBg,
              ),
              if (!filled)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.water,
                    ),
                    child: const Icon(Icons.add, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
