// ─── AppUser ──────────────────────────────────────────────────────────────────
class AppUser {
  final String id;
  final String email;
  final String? username;
  final String? avatarUrl;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.createdAt,
    this.username,
    this.avatarUrl,
  });

  AppUser copyWith(
          {String? id,
          String? email,
          String? username,
          String? avatarUrl,
          DateTime? createdAt}) =>
      AppUser(
          id: id ?? this.id,
          email: email ?? this.email,
          username: username ?? this.username,
          avatarUrl: avatarUrl ?? this.avatarUrl,
          createdAt: createdAt ?? this.createdAt);

  String get displayName =>
      (username?.isNotEmpty == true) ? username! : email.split('@').first;

  String get initials {
    final parts = displayName.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return displayName
        .substring(0, displayName.length.clamp(1, 2))
        .toUpperCase();
  }
}

// ─── Auth Status ────────────────────────────────────────────────────────────────
enum AuthStatus { loading, authenticated, unauthenticated }

// ─── SyncState ────────────────────────────────────────────────────────────────
enum SyncStatus { idle, syncing, success, error, offline }

class SyncState {
  final SyncStatus status;
  final String? message;
  final DateTime? lastSynced;

  const SyncState({required this.status, this.message, this.lastSynced});
  const SyncState.idle()
      : status = SyncStatus.idle,
        message = null,
        lastSynced = null;

  bool get isSyncing => status == SyncStatus.syncing;
  bool get isOffline => status == SyncStatus.offline;
  bool get hasError => status == SyncStatus.error;
}
