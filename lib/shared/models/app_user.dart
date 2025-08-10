import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    String? displayName,
    String? avatarUrl,
    @Default(false) bool isAnonymous,
    required DateTime createdAt,
    DateTime? lastSeenAt,
    @Default(0) int contributionCount,
    Map<String, dynamic>? preferences,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(true) bool shareLocation,
    @Default(true) bool enableNotifications,
    @Default(false) bool privateProfile,
    @Default('metric') String units,
    @Default(['lost', 'tossed', 'posted', 'marked', 'curious']) List<String> interestedCategories,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) => 
      _$UserPreferencesFromJson(json);
}
