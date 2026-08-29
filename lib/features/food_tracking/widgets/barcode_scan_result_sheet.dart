import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/features/food_tracking/providers/food_tracking_provider.dart';
import '../../../data/models/tracking_models.dart';

class BarcodeScanResultSheet extends ConsumerStatefulWidget {
  final String barcode;
  final DateTime day;
  const BarcodeScanResultSheet(
      {super.key, required this.barcode, required this.day});

  @override
  ConsumerState<BarcodeScanResultSheet> createState() =>
      _BarcodeScanResultSheetState();
}

class _BarcodeScanResultSheetState
    extends ConsumerState<BarcodeScanResultSheet> {
  String _mealType = 'snack';
  double _servings = 1.0;

  void _adjustServings(double delta) {
    setState(() {
      _servings = (_servings + delta).clamp(0.25, 5.0);
      _servings = double.parse(_servings.toStringAsFixed(2));
    });
  }

  @override
  Widget build(BuildContext context) {
    final lookup = ref.watch(barcodeFoodLookupProvider(widget.barcode));

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: lookup.when(
            loading: () => const _Loading(),
            error: (e, _) => _Error(message: '$e'),
            data: (entry) {
              final scaled = FoodEntry(
                name: entry.name,
                calories: entry.calories * _servings,
                protein: (entry.protein ?? 0) * _servings,
                carbs: (entry.carbs ?? 0) * _servings,
                fat: (entry.fat ?? 0) * _servings,
                fiber: entry.fiber != null ? entry.fiber! * _servings : null,
                mealType: _mealType,
                servingSize: (entry.servingSize ?? 100) * _servings,
              );

              return ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _HeroHeader(entry: scaled),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MacroRow(entry: scaled),
                        const SizedBox(height: 24),
                        Text('Meal', style: AppTypography.h4),
                        const SizedBox(height: 10),
                        _MealTypeSelector(
                          selected: _mealType,
                          onSelected: (m) => setState(() => _mealType = m),
                        ),
                        const SizedBox(height: 24),
                        Text('Servings', style: AppTypography.h4),
                        const SizedBox(height: 10),
                        _ServingStepper(
                          servings: _servings,
                          onDecrease: () => _adjustServings(-0.25),
                          onIncrease: () => _adjustServings(0.25),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Per 100g: ${entry.calories.round()} kcal · '
                          '${(entry.protein ?? 0).round()}g protein · '
                          '${(entry.carbs ?? 0).round()}g carbs · '
                          '${(entry.fat ?? 0).round()}g fat',
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: Material(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () async {
                                await ref
                                    .read(foodLogProvider(widget.day).notifier)
                                    .addEntry(scaled);
                                if (context.mounted)
                                  Navigator.of(context).pop();
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 17),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_rounded,
                                        color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Add to log',
                                      style: AppTypography.labelLarge.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Gradient hero card with the product name and an animated calorie count —
/// the centerpiece a fitness app leads with, instead of burying calories in
/// a small badge next to the title.
class _HeroHeader extends StatelessWidget {
  final FoodEntry entry;
  const _HeroHeader({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.calories,
            AppColors.calories.withValues(alpha: 0.78)
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.calories.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.qr_code_scanner_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.h3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: entry.calories),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      builder: (context, value, _) => Text(
                        '${value.round()}',
                        style: AppTypography.displayMedium
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'kcal',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Protein / Carbs / Fat as three color-coded mini cards, matching the
/// dashboard's existing macro color language (exercise=protein purple,
/// calories=carbs orange, water=fat blue) instead of a plain text line.
class _MacroRow extends StatelessWidget {
  final FoodEntry entry;
  const _MacroRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MacroTile(
            label: 'Protein',
            grams: entry.protein ?? 0,
            color: AppColors.exercise,
            bg: AppColors.exerciseBg,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MacroTile(
            label: 'Carbs',
            grams: entry.carbs ?? 0,
            color: AppColors.calories,
            bg: AppColors.caloriesBg,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MacroTile(
            label: 'Fat',
            grams: entry.fat ?? 0,
            color: AppColors.water,
            bg: AppColors.waterBg,
          ),
        ),
      ],
    );
  }
}

class _MacroTile extends StatelessWidget {
  final String label;
  final double grams;
  final Color color;
  final Color bg;

  const _MacroTile({
    required this.label,
    required this.grams,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 8),
          Text(
            '${grams.round()}g',
            style: AppTypography.h4.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}

/// Pill-style horizontal meal selector, replacing the plain dropdown —
/// scannable at a glance and matches fitness-app segmented-control patterns.
class _MealTypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _MealTypeSelector({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: mealIcons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final meal = mealIcons.keys.elementAt(i);
          final isSelected = meal == selected;
          return GestureDetector(
            onTap: () => onSelected(meal),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mealIcons[meal] ?? Icons.restaurant,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    meal[0].toUpperCase() + meal.substring(1),
                    style: AppTypography.labelLarge.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Explicit +/- stepper instead of a slider — more precise for a numeric
/// serving count and reads as more "app-like" than dragging a thumb.
class _ServingStepper extends StatelessWidget {
  final double servings;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _ServingStepper({
    required this.servings,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _StepperButton(icon: Icons.remove_rounded, onTap: onDecrease),
          Expanded(
            child: Center(
              child: Text(
                '${servings.toStringAsFixed(2)}x',
                style: AppTypography.h3,
              ),
            ),
          ),
          _StepperButton(icon: Icons.add_rounded, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 56),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.caloriesBg,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.qr_code_scanner_rounded,
              size: 30, color: AppColors.calories),
        ),
        const SizedBox(height: 20),
        Text('Looking up product…', style: AppTypography.h4),
        const SizedBox(height: 4),
        Text(
          'Matching barcode to nutrition data',
          style: AppTypography.bodySmall,
        ),
      ]),
    );
  }
}

class _Error extends StatelessWidget {
  final String message;
  const _Error({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Color(0xFFFDEAEA),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.search_off_rounded,
              color: Color(0xFFE05A5A), size: 30),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close', style: AppTypography.labelLarge),
        ),
      ]),
    );
  }
}
