import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lost_and_tossed/main.dart';
import 'package:lost_and_tossed/core/theme/app_theme.dart';
import 'package:lost_and_tossed/presentation/theme/cozy_theme.dart';
import 'package:lost_and_tossed/core/constants/app_constants.dart';

void main() {
  group('LostAndTossedApp', () {
    testWidgets('shows loading screen during initialization',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: LostAndTossedApp()));

      // Should show loading screen initially
      expect(find.text('Lost & Tossed'), findsOneWidget);
      expect(find.text('Gathering stories from the streets...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('applies correct theme', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: LostAndTossedApp()));

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));

      expect(materialApp.title, equals(AppConstants.appName));
      expect(materialApp.theme, equals(LostTossedCozyTheme.lightTheme));
      expect(materialApp.darkTheme, equals(LostTossedCozyTheme.lightTheme)); // Currently using light theme for both
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });
  });

  group('AppTheme', () {
    test('has correct primary colors', () {
      expect(AppTheme.primaryGreen, equals(const Color(0xFF2D6B3E)));
      expect(AppTheme.secondaryOrange, equals(const Color(0xFFF77F3A)));
      expect(AppTheme.accentBlue, equals(const Color(0xFF4A90C2)));
    });

    test('category colors are defined', () {
      expect(AppTheme.categoryColors.length, equals(6)); // Updated to 6 categories
      expect(AppTheme.categoryColors['lost'], isNotNull);
      expect(AppTheme.categoryColors['tossed'], isNotNull);
      expect(AppTheme.categoryColors['posted'], isNotNull);
      expect(AppTheme.categoryColors['marked'], isNotNull);
      expect(AppTheme.categoryColors['curious'], isNotNull);
      expect(AppTheme.categoryColors['traces'], isNotNull);
    });

    test('getCategoryColor returns correct colors', () {
      expect(AppTheme.getCategoryColor('lost'),
          equals(AppTheme.categoryColors['lost']));
      expect(AppTheme.getCategoryColor('invalid'), equals(AppTheme.warmGray));
    });
  });

  group('AppConstants', () {
    test('has correct app information', () {
      expect(AppConstants.appName, equals('Lost & Tossed'));
      expect(AppConstants.appVersion, equals('1.0.0+1'));
      expect(AppConstants.appDescription, isNotEmpty);
    });

    test('has valid Supabase configuration', () {
      expect(AppConstants.supabaseUrl, startsWith('https://'));
      expect(AppConstants.supabaseAnonKey, isNotEmpty);
    });

    test('has reasonable constraints', () {
      expect(AppConstants.maxImageSizeBytes, equals(5 * 1024 * 1024));
      expect(AppConstants.geohashPrecision, equals(5));
      expect(AppConstants.defaultPageSize, equals(20));
      expect(AppConstants.maxTitleLength, equals(100));
      expect(AppConstants.maxDescriptionLength, equals(1000));
    });
  });
}
