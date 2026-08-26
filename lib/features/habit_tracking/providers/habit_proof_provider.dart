import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What kind of proof a habit's category calls for, inferred from the
/// habit's name until there's a real `category`/`proofType` field on
/// your Habit model to key off instead.
enum HabitProofType { none, photo, waterGlasses }

@immutable
class HabitProof {
  final String? photoPath;
  final int? glassesFilled;
  final DateTime capturedAt;

  const HabitProof(
      {this.photoPath, this.glassesFilled, required this.capturedAt});
}

/// In-memory only for now — keyed by habit name. Survives navigation
/// within the app session but not a restart.
///
/// TODO: once you share your JourneyRepository / Habit model, this
/// should write through to persistent storage (e.g.
/// `repo.saveHabitProof(habitName, proof)`) the same way
/// `FoodLogController.addEntry` calls `repo.saveFoodEntry`, so proof
/// survives app restarts and can show up in a history/streak view.
final habitProofProvider = StateProvider<Map<String, HabitProof>>((ref) => {});

/// Best-effort category inference from the habit's name. Replace this
/// with a real `habit.category` check once that field exists — string
/// matching is a stopgap, not something to keep long-term (fails for
/// custom habit names the user types themselves, e.g. "Yoga" or "Bike
/// ride" won't match unless added to the keyword lists below).
HabitProofType inferProofType(String habitName) {
  final n = habitName.toLowerCase();

  const photoKeywords = [
    'exercise',
    'workout',
    'walk',
    'run',
    'gym',
    'strength',
    'cardio',
    'stretch',
    'yoga',
    'jog',
  ];
  const waterKeywords = ['water', 'hydrat', 'drink'];

  if (waterKeywords.any(n.contains)) return HabitProofType.waterGlasses;
  if (photoKeywords.any(n.contains)) return HabitProofType.photo;
  return HabitProofType.none;
}
