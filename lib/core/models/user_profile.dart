class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.language,
  });

  final String id;
  final String email;
  final String fullName;
  final String language;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      language: map['language'] as String? ?? 'English',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'language': language,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? language,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      language: language ?? this.language,
    );
  }
}
