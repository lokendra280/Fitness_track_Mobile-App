import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/data/repositories/journey_repository_provider.dart';
import 'package:habitflow/features/auth/ui/sign_in_screen.dart';
import 'package:habitflow/features/auth/ui/sign_up_screen.dart';
import 'package:habitflow/features/auth/ui/verify_otp_screen.dart';
import 'package:habitflow/features/bottom_navigation/ui/bottom_page.dart';

import 'package:habitflow/features/food_tracking/bar_code_scanner.dart';
import 'package:habitflow/features/onboarding/pages/onboarding_screen.dart';
import 'package:habitflow/features/onboarding/services/onboarding_prefs.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';

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
  static const signIn = '/sign-In';
  static const signUp = '/sign-up';
  static const oneBoarding = '/onBoarding';
  static const verifyOtp = '/verify-opt';
}

List<RouteBase> buildAppRoutes() {
  return [
    GoRoute(
      path: AppRoutes.oneBoarding,
      builder: (context, __) => OnboardingScreen(
        onFinished: () async {
          await OnboardingPrefs.markCompleted();
          if (context.mounted) {
            context.go(AppRoutes.bottomNavbar);
          }
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.signIn,
      builder: (_, __) => const SignInScreen(),
    ),
    GoRoute(
      path: AppRoutes.verifyOtp,
      builder: (_, __) => const VerifyOtpScreen(),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      builder: (_, __) => const SignUpScreen(),
    ),
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
      builder: (_, __) => const ProfileScreen(),
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
  final journeyRepository = ref.watch(journeyRepositoryProvider);

  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    redirect: (context, state) async {
      final location = state.matchedLocation;
      final isOnSplash = location == AppRoutes.splash;

      if (isOnSplash) return null;

      final hasCompletedOnboarding =
          await OnboardingPrefs.hasCompletedOnboarding();
      final isSignedIn = Supabase.instance.client.auth.currentSession != null;

      final hasCompletedSetup = journeyRepository.hasCompletedSetup;
      final hasGeneratedPlan = journeyRepository.hasGeneratedPlan;

      final isOnOnboarding = location == AppRoutes.oneBoarding;
      final isOnSignIn = location == AppRoutes.signIn;
      final isOnSignUp = location == AppRoutes.signUp;
      final isOnVerifyOtp = location == AppRoutes.verifyOtp;

      const setupFlowRoutes = {
        AppRoutes.journeySetup,
        AppRoutes.personalProfile,
        AppRoutes.aiPlan,
      };
      final isOnSetupFlow = setupFlowRoutes.contains(location);
      final isOnPersonalProfileOrEarlier = location == AppRoutes.journeySetup ||
          location == AppRoutes.personalProfile;

      // Gate 1: onboarding, always first.
      if (!hasCompletedOnboarding) {
        return isOnOnboarding ? null : AppRoutes.oneBoarding;
      }

      // Gate 2: must be signed in.
      if (!isSignedIn) {
        return (isOnSignIn || isOnSignUp || isOnVerifyOtp)
            ? null
            : AppRoutes.signIn;
      }

      // Gate 3: must have completed journey setup. Allow the whole
      // setup flow through, not just the entry screen — otherwise
      // step 2/3 immediately bounce back to step 1 on every push.
      if (!hasCompletedSetup) {
        return isOnPersonalProfileOrEarlier ? null : AppRoutes.journeySetup;
      }
      if (!hasGeneratedPlan) {
        return location == AppRoutes.aiPlan ? null : AppRoutes.aiPlan;
      }

      // All gates passed: don't let the user land back on an intro screen.
      if (isOnOnboarding ||
          isOnSignIn ||
          isOnSignUp ||
          isOnVerifyOtp ||
          isOnSetupFlow) {
        return AppRoutes.bottomNavbar;
      }

      return null;
    },
    routes: buildAppRoutes(),
  );
});

final initialLocationProvider = Provider<String>((ref) {
  throw UnimplementedError(
    'initialLocationProvider must be overridden in main.dart',
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
