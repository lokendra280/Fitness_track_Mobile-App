import 'dart:io';

import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

enum HealthAccessStatus {
  authorized,
  denied,
  healthConnectNotInstalled, // Android only
  activityRecognitionDenied, // Android only
  unavailable, // platform doesn't support health data at all
}

class StepCountController {
  StepCountController._();
  static final instance = StepCountController._();

  final Health _health = Health();
  bool _configured = false;

  static final _types = [HealthDataType.STEPS];
  static final _permissions = [HealthDataAccess.READ];

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  /// Full pre-flight + request flow. Call this from a button
  /// ("Connect to Health Connect / Apple Health"), not silently
  /// on every app launch — see note below.
  Future<HealthAccessStatus> requestAccess() async {
    await _ensureConfigured();

    if (Platform.isAndroid) {
      // 1. Health Connect must be installed on Android < 14.
      final availability = await _health.getHealthConnectSdkStatus();
      if (availability != HealthConnectSdkStatus.sdkAvailable) {
        return HealthAccessStatus.healthConnectNotInstalled;
      }

      // 2. Health Connect silently no-ops if ACTIVITY_RECOGNITION
      // hasn't been granted as a normal Android runtime permission first.
      final activityStatus = await Permission.activityRecognition.request();
      if (!activityStatus.isGranted) {
        return HealthAccessStatus.activityRecognitionDenied;
      }
    }

    // 3. Don't trust hasPermissions() as a gate before requesting —
    // it's known to return false negatives/positives on some OS
    // versions. Just attempt the request; the OS itself no-ops if
    // already granted.
    final granted = await _health.requestAuthorization(
      _types,
      permissions: _permissions,
    );

    return granted ? HealthAccessStatus.authorized : HealthAccessStatus.denied;
  }

  /// Cheap check for "should I show a connect button or the data?"
  /// Still not 100% reliable on Android per plugin docs, so treat a
  /// `false` here as "unknown" rather than "definitely denied" —
  /// only requestAccess() gives you a real answer.
  Future<bool> hasAccess() async {
    await _ensureConfigured();
    final has = await _health.hasPermissions(_types, permissions: _permissions);
    return has ?? false;
  }

  Future<int?> fetchTodaySteps() async {
    await _ensureConfigured();

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    try {
      final steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps;
    } catch (e) {
      // Common cause: permission was revoked in system settings after
      // the app already thought it was authorized.
      return null;
    }
  }

  /// Steps for any single calendar day (not just today). Used by the
  /// dashboard/step-counter screen when the user navigates to a past date.
  Future<int?> fetchStepsForDate(DateTime date) async {
    await _ensureConfigured();

    final start = DateTime(date.year, date.month, date.day);
    final end = start
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    try {
      final steps = await _health.getTotalStepsInInterval(start, end);
      return steps;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, int>> fetchWeeklySteps({DateTime? endDate}) async {
    final end = endDate ?? DateTime.now();
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final startOfWeek = end.subtract(Duration(days: end.weekday - 1));

    final results = <String, int>{};
    for (var i = 0; i < 7; i++) {
      final day = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)
          .add(Duration(days: i));
      results[labels[i]] = await fetchStepsForDate(day) ?? 0;
    }
    return results;
  }

  Future<void> openHealthConnectInstall() async {
    if (!Platform.isAndroid) return;
    await _health.installHealthConnect();
  }
}
