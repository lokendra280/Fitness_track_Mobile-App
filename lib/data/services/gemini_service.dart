import 'dart:convert';
import 'package:habitflow/data/services/plan_calculator.dart';
import 'package:http/http.dart' as http;
import '../models/journey_goal.dart';
import '../models/personal_profile.dart';
import '../models/ai_plan.dart';
import '../models/tracking_models.dart';

/// Wraps the Gemini API's `generateContent` endpoint and asks it to return
/// strict JSON matching [AiPlan]'s shape. Swap [apiKey] for a value pulled
/// from --dart-define or a secrets manager before shipping — never commit it.
class GeminiService {
  final String apiKey;
  final String model;

  GeminiService({required this.apiKey, this.model = 'gemini-flash-latest'});

  Uri get _endpoint => Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey');

  Future<AiPlan> generatePlan({
    required JourneyGoal goal,
    required PersonalProfile profile,
  }) async {
    final weightKg =
        PlanCalculator.kgFrom(goal.currentWeight ?? 0, goal.weightUnit);
    final heightCm =
        PlanCalculator.cmFrom(profile.height ?? 0, profile.heightUnit);
    final bmrValue = PlanCalculator.bmr(
        weightKg: weightKg,
        heightCm: heightCm,
        age: profile.age ?? 0,
        gender: profile.gender ?? '');
    final tdeeValue = PlanCalculator.tdee(
        bmr: bmrValue, activityLevel: profile.activityLevel ?? '');
    final calorieTargetValue =
        PlanCalculator.calorieTarget(tdee: tdeeValue, goalType: goal.type);
    final waterTargetValue = PlanCalculator.waterTargetMl(
        weightKg: weightKg, activityLevel: profile.activityLevel ?? '');
    final stepTargetValue = PlanCalculator.stepTarget(
        activityLevel: profile.activityLevel ?? '', goalType: goal.type);

    final prompt = _buildPrompt(
      goal,
      profile,
      calorieTarget: calorieTargetValue,
      waterTarget: waterTargetValue,
      stepTarget: stepTargetValue,
    );

    final response = await http.post(
      _endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0.4,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw GeminiServiceException(
          'Gemini request failed (${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final text =
        decoded['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
    if (text == null) {
      throw GeminiServiceException(
          'Gemini response had no text content: ${response.body}');
    }

    final Map<String, dynamic> planJson;
    try {
      planJson = jsonDecode(text) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw GeminiServiceException(
          'Gemini returned non-JSON output: $e\n$text');
    }

    // Deterministic values always win over whatever the model echoed back —
    // never trust unverified LLM arithmetic for numbers that gate real behavior.
    planJson['calorieTarget'] = calorieTargetValue;
    planJson['waterTarget'] = waterTargetValue;
    planJson['stepTarget'] = stepTargetValue;

    return AiPlan.fromJson(planJson);
  }

  String _buildPrompt(
    JourneyGoal goal,
    PersonalProfile profile, {
    required int calorieTarget,
    required int waterTarget,
    required int stepTarget,
  }) {
    return '''
You are a fitness and nutrition planning assistant. This is general wellness
guidance, not medical advice.

These daily numeric targets have already been calculated using standard
formulas — return them in your JSON EXACTLY as given, do not recalculate them:
- calorieTarget: $calorieTarget
- waterTarget: $waterTarget
- stepTarget: $stepTarget

User goal:
- type: ${goal.type}
- starting weight: ${goal.startingWeight} ${goal.weightUnit}
- current weight: ${goal.currentWeight} ${goal.weightUnit}
- target weight: ${goal.targetWeight} ${goal.weightUnit}
- target date: ${goal.targetDate?.toIso8601String()}

User profile:
- age: ${profile.age}
- gender: ${profile.gender}
- height: ${profile.height} ${profile.heightUnit}
- activity level: ${profile.activityLevel}
- fitness level: ${profile.fitnessLevel}
- diet preference: ${profile.dietPreference}
- food allergies: ${profile.foodAllergies.join(', ')}
- food restrictions: ${profile.foodRestrictions.join(', ')}

Choose 4-6 specific exercises appropriate for a "${profile.fitnessLevel}"
fitness level working toward "${goal.type}". Mix strength moves (e.g. squats,
lunges, push-ups, planks) with cardio/mobility as fits their level — assume
bodyweight/basic gym equipment unless told otherwise. Give each a concrete
sets/reps or duration.

Respond with ONLY a JSON object matching exactly this shape (no markdown
fences, no commentary):
{
  "calorieTarget": $calorieTarget,
  "waterTarget": $waterTarget,
  "stepTarget": $stepTarget,
  "exercises": [
    {"name": "<exercise name>", "sets": "<e.g. '3 sets x 12 reps' or '20 min'>", "category": "strength" | "cardio" | "mobility"}
  ],
  "exerciseFrequency": "<e.g. '3x_week'>",
  "sleepTarget": "<e.g. '7-9_hours'>",
  "mealTracking": <bool>,
  "recommendedHabits": [<3-5 short habit strings>],
  "milestones": [<3-5 short milestone strings tied to the goal>]
}
''';
  }

  /// Phase 6: plain-text summary of a day's tracked data.
  Future<String> reviewDay({
    double? weight,
    required List<FoodEntry> food,
    required int water,
    required int steps,
    required List<WorkoutEntry> workouts,
    SleepEntry? sleep,
    required List<Habit> habits,
    DailyCheckIn? checkIn,
  }) async {
    final prompt = '''
Summarize this day of health tracking data in 3-4 encouraging sentences, then
give 1-2 concrete suggestions for tomorrow. Not medical advice.
weight: $weight, water: ${water}ml, steps: $steps,
food: ${food.map((f) => '${f.name} (${f.calories}kcal)').join(', ')},
workouts: ${workouts.map((w) => '${w.type} ${w.minutes}min').join(', ')},
sleep: ${sleep?.hours}h, habits done: ${habits.where((h) => h.completedToday).length}/${habits.length},
mood/energy/stress: ${checkIn?.mood}/${checkIn?.energy}/${checkIn?.stress}
''';
    return _plainTextRequest(prompt);
  }

  /// Phase 6: AI coach chat turn.
  Future<String> chat(
      {required List<ChatMessage> history,
      required String contextSummary}) async {
    final convo = history.map((m) => '${m.role}: ${m.content}').join('\n');
    final prompt =
        'You are a supportive weight-loss coach. Context: $contextSummary\n\nConversation so far:\n$convo\n\nRespond as the assistant, briefly and warmly. Not medical advice.';
    return _plainTextRequest(prompt);
  }

  /// Phase 7: weekly/monthly text summaries.
  Future<String> summarizeWeek(Map<String, dynamic> metrics) => _plainTextRequest(
      'Summarize this week of weight-loss tracking data in 3-4 sentences, note one strength and one area to improve: $metrics');

  Future<String> summarizeMonth(Map<String, dynamic> metrics) => _plainTextRequest(
      'Summarize this month of weight-loss tracking data in 4-5 sentences with strengths, weaknesses and recommendations: $metrics');

  Future<String> _plainTextRequest(String prompt) async {
    final response = await http.post(
      _endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {'temperature': 0.6},
      }),
    );
    if (response.statusCode != 200) {
      throw GeminiServiceException(
          'Gemini request failed (${response.statusCode}): ${response.body}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final text =
        decoded['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
    return text ?? '(no response)';
  }

  /// Phase 4b: AI food scanner — sends a photo, gets back candidate food
  /// entries. Always route results through a confirmation UI before saving.
  Future<List<FoodEntry>> detectFood(List<int> imageBytes,
      {String mimeType = 'image/jpeg'}) async {
    final prompt = '''
Identify the food(s) in this photo and estimate nutrition. Respond with ONLY
a JSON array (no markdown fences, no commentary), one object per distinct
food item visible:
[{"mealType":"snack","name":"<food name>","calories":<number>,"protein":<number>,"carbs":<number>,"fat":<number>}]
Use your best visual estimate for portion size. If nothing edible is visible, return [].
''';
    final response = await http.post(
      _endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {
                  'mime_type': mimeType,
                  'data': base64Encode(imageBytes)
                }
              },
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0.2
        },
      }),
    );

    if (response.statusCode != 200) {
      throw GeminiServiceException(
          'Gemini request failed (${response.statusCode}): ${response.body}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final text =
        decoded['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
    if (text == null) {
      throw GeminiServiceException(
          'Gemini response had no text content: ${response.body}');
    }

    final List<dynamic> list;
    try {
      list = jsonDecode(text) as List<dynamic>;
    } on FormatException catch (e) {
      throw GeminiServiceException(
          'Gemini returned non-JSON output: $e\n$text');
    }
    return list
        .map((e) => FoodEntry.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

//   String _buildPrompt(JourneyGoal goal, PersonalProfile profile) {
//     return '''
// You are a fitness and nutrition planning assistant. Based on the user profile
// below, generate a personalized daily plan. This is general wellness guidance,
// not medical advice — do not include specific calorie deficits beyond standard
// safe ranges, and never recommend losing more than 1kg/2.2lb per week.

// User goal:
// - type: ${goal.type}
// - starting weight: ${goal.startingWeight} ${goal.weightUnit}
// - current weight: ${goal.currentWeight} ${goal.weightUnit}
// - target weight: ${goal.targetWeight} ${goal.weightUnit}
// - target date: ${goal.targetDate?.toIso8601String()}

// User profile:
// - age: ${profile.age}
// - gender: ${profile.gender}
// - height: ${profile.height} ${profile.heightUnit}
// - activity level: ${profile.activityLevel}
// - fitness level: ${profile.fitnessLevel}
// - diet preference: ${profile.dietPreference}
// - food allergies: ${profile.foodAllergies.join(', ')}
// - food restrictions: ${profile.foodRestrictions.join(', ')}

// Respond with ONLY a JSON object matching exactly this shape (no markdown fences,
// no commentary):
// {
//   "waterTarget": <int, ml per day>,
//   "stepTarget": <int, steps per day>,
//   "exerciseFrequency": "<e.g. '3x_week'>",
//   "sleepTarget": "<e.g. '7-9_hours'>",
//   "mealTracking": <bool>,
//   "recommendedHabits": [<3-5 short habit strings>],
//   "milestones": [<3-5 short milestone strings tied to the goal>]
// }
// ''';
//   }
}

class GeminiServiceException implements Exception {
  final String message;
  GeminiServiceException(this.message);
  @override
  String toString() => 'GeminiServiceException: $message';
}
