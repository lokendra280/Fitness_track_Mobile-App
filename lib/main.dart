import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/constants/supabase_config.dart';
import 'package:habitflow/core/utils/widget_data_service.dart';
import 'package:habitflow/data/repositories/challenge_repository.dart';
import 'package:habitflow/data/repositories/goal_repository.dart';
import 'package:habitflow/data/repositories/habit_repository.dart';
import 'package:habitflow/data/repositories/mood_repository.dart';
import 'package:habitflow/data/repositories/reminder_repository.dart';
import 'package:habitflow/presentation/providers/providers.dart';
import 'package:habitflow/presentation/screens/splash_page.dart';
import 'package:home_widget/home_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/theme/app_theme.dart';
import 'core/utils/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _widgetBackgroundCallback(Uri? uri) async {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    debug: false,
  );

  await HabitRepository.init();
  await ReminderRepository.init();
  await ChallengeRepository.init();
  await GoalRepository.init();
  await MoodRepository.init();

  tz.initializeTimeZones();
  await NotificationService.init();
  await NotificationService.requestPermission();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const ProviderScope(child: HabitFlowApp()));
}

class HabitFlowApp extends ConsumerStatefulWidget {
  const HabitFlowApp({super.key});

  @override
  ConsumerState<HabitFlowApp> createState() => _HabitFlowAppState();
}

class _HabitFlowAppState extends ConsumerState<HabitFlowApp> {
  @override
  void initState() {
    super.initState();
    // Defer until after first frame so native plugin channels are ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _initHomeWidget());
  }

  Future<void> _initHomeWidget() async {
    try {
      await HomeWidget.registerBackgroundCallback(_widgetBackgroundCallback);
      await WidgetDataService.init();
      HomeWidget.widgetClicked.listen((uri) {
        if (uri == null) return;
        debugPrint('[HomeWidget] tapped: $uri');
      });
    } on MissingPluginException {
      // Native side not linked yet (first run / simulator / no widget setup).
      // App works normally — widget features just aren't active.
      debugPrint('[HomeWidget] Plugin not available — skipping.');
    } catch (e) {
      debugPrint('[HomeWidget] Init error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'HabitFlow',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const LoadingSplash(),
    );
  }
}
