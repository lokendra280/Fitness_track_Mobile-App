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
        // User cancelled the Google picker — not an error, just abort.
        state = state.copyWith(isLoading: false);
        return;
      }
      // Successful sign-in flows through authStateChanges automatically
      // (Supabase's onAuthStateChange fires once the session is set),
      // which updates `state` to .authenticated(...) via the stream
      // listener in the constructor. We just need to clear isLoading here.
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _readableError(e));
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
      state = state.copyWith(isLoading: false, error: _readableError(e));
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
      state = state.copyWith(isLoading: false, error: _readableError(e));
    }
  }

  /// Was previously calling AuthService.signUpWithEmailPassword — meaning
  /// every "sign in" attempt was actually trying to create a NEW account,
  /// which Supabase rejects for an already-registered email. Fixed to
  /// call the correct signInWithEmail method.
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await AuthService.signInWithEmail(
        email: email,
        password: password,
      );
      if (response == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _readableError(e));
    }
  }

  Future<void> resendOtp() async {
    final email = state.pendingVerificationEmail;
    if (email == null) return;
    try {
      await AuthService.resendSignUpOtp(email: email);
    } catch (e) {
      state = state.copyWith(error: _readableError(e));
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.signInWithApple();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _readableError(e));
    }
  }

  void clearError() {
    if (state.error != null) state = state.copyWith(clearError: true);
  }

  Future<void> signOut() => _authService.signOut();

  /// AuthException.message is usually already user-readable (e.g.
  /// "Invalid login credentials"), but a raw caught Exception's
  /// toString() can leak internal details ("Exception: ..."). This keeps
  /// the SnackBar copy clean regardless of which error type was thrown.
  String _readableError(Object e) {
    final msg = e.toString();
    return msg.startsWith('Exception: ') ? msg.substring(11) : msg;
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
