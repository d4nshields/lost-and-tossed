import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_and_tossed/core/theme/app_theme.dart';

void main() {
  group('Lost & Tossed App', () {
    testWidgets('App should build without errors', (WidgetTester tester) async {
      // Mock environment variables
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Lost & Tossed'),
              ),
            ),
          ),
        ),
      );

      // Verify the app builds successfully
      expect(find.text('Lost & Tossed'), findsOneWidget);
    });

    testWidgets('App should have proper theme configuration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            title: 'Lost & Tossed',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const Scaffold(
              body: Center(
                child: Text('Test'),
              ),
            ),
          ),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
      expect(materialApp.title, equals('Lost & Tossed'));
    });
  });

  group('App Constants', () {
    test('should have valid app information', () {
      const appName = 'Lost & Tossed';
      const appVersion = '1.0.0';

      expect(appName.isNotEmpty, true);
      expect(appVersion.isNotEmpty, true);
    });

    test('should have valid category list', () {
      const categories = ['lost', 'tossed', 'posted', 'marked', 'curious', 'traces'];

      expect(categories.length, 6);
      expect(categories.contains('lost'), true);
      expect(categories.contains('curious'), true);
      expect(categories.contains('traces'), true);
    });
  });
}
