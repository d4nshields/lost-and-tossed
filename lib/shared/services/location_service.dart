import 'package:geolocator/geolocator.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:logger/logger.dart';

import '../../core/constants/app_constants.dart';

/// Simplified location service for basic operations
class LocationService {
  final Logger _logger;

  LocationService({required Logger logger}) : _logger = logger;

  /// Initialize the location service
  Future<void> initialize() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w('Location services are disabled');
        return;
      }

      // Check initial permission status
      LocationPermission permission = await Geolocator.checkPermission();
      _logger.i('Initial location permission: $permission');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize location service',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Get the current device location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check permission first
      final hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        final permission = await requestLocationPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          _logger.w('Location permission not granted');
          return null;
        }
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: AppConstants.locationTimeoutDuration,
      );

      _logger
          .i('Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e, stackTrace) {
      _logger.e('Failed to get current location',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Check if location permissions are granted
  Future<bool> hasLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e, stackTrace) {
      _logger.e('Failed to check location permission',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Request location permissions from the user
  Future<LocationPermission> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w('Location services are not enabled');
        return LocationPermission.denied;
      }

      // Check current permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
        _logger.i('Location permission requested: $permission');
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.w('Location permission denied forever');
        return LocationPermission.deniedForever;
      }

      return permission;
    } catch (e, stackTrace) {
      _logger.e('Failed to request location permission',
          error: e, stackTrace: stackTrace);
      return LocationPermission.denied;
    }
  }

  /// Generate a geohash from coordinates
  String generateGeohash(double latitude, double longitude,
      {int precision = 5}) {
    try {
      final geoHasher = GeoHasher();
      final geohash = geoHasher.encode(longitude, latitude, precision: precision);
      _logger.d('Generated geohash: $geohash for $latitude, $longitude');
      return geohash;
    } catch (e, stackTrace) {
      _logger.e('Failed to generate geohash', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Get location data for the current position
  Future<LocationData?> getCurrentLocationData() async {
    try {
      final position = await getCurrentLocation();
      if (position == null) return null;

      final geohash = generateGeohash(
        position.latitude,
        position.longitude,
        precision: AppConstants.geohashPrecision,
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        geohash: geohash,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to get current location data',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Format coordinates for display
  String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }
}

/// Data class for location information
class LocationData {
  final double latitude;
  final double longitude;
  final String geohash;
  final double accuracy;
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.accuracy,
    required this.timestamp,
  });

  bool get isAccurate => accuracy <= AppConstants.locationAccuracyMeters;

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, geohash: $geohash, accuracy: ${accuracy}m)';
  }
}
