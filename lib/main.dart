import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/app.dart';
import 'package:habitflow/core/constants/supabase_config.dart';
import 'package:habitflow/core/router/app_router.dart';
import 'package:habitflow/data/repositories/journey_repository.dart';
import 'package:habitflow/data/repositories/journey_repository_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await JourneyRepository.open();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    debug: false, // flip to true during development
  );
  runApp(
    ProviderScope(
      overrides: [
        journeyRepositoryProvider.overrideWithValue(repository),
        initialLocationProvider.overrideWithValue(
          repository.hasCompletedSetup ? '/splash' : '/journey-setup',
        ),
      ],
      child: const WeightLossJourneyApp(),
    ),
  );
}
