import 'package:flutter/material.dart';

class ChipGroupCard extends StatelessWidget {
  final List<String> options;
  final bool Function(String) isSelected;
  final ValueChanged<String> onSelected;
  final String Function(String)? labelBuilder;
  final bool filter;

  const ChipGroupCard({
    required this.options,
    required this.isSelected,
    required this.onSelected,
    this.labelBuilder,
    this.filter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final selected = isSelected(option);
        final label = labelBuilder?.call(option) ?? option;

        return _buildChip(
          context,
          option: option,
          label: label,
          selected: selected,
        );
      }).toList(),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String option,
    required String label,
    required bool selected,
  }) {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return _buildCupertinoChip(
        context,
        option: option,
        label: label,
        selected: selected,
      );
    }

    return _buildMaterialChip(
      context,
      option: option,
      label: label,
      selected: selected,
    );
  }

  Widget _buildMaterialChip(
    BuildContext context, {
    required String option,
    required String label,
    required bool selected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final labelWidget = Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        color: selected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: selected ? Colors.transparent : colorScheme.outlineVariant,
      ),
    );

    if (filter) {
      return FilterChip(
        label: labelWidget,
        selected: selected,
        onSelected: (_) => onSelected(option),
        shape: shape,
        showCheckmark: false,
        backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
        selectedColor: colorScheme.primaryContainer,
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
      );
    }

    return ChoiceChip(
      label: labelWidget,
      selected: selected,
      onSelected: (_) => onSelected(option),
      shape: shape,
      showCheckmark: false,
      backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
      selectedColor: colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2,
      ),
    );
  }

  Widget _buildCupertinoChip(
    BuildContext context, {
    required String option,
    required String label,
    required bool selected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => onSelected(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.transparent : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
