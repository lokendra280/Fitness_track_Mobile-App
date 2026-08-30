import 'package:flutter/material.dart';

class MacrosCard extends StatelessWidget {
  final double carbs, carbTarget;
  final double fat, fatTarget;
  final double protein, proteinTarget;

  const MacrosCard({
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
