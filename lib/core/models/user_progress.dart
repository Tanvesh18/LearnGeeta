class UserProgress {
  const UserProgress({
    required this.userId,
    required this.level,
    required this.xp,
    required this.streak,
    this.lastActive,
  });

  final String userId;
  final int level;
  final int xp;
  final int streak;
  final DateTime? lastActive;

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['user_id'] as String? ?? '',
      level: (map['level'] as num?)?.toInt() ?? 1,
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      lastActive: map['last_active'] == null
          ? null
          : DateTime.tryParse(map['last_active'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'level': level,
      'xp': xp,
      'streak': streak,
      'last_active': lastActive?.toIso8601String(),
    };
  }

  UserProgress copyWith({
    String? userId,
    int? level,
    int? xp,
    int? streak,
    DateTime? lastActive,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
