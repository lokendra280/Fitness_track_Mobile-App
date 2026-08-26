import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How many days the journey's daily habit grid should span. Defaults
/// to 80 (matching "80-day target" in the request) until there's a
/// real per-user journey-length field to read from — override this
/// via ProviderScope once journeySetupControllerProvider (or wherever
/// the user's chosen duration actually lives) exposes it, e.g.:
///
///   journeyLengthDaysProvider.overrideWith(
///     (ref) => ref.watch(journeySetupControllerProvider).durationDays,
///   )
final journeyLengthDaysProvider = Provider<int>((ref) => 80);

@immutable
class DailyLogKey {
  final String habitName;
  final DateTime day; // normalized to midnight
  const DailyLogKey(this.habitName, this.day);

  @override
  bool operator ==(Object other) =>
      other is DailyLogKey &&
      other.habitName == habitName &&
      other.day.year == day.year &&
      other.day.month == day.month &&
      other.day.day == day.day;

  @override
  int get hashCode => Object.hash(habitName, day.year, day.month, day.day);
}

final habitDailyLogProvider =
    NotifierProvider<HabitDailyLogController, Map<DailyLogKey, bool>>(
  HabitDailyLogController.new,
);

class HabitDailyLogController extends Notifier<Map<DailyLogKey, bool>> {
  @override
  Map<DailyLogKey, bool> build() => {};

  void log(String habitName, DateTime day, bool done) {
    final normalized = DateTime(day.year, day.month, day.day);
    state = {...state, DailyLogKey(habitName, normalized): done};
  }

  bool isDone(String habitName, DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return state[DailyLogKey(habitName, normalized)] ?? false;
  }
}
