import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/journey_repository_provider.dart';

class ConsentState {
  final bool healthDataConsent, aiDataConsent;
  const ConsentState({this.healthDataConsent = false, this.aiDataConsent = false});
}

class ConsentController extends Notifier<ConsentState> {
  @override
  ConsentState build() {
    final repo = ref.read(journeyRepositoryProvider);
    return ConsentState(healthDataConsent: repo.hasHealthDataConsent, aiDataConsent: repo.hasAiDataConsent);
  }

  Future<void> setHealthConsent(bool v) async {
    state = ConsentState(healthDataConsent: v, aiDataConsent: state.aiDataConsent);
    await ref.read(journeyRepositoryProvider).setConsent(health: v);
  }

  Future<void> setAiConsent(bool v) async {
    state = ConsentState(healthDataConsent: state.healthDataConsent, aiDataConsent: v);
    await ref.read(journeyRepositoryProvider).setConsent(ai: v);
  }

  Future<void> exportAllData() async {
    // repo.box.toMap() → serialize to file; left as a hook for Phase 9's export.
  }

  Future<void> deleteAllData() async {
    await ref.read(journeyRepositoryProvider).box.clear();
  }
}

final consentControllerProvider = NotifierProvider<ConsentController, ConsentState>(ConsentController.new);

/// Drop into any AI-generated screen (ai_plan, ai_daily_review, ai_coach,
/// weekly/monthly review).
class SafetyBannerWidget extends StatelessWidget {
  const SafetyBannerWidget({super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        color: Colors.amber[50],
        child: const Text('Not medical advice.', style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
      );
}

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consent = ref.watch(consentControllerProvider);
    final controller = ref.read(consentControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & data')),
      body: ListView(children: [
        SwitchListTile(title: const Text('Health data sync'), value: consent.healthDataConsent, onChanged: controller.setHealthConsent),
        SwitchListTile(title: const Text('AI features'), value: consent.aiDataConsent, onChanged: controller.setAiConsent),
        ListTile(title: const Text('Export all data'), trailing: const Icon(Icons.download), onTap: controller.exportAllData),
        ListTile(
          title: const Text('Delete all data', style: TextStyle(color: Colors.red)),
          trailing: const Icon(Icons.delete, color: Colors.red),
          onTap: () => showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete all data?'),
              content: const Text('This cannot be undone.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                FilledButton(onPressed: () { controller.deleteAllData(); Navigator.pop(ctx); }, child: const Text('Delete')),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
