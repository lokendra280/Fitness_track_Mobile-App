import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:habitflow/features/auth/entities/app_users.dart';
import 'package:habitflow/features/auth/entities/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isSignedIn => currentUser != null;
  static final _supabase = Supabase.instance.client;
  static const _webClientId =
      '661083503148-cl9ob8dtehf260itnci2lnrmjfvqh1ur.apps.googleusercontent.com';

  Stream<AppAuthState> get authStateChanges =>
      _client.auth.onAuthStateChange.map((e) {
        final u = e.session?.user;
        if (u == null) return const AppAuthState.unauthenticated();
        return AppAuthState.authenticated(_mapUser(u));
      });

  static Future<AuthResponse?> signInWithGoogle() async {
    try {
      debugPrint('🔵 Google Sign-In: starting authenticate()');

      // Initialize with serverClientId before authenticate()
      await GoogleSignIn.instance.initialize(serverClientId: _webClientId);

      // Use authenticate() for version 7.x
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      debugPrint('🔵 Google account: ${googleUser.email}');

      // Get authentication - returns GoogleSignInAuthentication directly
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      debugPrint('🔵 idToken: ${idToken != null ? "found ✅" : "NULL ❌"}');

      if (idToken == null) {
        throw Exception(
          'No ID Token. Ensure Web Client ID is configured correctly.',
        );
      }

      // For accessToken in v7.x, we need to get it from authorizationClient
      String? accessToken;
      try {
        final authorization = await googleUser.authorizationClient
            .authorizationForScopes(['email']);
        accessToken = authorization?.accessToken;
        debugPrint(
          '🔵 accessToken: ${accessToken != null ? "found ✅" : "NULL"}',
        );
      } catch (e) {
        debugPrint('🟡 Could not get access token: $e');
      }

      // Sign in to Supabase with Google tokens
      debugPrint('🔵 Signing in to Supabase...');
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      debugPrint('✅ Supabase sign-in success: ${response.user?.email}');
      return response;
    } on GoogleSignInException catch (e) {
      debugPrint(' GoogleSignInException: ${e.code} - ${e.toString()}');
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint(' User cancelled — returning null');
        return null;
      }
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error in GoogleAuthService.signIn(): $e');
      rethrow;
    }
  }

  static Future<AuthResponse?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        debugPrint('Signup successful: ${user.id}');
      }
      return response;
    } on AuthException catch (e) {
      debugPrint('Signup error: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error: $e');
    }
    return null;
  }

  static Future<AuthResponse?> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        debugPrint('Signup successful: ${user.id}');
      }
      return response;
    } on AuthException catch (e) {
      debugPrint('Signup error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      rethrow;
    }
  }

  static Future<AuthResponse> verifySignUpOtp({
    required String email,
    required String token,
  }) {
    return _supabase.auth.verifyOTP(
      type: OtpType.signup,
      token: token,
      email: email,
    );
  }

  static Future<void> resendSignUpOtp({required String email}) {
    return _supabase.auth.resend(type: OtpType.signup, email: email);
  }

  Future<void> signInWithApple() async =>
      _client.auth.signInWithOAuth(OAuthProvider.apple,
          redirectTo: 'io.supabase.habitflow://login-callback/');

  Future<void> updatePassword(String newPassword) async =>
      _client.auth.updateUser(UserAttributes(password: newPassword));

  Future<AppUser> updateProfile({String? username, String? avatarUrl}) async {
    final uid = currentUser?.id;
    if (uid == null) throw Exception('Not signed in');
    await _upsertProfile(uid, username, avatarUrl: avatarUrl);
    final profile =
        await _client.from('profiles').select().eq('id', uid).single();
    return _mapUser(currentUser!, profile: profile);
  }

  Future<AppUser?> getProfile() async {
    final u = currentUser;
    if (u == null) return null;
    try {
      final profile =
          await _client.from('profiles').select().eq('id', u.id).maybeSingle();
      return _mapUser(u, profile: profile);
    } catch (_) {
      return _mapUser(u);
    }
  }

  /// signUp with Password

  Future<void> signOut() => _client.auth.signOut();

  Future<void> _upsertProfile(String uid, String? username,
          {String? avatarUrl}) =>
      _client.from('profiles').upsert({
        'id': uid,
        if (username != null) 'username': username,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      });

  AppUser _mapUser(User u, {Map<String, dynamic>? profile}) => AppUser(
        id: u.id,
        email: u.email ?? '',
        username: profile?['username'] as String? ??
            u.userMetadata?['username'] as String?,
        avatarUrl: profile?['avatar_url'] as String? ??
            u.userMetadata?['avatar_url'] as String?,
        createdAt: DateTime.tryParse(u.createdAt) ?? DateTime.now(),
      );
}
