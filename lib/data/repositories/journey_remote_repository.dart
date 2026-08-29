import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/journey_goal.dart';
import '../models/personal_profile.dart';
import '../models/ai_plan.dart';

/// Supabase-backed mirror of the local Hive data in JourneyRepository.
/// Supabase is treated as the source of truth: on sign-in, if a remote row
/// exists, it hydrates the local box so a returning user never re-does
/// onboarding on a fresh device/install.
class JourneyRemoteRepository {
  final SupabaseClient _client = Supabase.instance.client;
  static const _table = 'journey_profiles';

  Future<Map<String, dynamic>?> fetchRow(String userId) {
    return _client.from(_table).select().eq('user_id', userId).maybeSingle();
  }

  /// that has never synced).
  Future<
      ({
        JourneyGoal goal,
        PersonalProfile profile,
        AiPlan? aiPlan,
      })?> fetchProfile({required String userId}) async {
    final row = await fetchRow(userId);
    if (row == null) return null;

    return (
      goal: _goalFromRow(row),
      profile: _profileFromRow(row),
      aiPlan: _planFromRow(row),
    );
  }

  Future<void> upsertGoalAndProfile({
    required String userId,
    required JourneyGoal goal,
    required PersonalProfile profile,
  }) async {
    await _client.from(_table).upsert({
      'user_id': userId,
      'type': goal.type,
      'starting_weight': goal.startingWeight,
      'current_weight': goal.currentWeight,
      'target_weight': goal.targetWeight,
      'weight_unit': goal.weightUnit,
      'start_date': goal.startDate?.toIso8601String(),
      'target_date': goal.targetDate?.toIso8601String(),
      'age': profile.age,
      'gender': profile.gender,
      'height': profile.height,
      'height_unit': profile.heightUnit,
      'activity_level': profile.activityLevel,
      'fitness_level': profile.fitnessLevel,
      'diet_preference': profile.dietPreference,
      'food_allergies': profile.foodAllergies,
      'food_restrictions': profile.foodRestrictions,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> upsertPlan({
    required String userId,
    required AiPlan plan,
  }) async {
    await _client.from(_table).update({
      'ai_plan': plan.toJson(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId);
  }

  // ---------------------------------------------------------------------
  // Row parsing helpers — turn a raw Supabase row map into typed models.
  // Kept private to this file since fetchRow() intentionally returns a
  // raw map rather than the models parsing themselves.
  // ---------------------------------------------------------------------

  JourneyGoal _goalFromRow(Map<String, dynamic> row) => JourneyGoal(
        type: row['type'] as String? ?? 'lose_weight',
        startingWeight: (row['starting_weight'] as num?)?.toDouble(),
        currentWeight: (row['current_weight'] as num?)?.toDouble(),
        targetWeight: (row['target_weight'] as num?)?.toDouble(),
        weightUnit: row['weight_unit'] as String? ?? 'kg',
        startDate: row['start_date'] != null
            ? DateTime.parse(row['start_date'] as String)
            : null,
        targetDate: row['target_date'] != null
            ? DateTime.parse(row['target_date'] as String)
            : null,
      );

  PersonalProfile _profileFromRow(Map<String, dynamic> row) => PersonalProfile(
        age: row['age'] as int?,
        gender: row['gender'] as String?,
        height: (row['height'] as num?)?.toDouble(),
        heightUnit: row['height_unit'] as String? ?? 'cm',
        activityLevel: row['activity_level'] as String?,
        fitnessLevel: row['fitness_level'] as String?,
        dietPreference: row['diet_preference'] as String?,
        foodAllergies:
            (row['food_allergies'] as List?)?.cast<String>() ?? const [],
        foodRestrictions:
            (row['food_restrictions'] as List?)?.cast<String>() ?? const [],
      );

  AiPlan? _planFromRow(Map<String, dynamic> row) {
    final planJson = row['ai_plan'] as Map<String, dynamic>?;
    if (planJson == null) return null;
    return AiPlan.fromJson(planJson);
  }
}
