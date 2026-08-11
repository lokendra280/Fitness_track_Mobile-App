// import 'dart:convert';
// import 'package:habitflow/domain/entities/mood_entity.dart';
// import 'package:home_widget/home_widget.dart';
// import 'package:habitflow/data/repositories/habit_repository.dart';
// import 'package:habitflow/data/repositories/mood_repository.dart';

// class WidgetDataService {
//   static const _appGroup = 'group.com.yourcompany.habitflow';
//   static const _iOSWidget = 'HabitFlowWidget';

//   static Future<void> init() async {
//     await HomeWidget.setAppGroupId(_appGroup);
//   }

//   /// Call this every time habits, checkins, or mood changes.
//   static Future<void> pushToWidget({
//     required HabitRepository habitRepo,
//     required MoodRepository moodRepo,
//   }) async {
//     final habits = habitRepo.getHabits();
//     final today = habitRepo.getTodayCheckins();
//     final streak = habits.isEmpty
//         ? 0
//         : habits
//             .map((h) => habitRepo.calculateStreak(h.id).currentStreak)
//             .reduce((a, b) => a > b ? a : b);
//     final done = habits
//         .where((h) =>
//             habitRepo.getTodayCheckins(habitId: h.id).length >= h.targetPerDay)
//         .length;
//     final todayMood = moodRepo.getToday();

//     // Build a compact JSON payload
//     final payload = jsonEncode({
//       'streak': streak,
//       'done': done,
//       'total': habits.length,
//       'mood_emoji': todayMood?.level.emoji ?? '',
//       'mood_label': todayMood?.level.label ?? '',
//       // Top 4 habits for the medium widget
//       'habits': habits.take(4).map((h) {
//         final cnt = habitRepo.getTodayCheckins(habitId: h.id).length;
//         return {
//           'name': h.name,
//           'icon': h.icon,
//           'done': cnt,
//           'target': h.targetPerDay,
//           'complete': cnt >= h.targetPerDay,
//         };
//       }).toList(),
//     });

//     await HomeWidget.saveWidgetData<String>('habitflow_data', payload);
//     await HomeWidget.updateWidget(
//       iOSName: _iOSWidget,
//       androidName: 'HabitFlowWidgetProvider',
//     );
//   }
// }
