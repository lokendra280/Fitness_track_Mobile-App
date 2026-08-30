import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/app_theme.dart';

class PersonalWorkoutCard extends StatelessWidget {
  const PersonalWorkoutCard({
    super.key,
    required this.title,
    required this.completedCount,
    required this.totalCount,
    this.onTap,
    this.onMenuTap,
  });

  final String title;
  final int completedCount;
  final int totalCount;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    final remaining = (totalCount - completedCount).clamp(0, totalCount);
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey.shade800, AppColors.goalStrengthColor],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.15),
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          width: 160,
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.25),
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$completedCount done · $remaining remaining',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onMenuTap != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: onMenuTap,
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      splashRadius: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
