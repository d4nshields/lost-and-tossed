import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helper utilities for Lost & Tossed app testing
class TestHelpers {
  /// Wraps a widget with MaterialApp and ProviderScope for testing
  static Widget wrapWithApp(Widget child, {List<Override>? overrides}) {
    return ProviderScope(
      overrides: overrides ?? [],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  /// Creates a mock Riverpod container with test overrides
  static ProviderContainer createContainer({List<Override>? overrides}) {
    return ProviderContainer(
      overrides: overrides ?? [],
    );
  }

  /// Pump and settle with a reasonable timeout
  static Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Common test data for Lost Items
  static const testLostItemData = {
    'id': 'test-id-123',
    'title': 'Test Lost Glove',
    'description': 'A lonely glove on its adventure',
    'category': 'lost',
    'imageUrl': 'https://example.com/image.jpg',
    'geohash': 'gbsuv',
    'createdAt': '2024-01-01T00:00:00Z',
    'createdBy': 'test-user-id',
    'license': 'cc_by_nc',
  };

  /// Common test data for App User
  static const testUserData = {
    'id': 'test-user-id',
    'email': 'test@example.com',
    'displayName': 'Test Explorer',
    'isAnonymous': false,
    'createdAt': '2024-01-01T00:00:00Z',
    'contributionCount': 5,
  };
}

/// Extension methods for test convenience
extension WidgetTesterExtensions on WidgetTester {
  /// Find a widget by its key string
  Finder findByKeyString(String key) {
    return find.byKey(Key(key));
  }

  /// Verify that an icon exists with a specific icon data
  void expectIcon(IconData iconData) {
    expect(find.byIcon(iconData), findsOneWidget);
  }

  /// Verify that text exists and is visible
  void expectText(String text) {
    expect(find.text(text), findsOneWidget);
  }
}

/// Mock implementations for testing
class MockProviders {
  // TODO: Add mock providers for Supabase, Location, etc.
  // when those services are implemented
}
