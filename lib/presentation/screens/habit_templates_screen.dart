import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:habitflow/core/common_widget/common_svg.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/data/models/habit_templated.dart';
import 'package:habitflow/presentation/providers/providers.dart';

class HabitTemplatesScreen extends ConsumerWidget {
  const HabitTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredTemplatesProvider);
    final selectedCat = ref.watch(templateCategoryProvider);

    return Scaffold(
      backgroundColor: context.bgColor,
      body: CustomScrollView(
        slivers: [
          // ── App bar ───────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 110,
            backgroundColor: context.bgColor,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: context.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text('Routines', style: context.syne(22, FontWeight.w700)),
              background: Container(color: context.bgColor),
            ),
          ),

          // ── Category chips ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                separatorBuilder: (_, __) => const Gap(8),
                itemCount: HabitTemplate.categories.length,
                itemBuilder: (_, i) {
                  final cat = HabitTemplate.categories[i];
                  final active = cat == selectedCat;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(templateCategoryProvider.notifier).state = cat;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? context.accent : context.surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: active ? context.accent : context.borderColor,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: context.dmSans(
                          13,
                          FontWeight.w600,
                          color: active ? Colors.white : context.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverGap(16),

          // ── Template grid ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.70,
              ),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) => _TemplateCard(template: filtered[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Template card ─────────────────────────────────────────────────────────────
class _TemplateCard extends ConsumerWidget {
  final HabitTemplate template;
  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.habitPalette;
    final accent = colors[template.colorIndex % colors.length];
    final accentSurf = accent.withOpacity(0.08);

    return GestureDetector(
      onTap: () => _showApplySheet(context, ref),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.borderColor, width: 1.5),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentSurf,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: CommonSvgWidget(
                  svgName: template.icon,
                  height: 24,
                  width: 24,
                ),
              ),
            ),
            const Gap(12),

            // Category eyebrow
            Text(
              template.category.toUpperCase(),
              style: context.dmSans(10, FontWeight.w700, color: accent),
            ),
            const Gap(4),

            // Title
            Text(
              template.name,
              style: context.syne(14, FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(6),

            // Description
            Text(
              template.description,
              style: context.dmSans(11, FontWeight.w400,
                  color: context.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // Habit count pill
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentSurf,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${template.habitNames.length} habits',
                    style: context.dmSans(11, FontWeight.w600, color: accent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showApplySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ApplyTemplateSheet(template: template, ref: ref),
    );
  }
}

// ── Apply sheet ───────────────────────────────────────────────────────────────
class _ApplyTemplateSheet extends StatefulWidget {
  final HabitTemplate template;
  final WidgetRef ref;
  const _ApplyTemplateSheet({required this.template, required this.ref});

  @override
  State<_ApplyTemplateSheet> createState() => _ApplyTemplateSheetState();
}

class _ApplyTemplateSheetState extends State<_ApplyTemplateSheet> {
  bool _loading = false;
  late List<bool> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.filled(widget.template.habitNames.length, true);
  }

  Future<void> _apply() async {
    setState(() => _loading = true);
    HapticFeedback.mediumImpact();
    final notifier = widget.ref.read(habitListProvider.notifier);
    for (int i = 0; i < widget.template.habitNames.length; i++) {
      if (!_selected[i]) continue;
      await notifier.addHabit(
        name: widget.template.habitNames[i],
        icon: widget.template.habitIcons[i],
        targetPerDay: widget.template.habitTargets[i],
        colorIndex: widget.template.colorIndex,
        reminderTime: '',
        reminderEnabled: false,
        frequency: 'daily',
      );
    }
    widget.ref.read(syncStateProvider.notifier).pushPending();
    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context); // back to home
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected.where((s) => s).length;
    final colors = AppColors.habitPalette;
    final accent = colors[widget.template.colorIndex % colors.length];

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.border2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  CommonSvgWidget(
                    svgName: widget.template.icon,
                    height: 28,
                    width: 28,
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.template.name,
                            style: context.syne(18, FontWeight.w700)),
                        Text(widget.template.description,
                            style: context.dmSans(13, FontWeight.w400,
                                color: context.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Gap(16),
            Divider(color: context.borderColor, height: 1),
            const Gap(8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text('Choose habits to add',
                      style: context.dmSans(13, FontWeight.w600,
                          color: context.textSecondary)),
                  const Spacer(),
                  Text('$selected selected',
                      style:
                          context.dmSans(13, FontWeight.w600, color: accent)),
                ],
              ),
            ),
            const Gap(8),

            // Habit list
            Expanded(
              child: ListView.separated(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                separatorBuilder: (_, __) => const Gap(8),
                itemCount: widget.template.habitNames.length,
                itemBuilder: (_, i) {
                  final on = _selected[i];
                  return GestureDetector(
                    onTap: () => setState(() => _selected[i] = !_selected[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: on ? accent.withOpacity(0.06) : context.surface2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: on ? accent : context.borderColor,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          CommonSvgWidget(
                            svgName: widget.template.habitIcons[i],
                            height: 22,
                            width: 22,
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.template.habitNames[i],
                                  style: context.dmSans(14, FontWeight.w600),
                                ),
                                Text(
                                  '${widget.template.habitTargets[i]}× per day',
                                  style: context.dmSans(
                                    12,
                                    FontWeight.w400,
                                    color: context.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: on ? accent : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: on ? accent : context.border2,
                                width: 1.5,
                              ),
                            ),
                            child: on
                                ? const Icon(Icons.check_rounded,
                                    size: 14, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Apply button
            Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 0, 20, MediaQuery.of(context).padding.bottom + 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (selected == 0 || _loading) ? null : _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          'Add $selected habit${selected == 1 ? '' : 's'}',
                          style: context.syne(15, FontWeight.w700,
                              color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
