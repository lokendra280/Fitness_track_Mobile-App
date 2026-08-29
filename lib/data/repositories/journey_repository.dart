import 'package:habitflow/data/repositories/journey_remote_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/journey_goal.dart';
import '../models/personal_profile.dart';
import '../models/ai_plan.dart';
import '../models/tracking_models.dart';

String _dk(String prefix, DateTime d) =>
    '${prefix}_${d.toIso8601String().split('T').first}';

const _kJourneyGoalKey = 'journey_goal';
const _kPersonalProfileKey = 'personal_profile';
const _kAiPlanKey = 'ai_plan';
const _kWeightLogKey = 'weight_log'; // List<{date, weight}>, newest last

/// Thin persistence layer over a single Hive box, keyed by string.
/// Phase 4+ will add typed sub-repositories (food, water, workouts, sleep,
/// body measurements) that read/write into the same box using date-prefixed
/// keys, e.g. 'food_2026-08-10'.
class JourneyRepository {
  final Box box;

  JourneyRepository({required this.box});

  static Future<JourneyRepository> open() async {
    await Hive.initFlutter();
    final box = await Hive.openBox('journey');
    return JourneyRepository(box: box);
  }

  // --- Phase 1: journey goal ---

  JourneyGoal loadGoal() {
    final raw = box.get(_kJourneyGoalKey);
    if (raw == null) return const JourneyGoal();
    return JourneyGoal.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<void> saveGoal(JourneyGoal goal) async {
    await box.put(_kJourneyGoalKey, goal.toJson());
    await _syncProfileToRemote();
  }

  /// for daily basic exercise
  Set<String> completedExercisesFor(DateTime day) {
    final raw = box.get(_dk('exercises_done', day)) as List?;
    if (raw == null) return {};
    return raw.cast<String>().toSet();
  }

  Future<void> toggleExerciseDone(DateTime day, String exerciseName) async {
    final current = completedExercisesFor(day);
    if (current.contains(exerciseName)) {
      current.remove(exerciseName);
    } else {
      current.add(exerciseName);
    }
    await box.put(_dk('exercises_done', day), current.toList());
  }
  // --- Phase 1: personal profile ---

  PersonalProfile loadProfile() {
    final raw = box.get(_kPersonalProfileKey);
    if (raw == null) return const PersonalProfile();
    return PersonalProfile.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<void> saveProfile(PersonalProfile profile) async {
    await box.put(_kPersonalProfileKey, profile.toJson());
    await _syncProfileToRemote();
  }

  /// Best-effort push to Supabase — local save always succeeds even if this
  /// fails (offline, etc.), so the app stays usable without connectivity.
  Future<void> _syncProfileToRemote() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await JourneyRemoteRepository().upsertGoalAndProfile(
        userId: userId,
        goal: loadGoal(),
        profile: loadProfile(),
      );
    } catch (_) {
      // Swallow — local Hive write already succeeded; remote will catch up
      // next time saveGoal/saveProfile runs successfully, or on next hydrate.
    }
  }

  bool get hasCompletedSetup {
    final goal = loadGoal();
    final profile = loadProfile();
    return goal.isValid && profile.isComplete;
  }

  // --- Phase 2: AI plan ---
  bool get hasGeneratedPlan => loadAiPlan() != null;

  AiPlan? loadAiPlan() {
    final raw = box.get(_kAiPlanKey);
    if (raw == null) return null;
    return AiPlan.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<void> saveAiPlan(AiPlan plan) async {
    await box.put(_kAiPlanKey, plan.toJson());
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await JourneyRemoteRepository().upsertPlan(userId: userId, plan: plan);
    } catch (_) {
      // Same best-effort policy as _syncProfileToRemote.
    }
  }

  Future<void> clearAiPlan() => box.delete(_kAiPlanKey);

  // --- Phase 3: weight log (feeds the dashboard) ---

  List<Map<String, dynamic>> _rawWeightLog() {
    final raw = box.get(_kWeightLogKey) as List?;
    if (raw == null) return [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> logWeight(double weight, {DateTime? date}) async {
    final entries = _rawWeightLog();
    entries.add(
        {'date': (date ?? DateTime.now()).toIso8601String(), 'weight': weight});
    await box.put(_kWeightLogKey, entries);
    await saveGoal(loadGoal().copyWith(currentWeight: weight));
  }

  double? latestLoggedWeight() {
    final entries = _rawWeightLog();
    if (entries.isEmpty) return null;
    return (entries.last['weight'] as num).toDouble();
  }

  int? get daysRemaining {
    final target = loadGoal().targetDate;
    if (target == null) return null;
    final diff = target.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  // --- Phase 4: food ---
  List<FoodEntry> foodEntriesFor(DateTime day) =>
      ((box.get(_dk('food', day)) as List?) ?? [])
          .map((e) => FoodEntry.fromJson(Map.from(e)))
          .toList();
  Future<void> saveFoodEntry(DateTime day, FoodEntry e) async {
    final list = foodEntriesFor(day)..add(e);
    await box.put(_dk('food', day), list.map((e) => e.toJson()).toList());
  }

  // --- Phase 4: water (ml) ---
  int waterFor(DateTime day) => (box.get(_dk('water', day)) as int?) ?? 0;
  Future<void> saveWater(DateTime day, int ml) =>
      box.put(_dk('water', day), ml);

  // --- Phase 4: workouts ---
  List<WorkoutEntry> workoutsFor(DateTime day) =>
      ((box.get(_dk('workouts', day)) as List?) ?? [])
          .map((e) => WorkoutEntry.fromJson(Map.from(e)))
          .toList();
  Future<void> logWorkout(DateTime day, WorkoutEntry w) async {
    final list = workoutsFor(day)..add(w);
    await box.put(_dk('workouts', day), list.map((e) => e.toJson()).toList());
  }

  int stepsFor(DateTime day) => (box.get(_dk('steps', day)) as int?) ?? 0;
  Future<void> saveSteps(DateTime day, int steps) =>
      box.put(_dk('steps', day), steps);

  // --- Phase 4: sleep ---
  SleepEntry? sleepFor(DateTime day) {
    final raw = box.get(_dk('sleep', day));
    return raw == null ? null : SleepEntry.fromJson(Map.from(raw));
  }

  Future<void> saveSleep(DateTime day, SleepEntry s) =>
      box.put(_dk('sleep', day), s.toJson());

  // --- Phase 4: body measurements ---
  List<BodyMeasurement> measurements() =>
      ((box.get('measurements') as List?) ?? [])
          .map((e) => BodyMeasurement.fromJson(Map.from(e)))
          .toList();
  Future<void> addMeasurement(BodyMeasurement m) async {
    final list = measurements()..add(m);
    await box.put('measurements', list.map((e) => e.toJson()).toList());
  }

  // --- Phase 5: habits ---
  List<Habit> habits() => ((box.get('habits') as List?) ?? [])
      .map((e) => Habit.fromJson(Map.from(e)))
      .toList();
  Future<void> saveHabits(List<Habit> list) =>
      box.put('habits', list.map((e) => e.toJson()).toList());

  DailyCheckIn? checkInFor(DateTime day) {
    final raw = box.get(_dk('checkin', day));
    return raw == null ? null : DailyCheckIn.fromJson(Map.from(raw));
  }

  Future<void> saveCheckIn(DateTime day, DailyCheckIn c) =>
      box.put(_dk('checkin', day), c.toJson());

  // --- Phase 6: AI coach chat history ---
  List<ChatMessage> chatHistory() => ((box.get('chat_history') as List?) ?? [])
      .map((e) => ChatMessage.fromJson(Map.from(e)))
      .toList();
  Future<void> saveChatHistory(List<ChatMessage> list) =>
      box.put('chat_history', list.map((e) => e.toJson()).toList());

  // --- Phase 7: milestones & streaks ---
  List<Milestone> achievedMilestones() =>
      ((box.get('milestones') as List?) ?? [])
          .map((e) => Milestone.fromJson(Map.from(e)))
          .toList();
  Future<void> addMilestone(Milestone m) async {
    final list = achievedMilestones()..add(m);
    await box.put('milestones', list.map((e) => e.toJson()).toList());
  }

  Map<String, int> streaks() =>
      Map<String, int>.from(box.get('streaks') as Map? ?? {});
  Future<void> saveStreaks(Map<String, int> streaks) =>
      box.put('streaks', streaks);

  DateTime? lastActiveDateFor(String type) {
    final raw = box.get('last_active_$type');
    return raw == null ? null : DateTime.parse(raw as String);
  }

  /// Generalized daily streak counter — pass a type from:
  /// journey, habit, meal_tracking, exercise, water, weekly_consistency.
  Future<void> recordActivity(String type) async {
    final today = DateTime.now();
    final last = lastActiveDateFor(type);
    final s = Map<String, int>.from(streaks());
    if (last == null) {
      s[type] = 1;
    } else {
      final gap = DateTime(today.year, today.month, today.day)
          .difference(DateTime(last.year, last.month, last.day))
          .inDays;
      if (gap == 1) {
        s[type] = (s[type] ?? 0) + 1;
      } else if (gap > 1) {
        s[type] = 1;
      }
    }
    await box.put('last_active_$type', today.toIso8601String());
    await saveStreaks(s);
  }

  Future<void> recordActivityToday() => recordActivity('journey');

  // --- Phase 4: progress photos (private local paths only) ---
  List<ProgressPhoto> progressPhotos() =>
      ((box.get('progress_photos') as List?) ?? [])
          .map((e) => ProgressPhoto.fromJson(Map.from(e)))
          .toList();
  Future<void> addProgressPhoto(ProgressPhoto p) async {
    final list = progressPhotos()..add(p);
    await box.put('progress_photos', list.map((e) => e.toJson()).toList());
  }

  // --- Phase 4: food search history / favorites ---
  List<String> recentFoodNames() =>
      ((box.get('recent_foods') as List?) ?? []).cast<String>();
  Future<void> recordRecentFood(String name) async {
    final list = recentFoodNames().where((n) => n != name).toList()
      ..insert(0, name);
    await box.put('recent_foods', list.take(20).toList());
  }

  List<String> favoriteFoodNames() =>
      ((box.get('favorite_foods') as List?) ?? []).cast<String>();
  Future<void> toggleFavoriteFood(String name) async {
    final list = favoriteFoodNames();
    list.contains(name) ? list.remove(name) : list.add(name);
    await box.put('favorite_foods', list);
  }

  // --- Phase 9: journey completion ---
  bool get isCompleted => (box.get('journey_completed') as bool?) ?? false;
  Future<void> markCompleted() => box.put('journey_completed', true);

  // --- Phase 10: consent ---
  bool get hasHealthDataConsent =>
      (box.get('consent_health') as bool?) ?? false;
  bool get hasAiDataConsent => (box.get('consent_ai') as bool?) ?? false;
  Future<void> setConsent({bool? health, bool? ai}) async {
    if (health != null) await box.put('consent_health', health);
    if (ai != null) await box.put('consent_ai', ai);
  }
}
