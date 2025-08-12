import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:lost_and_tossed/features/explore/presentation/screens/explore_screen.dart';

void main() {
  group('Explore Screen Tests', () {
    testWidgets('should display app bar with title and actions',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExploreScreen(),
          ),
        ),
      );

      // Verify app bar
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('should display category filter chips', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExploreScreen(),
          ),
        ),
      );

      // Verify category chips are present
      expect(find.text('Lost'), findsOneWidget);
      expect(find.text('Tossed'), findsOneWidget);
      expect(find.text('Posted'), findsOneWidget);
      expect(find.text('Marked'), findsOneWidget);
      expect(find.text('Curious'), findsOneWidget);
    });

    testWidgets('should display items grid', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExploreScreen(),
          ),
        ),
      );

      // Verify grid is present
      expect(find.byType(SliverGrid), findsOneWidget);

      // Verify some sample items are displayed
      expect(find.text('Solo Glove Adventure'), findsOneWidget);
      expect(find.text('Event Poster Survivor'), findsOneWidget);
    });

    testWidgets('should handle category chip selection', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExploreScreen(),
          ),
        ),
      );

      // Find and tap the Tossed category chip
      final tossedChip = find.text('Tossed');
      expect(tossedChip, findsOneWidget);

      await tester.tap(tossedChip);
      await tester.pump();

      // In a real implementation, we would verify filter state change
      // For now, we just verify the tap doesn't crash
      expect(tester.takeException(), isNull);
    });

    group('Golden Tests', () {
      testGoldens('should match golden file for explore screen',
          (tester) async {
        await loadAppFonts();

        await tester.pumpWidgetBuilder(
          const ExploreScreen(),
          wrapper: materialAppWrapper(
            theme: ThemeData.light(),
          ),
          surfaceSize: const Size(375, 812), // iPhone 13 size
        );

        await screenMatchesGolden(tester, 'explore_screen');
      });

      testGoldens('should match golden file for category chips',
          (tester) async {
        await loadAppFonts();

        // Test just the category chips section
        await tester.pumpWidgetBuilder(
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                FilterChip(
                  label: Text('Lost'),
                  selected: true,
                  onSelected: null,
                ),
                SizedBox(width: 8),
                FilterChip(
                  label: Text('Tossed'),
                  selected: false,
                  onSelected: null,
                ),
              ],
            ),
          ),
          wrapper: materialAppWrapper(),
          surfaceSize: const Size(375, 120),
        );

        await screenMatchesGolden(tester, 'category_chips');
      });
    });
  });
}
