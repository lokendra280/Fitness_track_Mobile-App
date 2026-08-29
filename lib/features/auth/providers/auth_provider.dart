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
      final response = await AuthService.signInWithGoogle();
      if (response == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyOtp(String token) async {
    final email = state.pendingVerificationEmail;
    if (email == null) {
      state = state.copyWith(error: 'No email pending verification.');
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await AuthService.verifySignUpOtp(email: email, token: token);
      state = state.copyWith(
        isLoading: false,
        clearPendingVerificationEmail: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await AuthService.signUpWithEmailPassword(
        email: email,
        password: password,
      );
      if (response == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      // Account created, but not confirmed yet — hand off to the OTP screen
      // rather than assuming a session exists.
      state = state.copyWith(
        isLoading: false,
        pendingVerificationEmail: email,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await AuthService.signUpWithEmailPassword(
        email: email,
        password: password,
      );
      if (response == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resendOtp() async {
    final email = state.pendingVerificationEmail;
    if (email == null) return;
    try {
      await AuthService.resendSignUpOtp(email: email);
    } catch (e) {
      state = state.copyWith(error: e.toString());
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
