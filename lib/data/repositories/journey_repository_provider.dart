import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'journey_repository.dart';

/// Deliberately left unimplemented at declaration time — `main.dart` awaits
/// `JourneyRepository.open()` before `runApp` and overrides this provider
/// with the real instance. This avoids every screen having to unwrap an
/// AsyncValue just to read local storage.
final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  throw UnimplementedError('journeyRepositoryProvider must be overridden in main.dart');
});
