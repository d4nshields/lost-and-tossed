// Temporary simplified model without code generation for initial build

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.isAnonymous = false,
    required this.createdAt,
    this.lastSeenAt,
    this.contributionCount = 0,
    this.preferences,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime? lastSeenAt;
  final int contributionCount;
  final Map<String, dynamic>? preferences;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      isAnonymous: json['isAnonymous'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastSeenAt: json['lastSeenAt'] != null ? DateTime.parse(json['lastSeenAt']) : null,
      contributionCount: json['contributionCount'] ?? 0,
      preferences: json['preferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.toIso8601String(),
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      'contributionCount': contributionCount,
      'preferences': preferences,
    };
  }
}

class UserPreferences {
  const UserPreferences({
    this.shareLocation = true,
    this.enableNotifications = true,
    this.privateProfile = false,
    this.units = 'metric',
    this.interestedCategories = const ['lost', 'tossed', 'posted', 'marked', 'curious'],
  });

  final bool shareLocation;
  final bool enableNotifications;
  final bool privateProfile;
  final String units;
  final List<String> interestedCategories;

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      shareLocation: json['shareLocation'] ?? true,
      enableNotifications: json['enableNotifications'] ?? true,
      privateProfile: json['privateProfile'] ?? false,
      units: json['units'] ?? 'metric',
      interestedCategories: List<String>.from(json['interestedCategories'] ?? 
        ['lost', 'tossed', 'posted', 'marked', 'curious']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shareLocation': shareLocation,
      'enableNotifications': enableNotifications,
      'privateProfile': privateProfile,
      'units': units,
      'interestedCategories': interestedCategories,
    };
  }
}
