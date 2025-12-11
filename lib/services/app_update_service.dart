import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Service for managing Google Play In-App Updates
///
/// Implements immediate update flow (with flexible fallback) for:
/// - Automatic update detection on app launch
/// - Blocking update UI until update completes
///
/// Graceful fallback for:
/// - Devices without Play Store
/// - Apps not installed via Play Store (debug/sideloaded builds)
/// - Unsupported Android versions
/// - Runtime API failures
class AppUpdateService {
  static final AppUpdateService instance = AppUpdateService._();

  AppUpdateService._();

  /// Whether the service is currently checking for updates
  bool _isChecking = false;

  /// Whether an update is currently being downloaded
  bool _isDownloading = false;

  /// Last error message for debugging
  String? _lastError;

  /// Get the last error (if any)
  String? get lastError => _lastError;

  /// Whether an update is currently downloading
  bool get isDownloading => _isDownloading;

  /// Check for updates and start update if available
  ///
  /// Returns true if an update was initiated, false otherwise.
  /// Prefers immediate update (blocking) with flexible update as fallback.
  ///
  /// Parameters:
  /// - [enabled]: Whether update checks are enabled (default: true)
  Future<bool> checkForUpdate({bool enabled = true}) async {
    // Skip if disabled
    if (!enabled) {
      _log('Update checks disabled via config flag');
      return false;
    }

    // Skip if already checking
    if (_isChecking) {
      _log('Update check already in progress');
      return false;
    }

    // Only run on Android
    if (!Platform.isAndroid) {
      _log('Skipping update check - not running on Android');
      return false;
    }

    _isChecking = true;
    _lastError = null;

    try {
      _log('=== STARTING UPDATE CHECK ===');
      _log('Checking for updates...');

      // Check if in-app updates are available on this device
      final updateInfo = await InAppUpdate.checkForUpdate();

      _log('Update check complete:');
      _log('  - Update availability: ${updateInfo.updateAvailability}');
      _log('  - Immediate allowed: ${updateInfo.immediateUpdateAllowed}');
      _log('  - Flexible allowed: ${updateInfo.flexibleUpdateAllowed}');

      // Check if update is available - prefer immediate update for blocking install
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          _log('Starting immediate update (will block until complete)...');
          await InAppUpdate.performImmediateUpdate();
          _log('Immediate update completed');
          return true;
        } else if (updateInfo.flexibleUpdateAllowed) {
          _log(
              'Immediate update not allowed, falling back to flexible update...');
          await _startFlexibleUpdate();
          return true;
        } else {
          _log('Update available but neither immediate nor flexible update allowed');
          return false;
        }
      } else {
        _log('No update available (availability: ${updateInfo.updateAvailability})');
        return false;
      }
    } catch (e, stackTrace) {
      // Graceful fallback - log error but don't disrupt app
      _lastError = e.toString();

      // Silently skip expected errors for sideloaded/debug builds
      final errorStr = e.toString();
      if (errorStr.contains('ERROR_APP_NOT_OWNED') ||
          errorStr.contains('-10:')) {
        // This is expected when running via 'flutter run' or sideloaded APK
        // The app wasn't installed from Play Store, so in-app updates don't apply
        _log('Update check skipped - app not installed from Play Store (expected for debug/sideloaded builds)');
        return false;
      }

      _logError('Update check failed', e, stackTrace);
      return false;
    } finally {
      _isChecking = false;
    }
  }

  /// Start the flexible update flow
  Future<void> _startFlexibleUpdate() async {
    try {
      _isDownloading = true;

      // Start the flexible update
      await InAppUpdate.startFlexibleUpdate();

      _log('Flexible update started, monitoring download progress...');

      // Monitor the download status
      InAppUpdate.completeFlexibleUpdate().then((_) {
        _log('Flexible update completed successfully');
        _isDownloading = false;
      }).catchError((e) {
        _logError('Failed to complete flexible update', e, StackTrace.current);
        _isDownloading = false;
      });
    } catch (e, stackTrace) {
      _isDownloading = false;
      _logError('Failed to start flexible update', e, stackTrace);
      rethrow;
    }
  }

  /// Perform an immediate update (blocking UI)
  ///
  /// This forces the user to update before continuing.
  /// Use for critical security updates.
  Future<bool> performImmediateUpdate({bool enabled = true}) async {
    if (!enabled) {
      _log('Immediate updates disabled via config flag');
      return false;
    }

    if (!Platform.isAndroid) {
      _log('Skipping immediate update - not running on Android');
      return false;
    }

    try {
      _log('Checking for immediate update...');

      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable &&
          updateInfo.immediateUpdateAllowed) {
        _log('Starting immediate update...');
        await InAppUpdate.performImmediateUpdate();
        return true;
      } else {
        _log('No immediate update available');
        return false;
      }
    } catch (e, stackTrace) {
      _lastError = e.toString();
      _logError('Immediate update failed', e, stackTrace);
      return false;
    }
  }

  /// Log a message (visible in debug mode)
  void _log(String message) {
    debugPrint('📱 [AppUpdate] $message');
  }

  /// Log an error with stack trace
  void _logError(String message, dynamic error, StackTrace stackTrace) {
    debugPrint('❌ [AppUpdate] $message: $error');
    if (kDebugMode) {
      debugPrint(
          '   Stack trace: ${stackTrace.toString().split('\n').take(3).join('\n   ')}');
    }
  }
}
