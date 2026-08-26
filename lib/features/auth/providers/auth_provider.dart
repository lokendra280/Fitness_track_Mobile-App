import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/auth/entities/auth_state.dart';
import 'package:habitflow/features/auth/services/auth_services.dart';

final authServiceProvider = Provider<AuthService>((_) => AuthService());

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AppAuthState> {
  AuthNotifier(this._authService) : super(const AppAuthState.initial()) {
    _sub = _authService.authStateChanges.listen((s) => state = s);
  }

  final AuthService _authService;
  late final StreamSubscription<AppAuthState> _sub;

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await AuthService.signIn();
      if (response == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.signInWithApple();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    if (state.error != null) state = state.copyWith(clearError: true);
  }

  Future<void> signOut() => _authService.signOut();

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
