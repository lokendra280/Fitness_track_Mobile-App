import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Add `flutter_local_notifications` to pubspec.yaml and fill in the plugin
/// calls (commented) once you can run `flutter pub get` — kept as a stub
/// here so the rest of the app compiles without that dependency. Call sites
/// for `celebrate()` already exist (milestones_screen.dart); the rest are
/// defined but not yet called from anywhere — hook them up once the plugin
/// is wired in.
class NotificationService {
  Future<void> init() async {
    // final plugin = FlutterLocalNotificationsPlugin();
    // await plugin.initialize(const InitializationSettings(...));
  }

  // --- reminders (spec: notifications.reminders) ---
  Future<void> scheduleWaterReminder() async {
    // Recurring reminder, e.g. every 2 hours during waking hours.
    // await _plugin.zonedSchedule(10, 'Stay hydrated', 'Time for a glass of water', ...);
  }

  Future<void> scheduleMealReminder(String mealType, {required int hour, required int minute}) async {
    // await _plugin.zonedSchedule(11, 'Log your $mealType', 'Don\'t forget to track it', ...);
  }

  Future<void> scheduleExerciseReminder() async {}
  Future<void> scheduleWeightReminder() async {}
  Future<void> scheduleSleepReminder() async {}
  Future<void> scheduleDailyCheckInReminder() async {}

  // --- smart notifications (spec: notifications.smart_notifications) ---
  Future<void> missedHabitReminder(String habitName) async {
    // await _plugin.show(0, 'Missed habit', 'You haven\'t logged "$habitName" today', ...);
  }

  Future<void> lowActivityAlert() async {
    // await _plugin.show(1, 'Low activity', 'You\'re behind on today\'s step goal', ...);
  }

  Future<void> missedCheckInAlert() async {
    // await _plugin.show(4, 'Daily check-in', 'You haven\'t checked in today', ...);
  }

  // --- progress notifications (spec: notifications.progress) ---
  Future<void> celebrate(int milestonePercent) async {
    // await _plugin.show(2, 'Milestone!', 'You\'ve hit $milestonePercent% of your goal 🎉', ...);
  }

  Future<void> streakNotification(String type, int count) async {
    // await _plugin.show(3, '$type streak', 'You\'re at a $count-day streak!', ...);
  }

  Future<void> weeklyReportReady() async {}
  Future<void> monthlyReportReady() async {}
}

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

/// Phase 8: health sync. Wire to `package:health` once you can pub get.
class HealthSyncController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // final health = Health();
    // final steps = await health.getTotalStepsInInterval(...);
    // ref.read(stepsControllerProvider.notifier).syncFromHealth(steps ?? 0);
  }
}

final healthSyncControllerProvider = AsyncNotifierProvider<HealthSyncController, void>(HealthSyncController.new);
