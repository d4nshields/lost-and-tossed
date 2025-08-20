/// User profile model for Lost & Tossed
class UserProfile {
  final String id;
  final String handle;
  final String? email;
  final String? avatarUrl;
  final String? bio;
  final DateTime createdAt;
  final int submissionCount;
  final int findCount;

  const UserProfile({
    required this.id,
    required this.handle,
    this.email,
    this.avatarUrl,
    this.bio,
    required this.createdAt,
    this.submissionCount = 0,
    this.findCount = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      handle: json['handle'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      submissionCount: json['submission_count'] as int? ?? 0,
      findCount: json['find_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'handle': handle,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
      'submission_count': submissionCount,
      'find_count': findCount,
    };
  }

  UserProfile copyWith({
    String? id,
    String? handle,
    String? email,
    String? avatarUrl,
    String? bio,
    DateTime? createdAt,
    int? submissionCount,
    int? findCount,
  }) {
    return UserProfile(
      id: id ?? this.id,
      handle: handle ?? this.handle,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      submissionCount: submissionCount ?? this.submissionCount,
      findCount: findCount ?? this.findCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          handle == other.handle;

  @override
  int get hashCode => id.hashCode ^ handle.hashCode;
}
