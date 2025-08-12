import 'package:flutter_test/flutter_test.dart';
import 'package:lost_and_tossed/shared/models/lost_item.dart';

void main() {
  group('LostItemCategory Tests', () {
    test('should have correct names for all categories', () {
      expect(LostItemCategory.lost.name, 'Lost');
      expect(LostItemCategory.tossed.name, 'Tossed');
      expect(LostItemCategory.posted.name, 'Posted');
      expect(LostItemCategory.marked.name, 'Marked');
      expect(LostItemCategory.curious.name, 'Curious');
    });

    test('should have correct descriptions for all categories', () {
      expect(
        LostItemCategory.lost.description,
        'Unintentionally left behind',
      );
      expect(
        LostItemCategory.tossed.description,
        'Deliberately discarded',
      );
      expect(
        LostItemCategory.posted.description,
        'Intended for display',
      );
      expect(
        LostItemCategory.marked.description,
        'Non-removable markings',
      );
      expect(
        LostItemCategory.curious.description,
        'Odd or unclassifiable',
      );
    });

    test('should have playful descriptions for all categories', () {
      expect(
        LostItemCategory.lost.playfulDescription,
        'A glove begins its solo adventure.',
      );
      expect(
        LostItemCategory.tossed.playfulDescription,
        'The snack that left only a clue.',
      );
      expect(
        LostItemCategory.posted.playfulDescription,
        'Poster\'s still here, but the event is long gone.',
      );
      expect(
        LostItemCategory.marked.playfulDescription,
        'Someone\'s creative mark on the world.',
      );
      expect(
        LostItemCategory.curious.playfulDescription,
        'What story does this tell?',
      );
    });

    test('should work with all enum values', () {
      const categories = LostItemCategory.values;
      expect(categories.length, 5);

      for (final category in categories) {
        expect(category.name, isA<String>());
        expect(category.description, isA<String>());
        expect(category.playfulDescription, isA<String>());
      }
    });
  });

  group('LicenseType Tests', () {
    test('should have correct enum values', () {
      expect(LicenseType.ccByNc, isNotNull);
      expect(LicenseType.cc0, isNotNull);
      expect(LicenseType.values.length, 2);
    });
  });

  group('LostItem Tests', () {
    test('should create valid LostItem instance', () {
      final testDate = DateTime.now();
      final testItem = LostItem(
        id: 'test-123',
        title: 'Test Item',
        description: 'A test item for testing',
        category: LostItemCategory.lost,
        imageUrl: 'https://example.com/image.jpg',
        geohash: 'gbsuv7',
        createdAt: testDate,
        createdBy: 'user-123',
      );

      expect(testItem.id, 'test-123');
      expect(testItem.title, 'Test Item');
      expect(testItem.category, LostItemCategory.lost);
      expect(testItem.license, LicenseType.ccByNc); // Default value
    });

    test('should support custom license type', () {
      final testDate = DateTime.now();
      final testItem = LostItem(
        id: 'test-123',
        title: 'Test Item',
        description: 'A test item for testing',
        category: LostItemCategory.curious,
        imageUrl: 'https://example.com/image.jpg',
        geohash: 'gbsuv7',
        createdAt: testDate,
        createdBy: 'user-123',
        license: LicenseType.cc0,
      );

      expect(testItem.license, LicenseType.cc0);
    });

    test('should serialize to/from JSON correctly', () {
      final testDate = DateTime.parse('2024-01-01T12:00:00Z');
      final item = LostItem(
        id: 'test-id',
        title: 'Test Glove',
        description: 'A lonely glove on the sidewalk',
        category: LostItemCategory.lost,
        imageUrl: 'https://example.com/glove.jpg',
        geohash: 'gbsuv',
        createdAt: testDate,
        createdBy: 'user123',
        license: LicenseType.ccByNc,
      );

      final json = item.toJson();
      expect(json['category'], 'lost');
      expect(json['license'], 'ccByNc');

      final recreated = LostItem.fromJson(json);
      expect(recreated.category, LostItemCategory.lost);
      expect(recreated.license, LicenseType.ccByNc);
      expect(recreated.title, 'Test Glove');
    });

    test('should handle missing license gracefully', () {
      final testDate = DateTime.parse('2024-01-01T12:00:00Z');
      final item = LostItem(
        id: 'test-id',
        title: 'Test Item',
        description: 'Description',
        category: LostItemCategory.curious,
        imageUrl: 'https://example.com/image.jpg',
        geohash: 'gbsuv',
        createdAt: testDate,
        createdBy: 'user123',
      );

      // Default license should be ccByNc
      expect(item.license, LicenseType.ccByNc);

      final json = item.toJson();
      // Remove license from JSON to test default behavior
      json.remove('license');

      final recreated = LostItem.fromJson(json);
      expect(recreated.license, LicenseType.ccByNc); // Should default to ccByNc
    });
  });
}
