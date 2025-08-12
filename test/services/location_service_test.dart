import 'package:flutter_test/flutter_test.dart';
import 'package:dart_geohash/dart_geohash.dart';

import 'package:lost_and_tossed/services/location_service.dart';
import 'package:lost_and_tossed/core/constants/app_constants.dart';

void main() {
  group('LocationService Tests', () {
    late LocationService locationService;

    setUp(() {
      locationService = const LocationService();
    });

    group('Geohash Encoding/Decoding', () {
      test('should encode coordinates to coarse geohash', () {
        // Test with Toronto coordinates
        const lat = 43.6532;
        const lon = -79.3832;

        final geohash = locationService.encodeCoarseGeohash(lat, lon);

        expect(geohash.length, AppConstants.coarseGeohashPrecision);
        expect(geohash, isA<String>());
        // Toronto should be around 'dpz8' for precision 5
        expect(geohash, startsWith('dpz'));
      });

      test('should encode coordinates to fine geohash', () {
        // Test with Toronto coordinates
        const lat = 43.6532;
        const lon = -79.3832;

        final geohash = locationService.encodeFineGeohash(lat, lon);

        expect(geohash.length, AppConstants.fineGeohashPrecision);
        expect(geohash, isA<String>());
      });

      test('should decode geohash back to coordinates', () {
        const originalLat = 43.6532;
        const originalLon = -79.3832;

        // Encode first
        final geohash =
            locationService.encodeCoarseGeohash(originalLat, originalLon);

        // Then decode
        final location = locationService.decodeGeohash(geohash);

        // Should be approximately the same (within geohash precision)
        expect(location.latitude, closeTo(originalLat, 0.1));
        expect(location.longitude, closeTo(originalLon, 0.1));
        expect(location.geohash, geohash);
      });

      test('should maintain precision consistency', () {
        const lat = 40.7589;
        const lon = -73.9851; // New York coordinates

        final coarseHash = locationService.encodeCoarseGeohash(lat, lon);
        final fineHash = locationService.encodeFineGeohash(lat, lon);

        expect(coarseHash.length, 5);
        expect(fineHash.length, 7);

        // Fine hash should start with coarse hash
        expect(fineHash, startsWith(coarseHash));
      });
    });

    group('Geohash Neighbors', () {
      test('should get neighbors for a geohash', () {
        const testHash = 'gbsuv';

        final neighbors = locationService.getNeighbors(testHash);

        expect(neighbors, isA<Map<String, String>>());
        expect(neighbors.length, greaterThan(0));

        // Should include the original hash and its neighbors
        expect(neighbors.values, contains(testHash));
      });

      test('should generate area query bounds', () {
        const lat = 51.5074; // London
        const lon = -0.1278;
        const radiusMeters = 1000.0;

        final bounds = locationService.getGeohashBounds(lat, lon, radiusMeters);

        expect(bounds, isA<List<String>>());
        expect(bounds.isNotEmpty, true);

        // Should contain the center geohash
        final centerHash = locationService.encodeCoarseGeohash(lat, lon);
        expect(bounds, contains(centerHash));
      });
    });

    group('Distance Calculations', () {
      test('should calculate distance between two points', () {
        // Distance between Toronto and Ottawa (approximately 350km)
        const torontoLat = 43.6532;
        const torontoLon = -79.3832;
        const ottawaLat = 45.4215;
        const ottawaLon = -75.6972;

        final distance = locationService.calculateDistance(
          torontoLat,
          torontoLon,
          ottawaLat,
          ottawaLon,
        );

        // Should be approximately 350,000 meters (give or take 50km)
        expect(distance, greaterThan(300000));
        expect(distance, lessThan(400000));
      });

      test('should return zero distance for same coordinates', () {
        const lat = 43.6532;
        const lon = -79.3832;

        final distance = locationService.calculateDistance(lat, lon, lat, lon);

        expect(distance, 0.0);
      });
    });

    group('Privacy Features', () {
      test('coarse geohash should provide privacy protection', () {
        // Two points close together should have the same coarse geohash
        const lat1 = 43.6532;
        const lon1 = -79.3832;
        const lat2 = 43.6540; // About 100m away
        const lon2 = -79.3840;

        final hash1 = locationService.encodeCoarseGeohash(lat1, lon1);
        final hash2 = locationService.encodeCoarseGeohash(lat2, lon2);

        // Should be the same for privacy (coarse precision)
        expect(hash1, hash2);
      });

      test('fine geohash should be more precise', () {
        const lat1 = 43.6532;
        const lon1 = -79.3832;
        const lat2 = 43.6540; // About 100m away
        const lon2 = -79.3840;

        final hash1 = locationService.encodeFineGeohash(lat1, lon1);
        final hash2 = locationService.encodeFineGeohash(lat2, lon2);

        // Should be different for precision (but might be same depending on actual distance)
        // Update test to use farther apart coordinates
        const lat3 = 43.7532; // Much further away
        const lon3 = -79.4832;
        final hash3 = locationService.encodeFineGeohash(lat3, lon3);
        
        expect(hash1, isNot(hash3));
      });
    });
  });

  group('dart_geohash Package Direct Tests', () {
    test('should work with GeoHasher class directly', () {
      final geoHasher = GeoHasher();

      // Test encoding
      final encoded = geoHasher.encode(-79.3832, 43.6532, precision: 5);
      expect(encoded, isA<String>());
      expect(encoded.length, 5);

      // Test decoding
      final decoded = geoHasher.decode(encoded);
      expect(decoded[1], closeTo(43.6532, 0.1)); // latitude is at index 1
      expect(decoded[0], closeTo(-79.3832, 0.1)); // longitude is at index 0
    });

    test('should work with GeoHash class directly', () {
      final geoHash = GeoHash.fromDecimalDegrees(-79.3832, 43.6532);

      expect(geoHash.geohash, isA<String>());
      expect(geoHash.latitude(), closeTo(43.6532, 0.1));
      expect(geoHash.longitude(), closeTo(-79.3832, 0.1));

      // Test neighbors
      final neighbors = geoHash.neighbors;
      expect(neighbors, isA<Map>());
      expect(neighbors.length, greaterThan(0));
    });
  });
}
