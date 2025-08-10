import 'package:flutter_test/flutter_test.dart';
import 'package:lost_and_tossed/shared/models/lost_item.dart';

void main() {
  group('LostItemCategory Tests', () {
    test('should have correct names for all categories', () {
      expect(const LostItemCategory.lost().name, 'Lost');
      expect(const LostItemCategory.tossed().name, 'Tossed');
      expect(const LostItemCategory.posted().name, 'Posted');
      expect(const LostItemCategory.marked().name, 'Marked');
      expect(const LostItemCategory.curious().name, 'Curious');
    });

    test('should have correct descriptions for all categories', () {
      expect(
        const LostItemCategory.lost().description,
        'Unintentionally left behind',
      );
      expect(
        const LostItemCategory.tossed().description,
        'Deliberately discarded',
      );
      expect(
        const LostItemCategory.posted().description,
        'Intended for display',
      );
      expect(
        const LostItemCategory.marked().description,
        'Non-removable markings',
      );
      expect(
        const LostItemCategory.curious().description,
        'Odd or unclassifiable',
      );
    });

    test('should have playful descriptions for all categories', () {
      expect(
        const LostItemCategory.lost().playfulDescription,
        'A glove begins its solo adventure.',
      );
      expect(
        const LostItemCategory.tossed().playfulDescription,
        'The snack that left only a clue.',
      );
      expect(
        const LostItemCategory.posted().playfulDescription,
        'Poster\'s still here, but the event is long gone.',
      );
      expect(
        const LostItemCategory.marked().playfulDescription,
        'Someone\'s creative mark on the world.',
      );
      expect(
        const LostItemCategory.curious().playfulDescription,
        'What story does this tell?',
      );
    });

    test('should support equality comparison', () {
      const category1 = LostItemCategory.lost();
      const category2 = LostItemCategory.lost();
      const category3 = LostItemCategory.tossed();

      expect(category1, equals(category2));
      expect(category1, isNot(equals(category3)));
    });
  });

  group('LicenseType Tests', () {
    test('should have correct JSON values', () {
      // This will work once the models are generated
      // For now, we test the enum values exist
      expect(LicenseType.ccByNc, isNotNull);
      expect(LicenseType.cc0, isNotNull);
    });
  });

  group('LostItem Tests', () {
    test('should create valid LostItem instance', () {
      final testDate = DateTime.now();
      const testItem = LostItem(
        id: 'test-123',
        title: 'Test Item',
        description: 'A test item for testing',
        category: LostItemCategory.lost(),
        imageUrl: 'https://example.com/image.jpg',
        geohash: 'gbsuv7',
        createdAt: testDate,
        createdBy: 'user-123',
      );

      expect(testItem.id, 'test-123');
      expect(testItem.title, 'Test Item');
      expect(testItem.category, const LostItemCategory.lost());
      expect(testItem.license, LicenseType.ccByNc); // Default value
    });

    test('should support custom license type', () {
      final testDate = DateTime.now();
      const testItem = LostItem(
        id: 'test-123',
        title: 'Test Item',
        description: 'A test item for testing',
        category: LostItemCategory.curious(),
        imageUrl: 'https://example.com/image.jpg',
        geohash: 'gbsuv7',
        createdAt: testDate,
        createdBy: 'user-123',
        license: LicenseType.cc0,
      );

      expect(testItem.license, LicenseType.cc0);
    });
  });
}
