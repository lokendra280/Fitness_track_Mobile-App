import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/data/models/exercise_item.dart';
import '../providers/daily_exercise_provider.dart';

class DailyExerciseCard extends ConsumerWidget {
  const DailyExerciseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyExerciseProvider);
    final toggle = ref.watch(toggleExerciseProvider);

    if (state.workout == null) {
      return const _EmptyState(
        icon: Icons.event_busy_rounded,
        text: 'No workout plan generated yet.',
      );
    }

    if (state.workout!.isRestDay) {
      return const _EmptyState(
        icon: Icons.self_improvement_rounded,
        text: 'Rest day — recovery is part of the plan.',
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.workout!.day.toUpperCase(),
                      style: AppTypography.labelSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.workout!.focus ?? 'Workout',
                      style: AppTypography.h3,
                    ),
                  ],
                ),
              ),
              _ProgressRing(progress: state.progress, done: state.isFullyDone),
            ],
          ),
          const SizedBox(height: 16),
          for (final exercise in state.workout!.exercises)
            _ExerciseRow(
              exercise: exercise,
              isDone: state.completedExerciseNames.contains(exercise.name),
              onToggle: () => toggle(exercise.name),
            ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  final bool done;
  const _ProgressRing({required this.progress, required this.done});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, value, _) => CircularProgressIndicator(
              value: value,
              strokeWidth: 4,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                done ? AppColors.primary : Colors.deepOrange,
              ),
            ),
          ),
          if (done)
            const Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final ExerciseItem exercise;
  final bool isDone;
  final VoidCallback onToggle;

  const _ExerciseRow({
    required this.exercise,
    required this.isDone,
    required this.onToggle,
  });

  Color _categoryColor() {
    switch (exercise.category) {
      case ExerciseCategory.cardio:
        return const Color(0xFFE8555A);
      case ExerciseCategory.mobility:
        return const Color(0xFF8C6FE0);
      case ExerciseCategory.strength:
        return const Color(0xFF3B9EDB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isDone ? AppColors.primary : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check_rounded,
                        size: 15, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _categoryColor(),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  exercise.name,
                  style: AppTypography.labelLarge.copyWith(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                  ),
                ),
              ),
              Text(exercise.sets, style: AppTypography.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
