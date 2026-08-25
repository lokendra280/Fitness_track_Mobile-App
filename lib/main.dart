import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/app.dart';
import 'package:habitflow/data/repositories/journey_repository.dart';
import 'package:habitflow/data/repositories/journey_repository_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await JourneyRepository.open();
  await dotenv.load(fileName: ".env");

  runApp(
    ProviderScope(
      overrides: [
        journeyRepositoryProvider.overrideWithValue(repository),
      ],
      child: WeightLossJourneyApp(
        initialLocation:
            repository.hasCompletedSetup ? '/splash' : '/journey-setup',
      ),
    ),
  );
}
