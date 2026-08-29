import 'package:habitflow/data/models/journey_goal.dart';
import 'package:habitflow/data/models/personal_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JourneySupabaseException implements Exception {
  final String message;
  JourneySupabaseException(this.message);
  @override
  String toString() => 'JourneySupabaseException: $message';
}

class JourneySupabaseService {
  final SupabaseClient _client;
  JourneySupabaseService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<void> syncProfile({
    required JourneyGoal goal,
    required PersonalProfile profile,
  }) async {
    final userId = _userId;
    if (userId == null) return;

    final row = {
      ...goal.toSupabaseRow(userId),
      ...profile.toSupabaseRow(),
    };

    try {
      await _client.from('journey_profiles').upsert(row);
    } on PostgrestException catch (e) {
      throw JourneySupabaseException('Failed to sync profile: ${e.message}');
    }
  }

  Future<({JourneyGoal goal, PersonalProfile profile})?> fetchProfile() async {
    final userId = _userId;
    if (userId == null) return null;

    try {
      final row = await _client
          .from('journey_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (row == null) return null;

      return (
        goal: JourneyGoal.fromSupabaseRow(row),
        profile: PersonalProfile.fromSupabaseRow(row),
      );
    } on PostgrestException catch (e) {
      throw JourneySupabaseException('Failed to fetch profile: ${e.message}');
    }
  }
}
