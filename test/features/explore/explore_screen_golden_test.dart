import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:lost_and_tossed/features/explore/presentation/screens/explore_screen.dart';

void main() {
  group('ExploreScreen Golden Tests', () {
    testGoldens('explore screen renders correctly', (tester) async {
      await tester.pumpWidgetBuilder(
        const ProviderScope(
          child: ExploreScreen(),
        ),
        wrapper: materialAppWrapper(
          theme: ThemeData.light(),
        ),
        surfaceSize: const Size(375, 812), // iPhone X size
      );

      await screenMatchesGolden(tester, 'explore_screen_light');
    });

    testGoldens('explore screen renders correctly in dark mode', (tester) async {
      await tester.pumpWidgetBuilder(
        const ProviderScope(
          child: ExploreScreen(),
        ),
        wrapper: materialAppWrapper(
          theme: ThemeData.dark(),
        ),
        surfaceSize: const Size(375, 812),
      );

      await screenMatchesGolden(tester, 'explore_screen_dark');
    });
  });
}
