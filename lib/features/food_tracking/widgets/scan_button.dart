import 'package:flutter/material.dart';

/// One of the two "Scan food" / "Upload photo" entry buttons.
class ScanButton extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final VoidCallback onTap;
  const ScanButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: scheme.primaryContainer, shape: BoxShape.circle),
              child: Icon(icon, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: 8),
            Text(label, style: text.titleMedium),
            Text(subtitle, style: text.labelMedium),
          ]),
        ),
      ),
    );
  }
}
