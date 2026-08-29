import 'app_users.dart';

class AppAuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;
  final String? pendingVerificationEmail;

  const AppAuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.pendingVerificationEmail,
  });

  const AppAuthState.initial() : this(isLoading: true);
  const AppAuthState.unauthenticated({String? error})
      : this(isLoading: false, error: error);
  const AppAuthState.authenticated(AppUser user)
      : this(user: user, isLoading: false);

  bool get isAuthenticated => user != null;
  bool get hasPendingVerification => pendingVerificationEmail != null;

  AppAuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? pendingVerificationEmail,
    bool clearPendingVerificationEmail = false,
  }) {
    return AppAuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      pendingVerificationEmail: clearPendingVerificationEmail
          ? null
          : (pendingVerificationEmail ?? this.pendingVerificationEmail),
    );
  }
}
