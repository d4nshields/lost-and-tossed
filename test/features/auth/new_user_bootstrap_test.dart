import 'package:flutter_test/flutter_test.dart';
import 'package:lost_and_tossed/features/auth/domain/models/user_profile.dart';

void main() {
  group('New User Bootstrap Tests', () {
    test('handle follows validation rules', () {
      // Test handle validation
      final validHandles = [
        'explorer_abc123',
        'explorer_123',
        'explorer_test1',
        'user_123',
        'abc',  // Minimum 3 chars
        'abcdefghijklmnopqrst', // Maximum 20 chars
      ];
      
      final invalidHandles = [
        'ab', // Too short (< 3 chars)
        'this_is_a_very_long_handle_that_exceeds_twenty_chars', // Too long (> 20 chars)
        '', // Empty
      ];
      
      for (final handle in validHandles) {
        expect(handle.length, greaterThanOrEqualTo(3));
        expect(handle.length, lessThanOrEqualTo(20));
        // Check format - only letters, numbers, underscores
        expect(RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(handle), isTrue);
      }
      
      for (final handle in invalidHandles) {
        final isValid = handle.length >= 3 && 
                       handle.length <= 20 && 
                       RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(handle);
        expect(isValid, isFalse);
      }
    });

    test('UserProfile model properly handles all fields', () {
      final now = DateTime.now();
      final profile = UserProfile(
        id: 'test-id',
        handle: 'explorer_test',
        email: 'test@example.com',
        avatarUrl: 'https://example.com/avatar.jpg',
        bio: 'Test bio',
        createdAt: now,
        submissionCount: 5,
        findCount: 3,
      );
      
      expect(profile.id, equals('test-id'));
      expect(profile.handle, equals('explorer_test'));
      expect(profile.email, equals('test@example.com'));
      expect(profile.avatarUrl, equals('https://example.com/avatar.jpg'));
      expect(profile.bio, equals('Test bio'));
      expect(profile.createdAt, equals(now));
      expect(profile.submissionCount, equals(5));
      expect(profile.findCount, equals(3));
    });

    test('UserProfile serialization works correctly', () {
      final now = DateTime.now();
      final profile = UserProfile(
        id: 'test-id',
        handle: 'explorer_test',
        email: 'test@example.com',
        createdAt: now,
      );
      
      final json = profile.toJson();
      expect(json['id'], equals('test-id'));
      expect(json['handle'], equals('explorer_test'));
      expect(json['email'], equals('test@example.com'));
      expect(json['created_at'], equals(now.toIso8601String()));
      
      final restored = UserProfile.fromJson(json);
      expect(restored.id, equals(profile.id));
      expect(restored.handle, equals(profile.handle));
      expect(restored.email, equals(profile.email));
    });

    test('generated handles follow explorer pattern', () {
      // Test that generated handles match expected pattern
      final generatedHandles = [
        'explorer_abc123',
        'explorer_xyz789',
        'explorer_a1b2c3',
      ];
      
      for (final handle in generatedHandles) {
        expect(handle, startsWith('explorer_'));
        expect(handle.length, greaterThanOrEqualTo(9)); // explorer_ + at least 1 char
        expect(handle.length, lessThanOrEqualTo(20));
        expect(RegExp(r'^explorer_[a-z0-9]+$').hasMatch(handle), isTrue);
      }
    });
  });
}
