// Simple test to verify the app builds correctly with the new theme
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_and_tossed/presentation/theme/cozy_theme.dart';

void main() {
  testWidgets('App builds with cozy theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: LostTossedCozyTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: Text('Lost & Tossed'),
          ),
        ),
      ),
    );

    expect(find.text('Lost & Tossed'), findsOneWidget);
  });
}
