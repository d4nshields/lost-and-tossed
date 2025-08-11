import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase/supabase.dart' hide Provider;
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import '../../shared/services/location_service.dart';
import '../../shared/services/image_service.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/services/simple_supabase_service.dart';
import '../../shared/models/simple_models.dart';

/// Core dependency injection providers
/// 
/// This file centralizes all the core services and dependencies that
/// are used throughout the app. By using Riverpod providers, we get
/// automatic dependency injection, lifecycle management, and testing support.

/// Supabase client provider
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return SupabaseClient(
    AppConstants.supabaseUrl,
    AppConstants.supabaseAnonKey,
  );
});

/// Logger provider for structured logging
final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
});

/// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  final logger = ref.watch(loggerProvider);
  return LocationService(logger: logger);
});

/// Image processing service provider
final imageServiceProvider = Provider<ImageService>((ref) {
  final logger = ref.watch(loggerProvider);
  return ImageService(logger: logger);
});

/// Storage service provider (Supabase Storage)
final storageServiceProvider = Provider<StorageService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final logger = ref.watch(loggerProvider);
  return StorageService(
    supabase: supabase,
    logger: logger,
  );
});

/// Supabase service provider (database operations)
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final logger = ref.watch(loggerProvider);
  return SupabaseService(
    supabase: supabase,
    logger: logger,
  );
});

/// Current user session provider (simplified for now)
final currentUserProvider = StreamProvider<User?>((ref) {
  // For now, return null - we'll implement auth later
  return Stream.value(null);
});

/// Current user profile provider (simplified)
final currentUserProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    yield null;
    return;
  }

  final supabaseService = ref.watch(supabaseServiceProvider);
  try {
    final profile = await supabaseService.getProfile(user.id);
    yield profile;
  } catch (e) {
    // User might not have a profile yet
    yield null;
  }
});

/// App initialization provider
/// 
/// This provider handles the initialization of core services
/// and ensures they're ready before the app starts.
final appInitProvider = FutureProvider<void>((ref) async {
  final logger = ref.read(loggerProvider);
  
  try {
    logger.i('App initialization started');
    
    // Initialize location service
    final locationService = ref.read(locationServiceProvider);
    await locationService.initialize();
    
    logger.i('Location service initialized');
    
    // Initialize image service
    final imageService = ref.read(imageServiceProvider);
    await imageService.initialize();
    
    logger.i('Image service initialized');
    
    logger.i('App initialization completed successfully');
  } catch (e, stackTrace) {
    logger.e('App initialization failed', error: e, stackTrace: stackTrace);
    rethrow;
  }
});

/// Helper extensions for common operations
extension RefExtensions on Ref {
  /// Get the current user ID, throws if not authenticated
  String get currentUserId {
    final user = watch(currentUserProvider).value;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.id;
  }

  /// Get the current user ID, returns null if not authenticated
  String? get currentUserIdOrNull {
    return watch(currentUserProvider).value?.id;
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    return watch(currentUserProvider).value != null;
  }
}
