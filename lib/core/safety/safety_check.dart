import 'package:flutter/material.dart';

/// Spec: safety.professional_help_when_appropriate.
/// Pure, testable rules — flags patterns worth a "consider professional
/// support" nudge. This never diagnoses; it only decides when to show the
/// banner below. Call `check()` wherever check-in / weight data is saved.
class SafetyCheckResult {
  final bool shouldSuggestProfessionalHelp;
  final String? reason;
  const SafetyCheckResult({required this.shouldSuggestProfessionalHelp, this.reason});
}

class SafetyCheck {
  /// [weeklyWeightChangeKg] negative = loss. Flags >1kg/week loss (spec:
  /// avoid_extreme_weight_loss_recommendations) and persistently low mood/
  /// high stress from check-ins.
  static SafetyCheckResult check({
    double? weeklyWeightChangeKg,
    List<int>? recentStressLevels, // 1-5, most recent last
    List<int>? recentEnergyLevels,
  }) {
    if (weeklyWeightChangeKg != null && weeklyWeightChangeKg <= -1.5) {
      return const SafetyCheckResult(
        shouldSuggestProfessionalHelp: true,
        reason: 'Your weight loss pace looks faster than the generally recommended 0.5–1kg/week.',
      );
    }
    if (recentStressLevels != null && recentStressLevels.length >= 3 && recentStressLevels.every((s) => s >= 4)) {
      return const SafetyCheckResult(
        shouldSuggestProfessionalHelp: true,
        reason: 'Your stress levels have been consistently high in recent check-ins.',
      );
    }
    if (recentEnergyLevels != null && recentEnergyLevels.length >= 5 && recentEnergyLevels.every((e) => e <= 2)) {
      return const SafetyCheckResult(
        shouldSuggestProfessionalHelp: true,
        reason: 'Your energy levels have been consistently low for several days.',
      );
    }
    return const SafetyCheckResult(shouldSuggestProfessionalHelp: false);
  }
}

class ProfessionalHelpBanner extends StatelessWidget {
  final String reason;
  const ProfessionalHelpBanner({super.key, required this.reason});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange[200]!)),
        child: Row(children: [
          const Icon(Icons.health_and_safety_outlined, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text('$reason Consider talking to a doctor or registered dietitian.', style: const TextStyle(fontSize: 13))),
        ]),
      );
}
