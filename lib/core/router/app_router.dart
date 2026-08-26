import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/features/bottom_navigation/ui/bottom_page.dart';

import 'package:habitflow/features/food_tracking/bar_code_scanner.dart';
import 'package:habitflow/features/reports/pages/statistics_screen.dart';
import 'package:habitflow/features/splash/splash_screen.dart';
import 'package:habitflow/features/steps/ui/step_count_screen.dart';
import 'package:habitflow/features/journey_setup/screens/journey_setup_screen.dart';
import 'package:habitflow/features/personal_profile/screens/personal_profile_screen.dart';
import 'package:habitflow/features/ai_plan/screens/ai_plan_screen.dart';
import 'package:habitflow/features/dashboard/screens/dashboard_screen.dart';
import 'package:habitflow/features/food_tracking/food_tracking_screen.dart';
import 'package:habitflow/features/water_tracking/water_tracking_screen.dart';
import 'package:habitflow/features/activity_tracking/activity_tracking_screen.dart';
import 'package:habitflow/features/sleep_tracking/sleep_tracking_screen.dart';
import 'package:habitflow/features/body_progress/body_progress_screen.dart';
import 'package:habitflow/features/habit_tracking/habit_tracking_screen.dart';
import 'package:habitflow/features/daily_check_in/daily_check_in_screen.dart';
import 'package:habitflow/features/ai_daily_review/ai_daily_review_screen.dart';
import 'package:habitflow/features/ai_coach/ai_coach_screen.dart';
import 'package:habitflow/features/weekly_review/review_screens.dart';
import 'package:habitflow/features/milestones/milestones_screen.dart';
import 'package:habitflow/features/reports/journey_completion_screen.dart';
import 'package:habitflow/core/privacy/consent_provider.dart';

/// Route path constants — reference these instead of hardcoded strings
/// (context.push('/food') etc.) wherever possible, so a typo'd path
/// fails at compile time rather than silently 404-ing at runtime.
abstract class AppRoutes {
  AppRoutes._();

  static const journeySetup = '/journey-setup';
  static const personalProfile = '/personal-profile';
  static const aiPlan = '/ai-plan';
  static const splash = '/splash';
  static const dashboard = '/dashboard';
  static const food = '/food';
  static const water = '/water';
  static const activity = '/activity';
  static const sleep = '/sleep';
  static const bodyProgress = '/body-progress';
  static const habits = '/habits';
  static const checkIn = '/check-in';
  static const aiReview = '/ai-review';
  static const aiCoach = '/ai-coach';
  static const weeklyReview = '/weekly-review';
  static const monthlyReview = '/monthly-review';
  static const milestones = '/milestones';
  static const reports = '/reports';
  static const journeyCompletion = '/journey-completion';
  static const stepCounter = '/step-counter';
  static const barcode = '/barcode';
  static const privacy = '/privacy';
  static const bottomNavbar = '/botoomNav';
}

/// Builds the GoRouter's route table. Kept separate from the provider
/// itself so it's a plain, easily-testable function.
List<RouteBase> buildAppRoutes() {
  return [
    GoRoute(
      path: AppRoutes.journeySetup,
      builder: (_, __) => const JourneySetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.bottomNavbar,
      builder: (_, __) => const RootScaffold(),
    ),
    GoRoute(
      path: AppRoutes.personalProfile,
      builder: (_, __) => const PersonalProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.aiPlan,
      builder: (_, __) => const AiPlanScreen(),
    ),
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, __) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (_, __) => const DashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.food,
      builder: (_, __) => const FoodTrackingScreen(),
    ),
    GoRoute(
      path: AppRoutes.water,
      builder: (_, __) => const WaterTrackingScreen(),
    ),
    GoRoute(
      path: AppRoutes.activity,
      builder: (_, __) => const ActivityTrackingScreen(),
    ),
    GoRoute(
      path: AppRoutes.sleep,
      builder: (_, __) => const SleepTrackingScreen(),
    ),
    GoRoute(
      path: AppRoutes.bodyProgress,
      builder: (_, __) => const BodyProgressScreen(),
    ),
    GoRoute(
      path: AppRoutes.habits,
      builder: (_, __) => const HabitTrackingScreen(),
    ),
    GoRoute(
      path: AppRoutes.checkIn,
      builder: (_, __) => const DailyCheckInScreen(),
    ),
    GoRoute(
      path: AppRoutes.aiReview,
      builder: (_, __) => const AiDailyReviewScreen(),
    ),
    GoRoute(
      path: AppRoutes.aiCoach,
      builder: (_, __) => const AiCoachScreen(),
    ),
    GoRoute(
      path: AppRoutes.weeklyReview,
      builder: (_, __) => const WeeklyReviewScreen(),
    ),
    GoRoute(
      path: AppRoutes.monthlyReview,
      builder: (_, __) => const MonthlyReviewScreen(),
    ),
    GoRoute(
      path: AppRoutes.milestones,
      builder: (_, __) => const MilestonesScreen(),
    ),
    GoRoute(
      path: AppRoutes.reports,
      builder: (_, __) => const StatisticsScreen(),
    ),
    GoRoute(
      path: AppRoutes.journeyCompletion,
      builder: (_, __) => const JourneyCompletionScreen(),
    ),
    GoRoute(
      path: AppRoutes.stepCounter,
      builder: (_, __) => const StepCounterScreen(),
    ),
    GoRoute(
      path: AppRoutes.barcode,
      builder: (_, __) => BarcodeScannerScreen(day: DateTime.now()),
    ),
    GoRoute(
      path: AppRoutes.privacy,
      builder: (_, __) => const PrivacySettingsScreen(),
    ),
  ];
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final initialLocation = ref.watch(initialLocationProvider);
  return GoRouter(
    initialLocation: initialLocation,
    routes: buildAppRoutes(),
  );
});

final initialLocationProvider = Provider<String>((ref) {
  throw UnimplementedError(
    'initialLocationProvider must be overridden in main.dart',
  );
});
