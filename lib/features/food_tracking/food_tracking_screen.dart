import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/constants/app_string.dart';
import 'package:habitflow/features/food_tracking/providers/food_tracking_provider.dart';
import 'package:habitflow/features/food_tracking/widgets/food_scan_result.dart';
import 'package:habitflow/data/models/tracking_models.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/add_food_sheet.dart';

class FoodTrackingScreen extends ConsumerWidget {
  const FoodTrackingScreen({super.key});

  static const double _fallbackCalorieTarget = 2000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = DateTime.now();
    final entries = ref.watch(foodLogProvider(day));
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final totalCal = entries.fold<double>(0, (s, e) => s + (e.calories ?? 0));
    final totalCarbs = entries.fold<double>(0, (s, e) => s + (e.carbs ?? 0));
    final totalFat = entries.fold<double>(0, (s, e) => s + (e.fat ?? 0));
    final totalProtein =
        entries.fold<double>(0, (s, e) => s + (e.protein ?? 0));

    // TODO: swap for the real accepted plan once wired here, e.g.:
    // final plan = ref.watch(aiPlanControllerProvider);
    // final calorieTarget = plan?.calorieTarget.toDouble() ?? _fallbackCalorieTarget;
    final calorieTarget = _fallbackCalorieTarget;
    final carbTarget = calorieTarget * 0.40 / 4; // 4 kcal/g
    final proteinTarget = calorieTarget * 0.30 / 4;
    final fatTarget = calorieTarget * 0.30 / 9; // 9 kcal/g

    final byMeal = <String, List<FoodEntry>>{
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snack': [],
    };
    for (final e in entries) {
      (byMeal[e.mealType] ??= []).add(e);
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _TodayHeader(
                  date: day,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _WeekStrip(selectedDate: day),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _CalorieCard(
                  eaten: totalCal,
                  target: calorieTarget,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _MacrosCard(
                  carbs: totalCarbs,
                  carbTarget: carbTarget,
                  fat: totalFat,
                  fatTarget: fatTarget,
                  protein: totalProtein,
                  proteinTarget: proteinTarget,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _QuickScanRow(day: day),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Diary', style: text.titleLarge),
                    TextButton(
                      onPressed:
                          () {}, // TODO: wire to a full diary/history screen
                      child: const Text('View all'),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList.list(children: [
                _MealRow(
                  icon: Icons.free_breakfast_rounded,
                  iconColor: Colors.blue,
                  title: 'Breakfast',
                  entries: byMeal['breakfast']!,
                  onLog: () => showAddFoodSheet(context, ref, day),
                ),
                const SizedBox(height: 12),
                _MealRow(
                  icon: Icons.lunch_dining_rounded,
                  iconColor: Colors.blue,
                  title: 'Lunch',
                  entries: byMeal['lunch']!,
                  onLog: () => showAddFoodSheet(context, ref, day),
                ),
                const SizedBox(height: 12),
                _MealRow(
                  icon: Icons.dinner_dining_rounded,
                  iconColor: Colors.blue,
                  title: 'Dinner',
                  entries: byMeal['dinner']!,
                  onLog: () => showAddFoodSheet(context, ref, day),
                ),
                const SizedBox(height: 12),
                _MealRow(
                  icon: Icons.cookie_outlined,
                  iconColor: Colors.blue,
                  title: 'Snack',
                  entries: byMeal['snack']!,
                  onLog: () => showAddFoodSheet(context, ref, day),
                ),
              ]),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddFoodSheet(context, ref, day),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// "Today ▾" header + streak badge
// ---------------------------------------------------------------------------

class _TodayHeader extends StatelessWidget {
  final DateTime date;
  const _TodayHeader({
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(AppString.caloriesTracking, style: text.headlineMedium),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Week strip
// ---------------------------------------------------------------------------

class _WeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  const _WeekStrip({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    // Sunday-start week containing selectedDate.
    final weekdayFromSunday = selectedDate.weekday % 7; // Sun=0..Sat=6
    final sunday = selectedDate.subtract(Duration(days: weekdayFromSunday));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = sunday.add(Duration(days: i));
        final isToday = day.year == selectedDate.year &&
            day.month == selectedDate.month &&
            day.day == selectedDate.day;
        final isPast = day.isBefore(
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day));

        // TODO: replace with a real "was this day fully logged" check
        // once a per-day completion provider exists — currently just
        // marks past days as done and future days as empty, matching
        // the screenshot's visual pattern without real data behind it.
        final done = isPast;

        return Column(
          children: [
            Text(labels[i],
                style: text.bodySmall?.copyWith(color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? Colors.black : Colors.transparent,
                border: Border.all(
                  color: isToday
                      ? scheme.primary
                      : done
                          ? Colors.black
                          : Colors.grey.shade300,
                  width: isToday ? 2 : 1,
                ),
              ),
              child: done
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 18)
                  : null,
            ),
          ],
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Calorie card
// ---------------------------------------------------------------------------

class _CalorieCard extends StatelessWidget {
  final double eaten;
  final double target;
  const _CalorieCard({required this.eaten, required this.target});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final remaining = (target - eaten).clamp(0, target);
    final progress = target == 0 ? 0.0 : (eaten / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Text('Calories', style: text.titleMedium),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${eaten.round()} cal',
                  style: text.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              Text('/ ${target.round()}',
                  style:
                      text.bodyMedium?.copyWith(color: Colors.grey.shade500)),
              const Spacer(),
              Text('${remaining.round()} left',
                  style:
                      text.bodyMedium?.copyWith(color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Macros card
// ---------------------------------------------------------------------------

class _MacrosCard extends StatelessWidget {
  final double carbs, carbTarget;
  final double fat, fatTarget;
  final double protein, proteinTarget;

  const _MacrosCard({
    required this.carbs,
    required this.carbTarget,
    required this.fat,
    required this.fatTarget,
    required this.protein,
    required this.proteinTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _MacroColumn(
              label: 'Carbs',
              value: carbs,
              target: carbTarget,
              color: const Color(0xFF2FBFA0),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _MacroColumn(
              label: 'Fat',
              value: fat,
              target: fatTarget,
              color: const Color(0xFF6C3FDB),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _MacroColumn(
              label: 'Protein',
              value: protein,
              target: proteinTarget,
              color: const Color(0xFFF4A73C),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroColumn extends StatelessWidget {
  final String label;
  final double value;
  final double target;
  final Color color;

  const _MacroColumn({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final progress = target == 0 ? 0.0 : (value / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: text.bodyMedium?.copyWith(color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: text.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800, color: Colors.black),
            children: [
              TextSpan(text: '${value.round()} g'),
              TextSpan(
                text: ' / ${target.round()}',
                style: text.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Quick scan row — kept from your current screen, condensed to two options
// ---------------------------------------------------------------------------

class _QuickScanRow extends ConsumerWidget {
  final DateTime day;
  const _QuickScanRow({required this.day});

  Future<void> _scanPhoto(BuildContext context, WidgetRef ref) async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked == null || !context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FoodScanResultSheet(image: File(picked.path), day: day),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _scanPhoto(context, ref),
            icon: const Icon(Icons.camera_alt_rounded, size: 18),
            label: const Text('Scan food'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: scheme.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push('/barcode'),
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
            label: const Text('Barcode'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: scheme.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Diary meal row
// ---------------------------------------------------------------------------

class _MealRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<FoodEntry> entries;
  final VoidCallback onLog;

  const _MealRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.entries,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final hasEntries = entries.isNotEmpty;

    final totalCal = entries.fold<double>(0, (s, e) => s + e.calories);
    final totalCarbs = entries.fold<double>(0, (s, e) => s + (e.carbs ?? 0));
    final totalFat = entries.fold<double>(0, (s, e) => s + (e.fat ?? 0));
    final totalProtein =
        entries.fold<double>(0, (s, e) => s + (e.protein ?? 0));
    final totalMacroCal =
        (totalCarbs * 4) + (totalFat * 9) + (totalProtein * 4);

    int pct(double macroCal) =>
        totalMacroCal == 0 ? 0 : ((macroCal / totalMacroCal) * 100).round();

    final subtitle = hasEntries
        ? entries.length == 1
            ? entries.first.name
            : '${entries.first.name} and ${entries.length - 1} more'
        : 'Nothing logged yet';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: text.titleMedium),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz_rounded, size: 18),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      splashRadius: 16,
                    ),
                    const SizedBox(width: 8),
                    _LogChip(onTap: onLog, enabled: !hasEntries),
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        text.bodyMedium?.copyWith(color: Colors.grey.shade600)),
                if (hasEntries) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${totalCal.round()} cal · C ${pct(totalCarbs * 4)}% · '
                    'F ${pct(totalFat * 9)}% · P ${pct(totalProtein * 4)}%',
                    style:
                        text.bodySmall?.copyWith(color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogChip extends StatelessWidget {
  final VoidCallback onTap;
  final bool enabled;
  const _LogChip({required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: enabled
              ? Colors.blue.withValues(alpha: 0.12)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Log',
          style: TextStyle(
            color: enabled ? Colors.blue : Colors.grey.shade400,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
