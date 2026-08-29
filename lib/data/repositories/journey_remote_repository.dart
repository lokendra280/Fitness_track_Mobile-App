import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/journey_goal.dart';
import '../models/personal_profile.dart';
import '../models/ai_plan.dart';

class JourneyRemoteRepository {
  final SupabaseClient _client = Supabase.instance.client;
  static const _table = 'journey_profiles';

  Future<Map<String, dynamic>?> fetchRow(String userId) {
    return _client.from(_table).select().eq('user_id', userId).maybeSingle();
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
}
