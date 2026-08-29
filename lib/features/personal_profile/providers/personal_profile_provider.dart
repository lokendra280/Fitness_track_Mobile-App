import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/personal_profile.dart';
import '../../../data/repositories/journey_repository_provider.dart';
import '../../journey_setup/providers/journey_setup_provider.dart';

class PersonalProfileController extends Notifier<PersonalProfile> {
  @override
  PersonalProfile build() => ref.read(journeyRepositoryProvider).loadProfile();

  void setAge(int age) => state = state.copyWith(age: age);
  void setGender(String gender) => state = state.copyWith(gender: gender);
  void setHeight(double height, {String? unit}) => state =
      state.copyWith(height: height, heightUnit: unit ?? state.heightUnit);
  void setActivityLevel(String level) =>
      state = state.copyWith(activityLevel: level);
  void setFitnessLevel(String level) =>
      state = state.copyWith(fitnessLevel: level);
  void setDietPreference(String diet) =>
      state = state.copyWith(dietPreference: diet);

  void toggleAllergy(String allergy) {
    final list = List<String>.from(state.foodAllergies);
    list.contains(allergy) ? list.remove(allergy) : list.add(allergy);
    state = state.copyWith(foodAllergies: list);
  }

  void toggleRestriction(String restriction) {
    final list = List<String>.from(state.foodRestrictions);
    list.contains(restriction)
        ? list.remove(restriction)
        : list.add(restriction);
    state = state.copyWith(foodRestrictions: list);
  }

  Future<void> submit() async {
    await ref.read(journeyRepositoryProvider).saveProfile(state);

    try {
      final goal = ref.read(journeySetupControllerProvider);
      await ref.read(journeySupabaseServiceProvider).syncProfile(
            goal: goal,
            profile: state,
          );
    } catch (_) {}
  }
}

final personalProfileControllerProvider =
    NotifierProvider<PersonalProfileController, PersonalProfile>(
        PersonalProfileController.new);

final personalProfileValidProvider = Provider<bool>((ref) {
  return ref.watch(personalProfileControllerProvider).isComplete;
});
