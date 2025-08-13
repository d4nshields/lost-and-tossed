import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lost_and_tossed/presentation/theme/cozy_theme.dart';

void main() {
  group('LostTossedCozyTheme', () {
    testWidgets('theme builds without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: LostTossedCozyTheme.lightTheme,
          home: const Scaffold(
            body: Text('Test App'),
          ),
        ),
      );

      expect(find.text('Test App'), findsOneWidget);
    });

    test('category colors are defined for all categories', () {
      final categories = ['lost', 'tossed', 'posted', 'marked', 'curious', 'traces'];
      
      for (final category in categories) {
        final color = LostTossedCozyTheme.getCategoryColor(category);
        expect(color, isA<Color>());
        expect(color, isNot(equals(LostTossedCozyTheme.pewter))); // Should not default to pewter
      }
    });

    test('accessibility requirements are met', () {
      final report = LostTossedCozyTheme.accessibilityReport;
      
      // Check that all combinations meet WCAG AA standards
      for (final entry in report.entries) {
        final data = entry.value;
        expect(data['wcag_aa'], isTrue, 
            reason: '${entry.key} does not meet WCAG AA contrast requirements');
      }
    });

    test('category descriptions are provided', () {
      final categories = ['lost', 'tossed', 'posted', 'marked', 'curious', 'traces'];
      
      for (final category in categories) {
        final description = LostTossedCozyTheme.getCategoryDescription(category);
        expect(description, isNotEmpty);
        expect(description, isNot(equals('Part of our shared landscape'))); // Should not be default
      }
    });

    testWidgets('utility widgets build correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: LostTossedCozyTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                LostTossedCozyTheme.createMicroCopy('Test micro-copy'),
                LostTossedCozyTheme.createCategoryChip(category: 'lost'),
                LostTossedCozyTheme.createDiscoveryCard(
                  child: const Text('Discovery content'),
                ),
                LostTossedCozyTheme.createCommunityButton(
                  text: 'Test Button',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Test micro-copy'), findsOneWidget);
      expect(find.text('LOST'), findsOneWidget);
      expect(find.text('Discovery content'), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
    });

    test('text color calculation works correctly', () {
      // Light background should return dark text
      final darkText = LostTossedCozyTheme.getTextColorForBackground(Colors.white);
      expect(darkText, equals(LostTossedCozyTheme.richCharcoal));

      // Dark background should return light text
      final lightText = LostTossedCozyTheme.getTextColorForBackground(Colors.black);
      expect(lightText, equals(LostTossedCozyTheme.linenWhite));
    });

    test('theme constants are properly defined', () {
      // Spacing constants
      expect(LostTossedCozyTheme.spaceXs, equals(4.0));
      expect(LostTossedCozyTheme.spaceSm, equals(8.0));
      expect(LostTossedCozyTheme.spaceMd, equals(16.0));
      expect(LostTossedCozyTheme.spaceLg, equals(24.0));
      expect(LostTossedCozyTheme.spaceXl, equals(32.0));
      expect(LostTossedCozyTheme.space2xl, equals(48.0));

      // Radius constants
      expect(LostTossedCozyTheme.radiusXs, equals(4.0));
      expect(LostTossedCozyTheme.radiusSm, equals(6.0));
      expect(LostTossedCozyTheme.radiusMd, equals(8.0));
      expect(LostTossedCozyTheme.radiusLg, equals(12.0));
      expect(LostTossedCozyTheme.radiusXl, equals(16.0));
      expect(LostTossedCozyTheme.radius2xl, equals(24.0));
    });
  });
}
