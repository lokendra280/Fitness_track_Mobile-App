import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/data/repositories/journey_repository_provider.dart';
import 'package:habitflow/features/steps/ui/step_count_provider.dart';

final stepsSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<int>>(todayStepsProvider, (previous, next) {
    final steps = next.valueOrNull;
    if (steps == null) return;
    ref.read(journeyRepositoryProvider).saveSteps(DateTime.now(), steps);
  });
});
