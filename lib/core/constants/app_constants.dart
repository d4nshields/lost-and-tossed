/// App-wide constants for Lost & Tossed
class AppConstants {
  // App Info
  static const String appName = 'Lost & Tossed';
  static const String appVersion = '1.0.0+1';
  static const String appDescription =
      'A playful community field guide for documenting found, discarded, or posted public objects.';

  // Supabase Configuration
  static const String supabaseUrl = 'https://itosryiospovqdcrnjxr.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml0b3NyeWlvc3BvdnFkY3JuanhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4NTc5NTAsImV4cCI6MjA3MDQzMzk1MH0.jiR7KITFeGcacXOYXvj_3eTVAYM-e-g6dTKJwWtbS3A';

  // Storage Buckets
  static const String itemImagesBucket = 'item-images';
  static const String profileAvatarsBucket = 'profile-avatars';

  // Geohash precision (5 = ~152m x 152m grid)
  static const int geohashPrecision = 5;

  // Image constraints
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int thumbnailWidth = 300;
  static const int thumbnailHeight = 300;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1920;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Text limits
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 1000;
  static const int maxCommentLength = 500;
  static const int maxUsernameLength = 20;
  static const int minUsernameLength = 3;

  // Location accuracy
  static const double locationAccuracyMeters = 100.0;
  static const Duration locationTimeoutDuration = Duration(seconds: 30);

  // Cache durations
  static const Duration itemCacheDuration = Duration(minutes: 15);
  static const Duration profileCacheDuration = Duration(hours: 1);

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}
