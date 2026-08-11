import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/personal_profile_provider.dart';

const _activityLevels = ['sedentary', 'light', 'moderate', 'active', 'very_active'];
const _fitnessLevels = ['beginner', 'intermediate', 'advanced'];
const _diets = ['omnivore', 'vegetarian', 'vegan', 'pescatarian', 'keto', 'other'];
const _commonAllergies = ['peanuts', 'tree nuts', 'dairy', 'gluten', 'shellfish', 'eggs', 'soy'];

class PersonalProfileScreen extends ConsumerWidget {
  const PersonalProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(personalProfileControllerProvider.notifier);
    final profile = ref.watch(personalProfileControllerProvider);
    final isValid = ref.watch(personalProfileValidProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('About you')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
              onChanged: (v) {
                final age = int.tryParse(v);
                if (age != null) controller.setAge(age);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
              value: profile.gender,
              items: const ['female', 'male', 'non-binary', 'prefer not to say']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) {
                if (v != null) controller.setGender(v);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Height (${profile.heightUnit})',
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) {
                final h = double.tryParse(v);
                if (h != null) controller.setHeight(h);
              },
            ),
            const SizedBox(height: 24),
            Text('Activity level', style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 8,
              children: _activityLevels
                  .map((level) => ChoiceChip(
                        label: Text(level.replaceAll('_', ' ')),
                        selected: profile.activityLevel == level,
                        onSelected: (_) => controller.setActivityLevel(level),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Fitness level', style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 8,
              children: _fitnessLevels
                  .map((level) => ChoiceChip(
                        label: Text(level),
                        selected: profile.fitnessLevel == level,
                        onSelected: (_) => controller.setFitnessLevel(level),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Diet preference', style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 8,
              children: _diets
                  .map((d) => ChoiceChip(
                        label: Text(d),
                        selected: profile.dietPreference == d,
                        onSelected: (_) => controller.setDietPreference(d),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Food allergies', style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 8,
              children: _commonAllergies
                  .map((a) => FilterChip(
                        label: Text(a),
                        selected: profile.foodAllergies.contains(a),
                        onSelected: (_) => controller.toggleAllergy(a),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: isValid
                  ? () async {
                      await controller.submit();
                      if (context.mounted) context.go('/ai-plan');
                    }
                  : null,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
