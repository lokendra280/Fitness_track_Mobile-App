import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/journey_setup_provider.dart';

class JourneySetupScreen extends ConsumerStatefulWidget {
  const JourneySetupScreen({super.key});

  @override
  ConsumerState<JourneySetupScreen> createState() => _JourneySetupScreenState();
}

class _JourneySetupScreenState extends ConsumerState<JourneySetupScreen> {
  late final TextEditingController _startCtrl;
  late final TextEditingController _targetCtrl;

  @override
  void initState() {
    super.initState();
    final goal = ref.read(journeySetupControllerProvider);
    _startCtrl =
        TextEditingController(text: goal.startingWeight?.toString() ?? '');
    _targetCtrl =
        TextEditingController(text: goal.targetWeight?.toString() ?? '');
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(journeySetupControllerProvider.notifier);
    final goal = ref.watch(journeySetupControllerProvider);
    final isValid = ref.watch(journeySetupValidProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _StepHeader(
                step: 1,
                totalSteps: 3,
                title: 'Start your journey',
                subtitle: "Let's set a goal that fits your life.",
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _SectionCard(
                    icon: Icons.flag_rounded,
                    title: 'Goal',
                    child: SegmentedButton<String>(
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: colorScheme.primary,
                        selectedForegroundColor: colorScheme.onPrimary,
                        side: BorderSide(color: colorScheme.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      segments: const [
                        ButtonSegment(
                            value: 'lose_weight', label: Text('Lose')),
                        ButtonSegment(
                            value: 'maintain', label: Text('Maintain')),
                        ButtonSegment(
                            value: 'gain_muscle', label: Text('Gain muscle')),
                      ],
                      selected: {goal.type},
                      onSelectionChanged: (s) => controller.updateType(s.first),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.monitor_weight_rounded,
                    title: 'Weight',
                    child: Column(
                      children: [
                        _PremiumTextField(
                          controller: _startCtrl,
                          label: 'Starting weight',
                          suffix: goal.weightUnit,
                          icon: Icons.trending_flat_rounded,
                          onChanged: (v) => controller.updateWeights(
                            start: double.tryParse(v),
                            current: double.tryParse(
                                v), // current defaults to starting weight
                          ),
                        ),
                        const SizedBox(height: 14),
                        _PremiumTextField(
                          controller: _targetCtrl,
                          label: 'Target weight',
                          suffix: goal.weightUnit,
                          icon: Icons.flag_circle_rounded,
                          onChanged: (v) => controller.updateWeights(
                              target: double.tryParse(v)),
                        ),
                        if (goal.weightToLose != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.primaryContainer.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  goal.weightToLose! >= 0
                                      ? Icons.south_rounded
                                      : Icons.north_rounded,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${goal.weightToLose!.abs().toStringAsFixed(1)} ${goal.weightUnit} to '
                                    '${goal.weightToLose! >= 0 ? 'lose' : 'gain'}',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.event_rounded,
                    title: 'Timeline',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.now().add(const Duration(days: 90)),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 730)),
                        );
                        if (picked != null)
                          controller.updateDates(target: picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month_rounded,
                                color: colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                goal.targetDate == null
                                    ? 'Pick a target date'
                                    : goal.targetDate!
                                        .toLocal()
                                        .toString()
                                        .split(' ')
                                        .first,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: colorScheme.onSurfaceVariant),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: isValid
                        ? () async {
                            await controller.submit();
                            if (context.mounted)
                              context.push('/personal-profile');
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Continue', style: theme.textTheme.labelLarge),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      await controller.saveAndContinueLater();
                      if (context.mounted) context.go('/dashboard');
                    },
                    child: const Text('Save & continue later'),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final int step;
  final int totalSteps;
  final String title;
  final String subtitle;

  const _StepHeader({
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.82),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $step of $totalSteps',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.85),
                ),
              ),
              Row(
                children: List.generate(totalSteps, (i) {
                  final active = i < step;
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    width: 20,
                    height: 4,
                    decoration: BoxDecoration(
                      color: active
                          ? colorScheme.onPrimary
                          : colorScheme.onPrimary.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? suffix;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
      ),
    );
  }
}
