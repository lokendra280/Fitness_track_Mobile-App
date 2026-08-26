import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/router/app_router.dart';
import 'package:habitflow/core/theme/app_theme.dart';

class WeightLossJourneyApp extends ConsumerWidget {
  const WeightLossJourneyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Weight Loss Journey',
      theme: AppTheme.light,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
