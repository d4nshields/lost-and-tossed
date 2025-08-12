import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dart_geohash/dart_geohash.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/app_error.dart';

class LocationService {
  const LocationService();

  /// Get current location with permission handling
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const AppError.location(
          message: 'Location services are disabled.',
          code: 'LOCATION_DISABLED',
        );
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw const AppError.permission(
            message: 'Location permissions are denied',
            permission: 'location',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw const AppError.permission(
          message:
              'Location permissions are permanently denied, we cannot request permissions.',
          permission: 'location',
        );
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: AppConstants.locationTimeoutSeconds),
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.location(
        message: 'Failed to get current location',
        code: e.toString(),
      );
    }
  }

  /// Convert latitude/longitude to coarse geohash for privacy
  String encodeCoarseGeohash(double latitude, double longitude) {
    final geoHasher = GeoHasher();
    return geoHasher.encode(
      longitude,
      latitude,
      precision: AppConstants.coarseGeohashPrecision,
    );
  }

  /// Convert latitude/longitude to fine geohash for precise location (optional)
  String encodeFineGeohash(double latitude, double longitude) {
    final geoHasher = GeoHasher();
    return geoHasher.encode(
      longitude,
      latitude,
      precision: AppConstants.fineGeohashPrecision,
    );
  }

  /// Decode geohash back to latitude/longitude
  GeohashLocation decodeGeohash(String geohash) {
    final geoHasher = GeoHasher();
    final decoded = geoHasher.decode(geohash);
    return GeohashLocation(
      latitude: decoded[1], // latitude is at index 1
      longitude: decoded[0], // longitude is at index 0
      geohash: geohash,
    );
  }

  /// Get neighboring geohashes for area queries
  Map<String, String> getNeighbors(String geohash) {
    final geoHash = GeoHash(geohash);
    return geoHash.neighbors;
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Check if location accuracy is acceptable
  bool isLocationAccurate(Position position) {
    return position.accuracy <= AppConstants.locationAccuracyThreshold;
  }

  /// Generate area query bounds for geohash searching
  /// This is useful for finding items within a certain radius
  List<String> getGeohashBounds(
    double centerLat,
    double centerLon,
    double radiusMeters,
  ) {
    // For simplicity, we'll use the center geohash and its neighbors
    // In a production app, you might want a more sophisticated approach
    final centerHash = encodeCoarseGeohash(centerLat, centerLon);
    final neighbors = getNeighbors(centerHash);

    // Return the center and all neighbors for querying
    return [
      centerHash,
      ...neighbors.values,
    ].toSet().toList(); // Remove duplicates
  }
}

class GeohashLocation {
  const GeohashLocation({
    required this.latitude,
    required this.longitude,
    required this.geohash,
  });

  final double latitude;
  final double longitude;
  final String geohash;

  @override
  String toString() =>
      'GeohashLocation(lat: $latitude, lon: $longitude, hash: $geohash)';
}

// Riverpod providers
final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

final currentLocationProvider = FutureProvider<Position?>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.getCurrentLocation();
});
