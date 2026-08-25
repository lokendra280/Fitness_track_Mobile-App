import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/features/food_tracking/bar_code_scanner.dart';
import 'package:habitflow/features/splash/splash_screen.dart';
import 'package:habitflow/features/steps/ui/step_count_screen.dart';
import 'features/journey_setup/screens/journey_setup_screen.dart';
import 'features/personal_profile/screens/personal_profile_screen.dart';
import 'features/ai_plan/screens/ai_plan_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/food_tracking/food_tracking_screen.dart';
import 'features/water_tracking/water_tracking_screen.dart';
import 'features/activity_tracking/activity_tracking_screen.dart';
import 'features/sleep_tracking/sleep_tracking_screen.dart';
import 'features/body_progress/body_progress_screen.dart';
import 'features/habit_tracking/habit_tracking_screen.dart';
import 'features/daily_check_in/daily_check_in_screen.dart';
import 'features/ai_daily_review/ai_daily_review_screen.dart';
import 'features/ai_coach/ai_coach_screen.dart';
import 'features/weekly_review/review_screens.dart';
import 'features/milestones/milestones_screen.dart';
import 'features/journey_completion/journey_completion_screen.dart';
import 'core/privacy/consent_provider.dart';

class WeightLossJourneyApp extends StatelessWidget {
  final String initialLocation;

  const WeightLossJourneyApp({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
            path: '/journey-setup',
            builder: (_, __) => const JourneySetupScreen()),
        GoRoute(
            path: '/personal-profile',
            builder: (_, __) => const PersonalProfileScreen()),
        GoRoute(path: '/ai-plan', builder: (_, __) => const AiPlanScreen()),
        GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
        GoRoute(
            path: '/dashboard', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/food', builder: (_, __) => const FoodTrackingScreen()),
        GoRoute(
            path: '/water', builder: (_, __) => const WaterTrackingScreen()),
        GoRoute(
            path: '/activity',
            builder: (_, __) => const ActivityTrackingScreen()),
        GoRoute(
            path: '/sleep', builder: (_, __) => const SleepTrackingScreen()),
        GoRoute(
            path: '/body-progress',
            builder: (_, __) => const BodyProgressScreen()),
        GoRoute(
            path: '/habits', builder: (_, __) => const HabitTrackingScreen()),
        GoRoute(
            path: '/check-in', builder: (_, __) => const DailyCheckInScreen()),
        GoRoute(
            path: '/ai-review',
            builder: (_, __) => const AiDailyReviewScreen()),
        GoRoute(path: '/ai-coach', builder: (_, __) => const AiCoachScreen()),
        GoRoute(
            path: '/weekly-review',
            builder: (_, __) => const WeeklyReviewScreen()),
        GoRoute(
            path: '/monthly-review',
            builder: (_, __) => const MonthlyReviewScreen()),
        GoRoute(
            path: '/milestones', builder: (_, __) => const MilestonesScreen()),
        GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
        GoRoute(
            path: '/journey-completion',
            builder: (_, __) => const JourneyCompletionScreen()),
        GoRoute(
          path: '/step-counter',
          builder: (_, __) => const StepCounterScreen(),
        ),
        GoRoute(
          path: '/barcode',
          builder: (_, __) => BarcodeScannerScreen(
            day: DateTime.now(),
          ),
        ),
        GoRoute(
            path: '/privacy',
            builder: (_, __) => const PrivacySettingsScreen()),
      ],
    );

    return MaterialApp.router(
      title: 'Weight Loss Journey',
      theme: AppTheme.light,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
