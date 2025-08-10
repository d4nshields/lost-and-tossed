class AppConstants {
  // App information
  static const String appName = 'Lost & Tossed';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A playful community field guide for documenting found, discarded, or posted public objects';
  
  // Geohash precision levels
  static const int coarseGeohashPrecision = 5; // ~2.4km x 1.2km
  static const int fineGeohashPrecision = 7; // ~76m x 152m
  
  // Image constraints
  static const int maxImageSizeMB = 10;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1920;
  static const double imageQuality = 0.8;
  
  // Location settings
  static const double locationAccuracyThreshold = 100.0; // meters
  static const int locationTimeoutSeconds = 30;
  
  // Privacy and licensing
  static const String defaultLicense = 'CC BY-NC';
  static const List<String> availableLicenses = ['CC BY-NC', 'CC0'];
  
  // API limits
  static const int maxDescriptionLength = 500;
  static const int maxTitleLength = 100;
  static const int itemsPerPage = 20;
  
  // Categories
  static const List<String> itemCategories = [
    'lost',
    'tossed',
    'posted',
    'marked',
    'curious',
  ];
  
  // Playful micro-copy
  static const Map<String, String> categoryMicroCopy = {
    'lost': 'A glove begins its solo adventure.',
    'tossed': 'The snack that left only a clue.',
    'posted': 'Poster\'s still here, but the event is long gone.',
    'marked': 'Someone\'s creative mark on the world.',
    'curious': 'What story does this tell?',
  };
  
  // Privacy settings
  static const bool defaultShareLocation = true;
  static const bool defaultEnableNotifications = true;
  static const bool defaultPrivateProfile = false;
  
  // ML Kit settings
  static const double faceDetectionConfidence = 0.7;
  static const double textRecognitionConfidence = 0.8;
}

class ApiEndpoints {
  static const String items = '/items';
  static const String users = '/users';
  static const String auth = '/auth';
  static const String upload = '/upload';
  static const String geohash = '/geohash';
}

class DatabaseTables {
  static const String items = 'items';
  static const String users = 'profiles';
  static const String favorites = 'favorites';
  static const String reports = 'reports';
}

class StorageBuckets {
  static const String itemImages = 'item-images';
  static const String userAvatars = 'user-avatars';
  static const String thumbnails = 'thumbnails';
}
