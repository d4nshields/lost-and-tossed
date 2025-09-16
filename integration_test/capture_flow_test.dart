import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lost_and_tossed/main.dart' as app;


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Capture Flow Integration Test', () {
    testWidgets('Complete capture flow with traces category', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to capture screen (assuming there's a capture button)
      final captureButton = find.byIcon(Icons.add_a_photo);
      if (captureButton.evaluate().isNotEmpty) {
        await tester.tap(captureButton);
        await tester.pumpAndSettle();
      }

      // Verify we're on the capture screen
      expect(find.text('Document a Find'), findsOneWidget);

      // Test category selection
      await tester.tap(find.text('Traces'));
      await tester.pumpAndSettle();

      // Verify traces form appears
      expect(find.text('Surface'), findsOneWidget);
      expect(find.text('Freshness'), findsOneWidget);
      expect(find.text('Permanence'), findsOneWidget);

      // Select surface type
      await tester.tap(find.text('Snow'));
      await tester.pumpAndSettle();

      // Select freshness
      await tester.tap(find.text('Hours old'));
      await tester.pumpAndSettle();

      // Select permanence
      await tester.tap(find.text('Ephemeral'));
      await tester.pumpAndSettle();

      // Enter direction
      final directionField = find.byType(TextField).at(0);
      await tester.enterText(directionField, '45');
      await tester.pumpAndSettle();

      // Add notes
      final notesField = find.byType(TextField).at(1);
      await tester.enterText(notesField, 'Test trace notes');
      await tester.pumpAndSettle();

      // Test tag selection
      final tagChips = find.byType(FilterChip);
      if (tagChips.evaluate().isNotEmpty) {
        await tester.tap(tagChips.first);
        await tester.pumpAndSettle();
      }

      // Add caption
      final captionField = find.byType(TextField).last;
      await tester.enterText(captionField, 'A mysterious trace in the snow');
      await tester.pumpAndSettle();

      // Toggle license
      await tester.tap(find.text('CC0'));
      await tester.pumpAndSettle();

      // Toggle disposed
      await tester.tap(find.text('Disposed'));
      await tester.pumpAndSettle();

      // Verify all selections are made
      expect(find.text('Traces'), findsOneWidget);
      expect(find.text('A mysterious trace in the snow'), findsOneWidget);
    });

    testWidgets('Category switching hides/shows trace form', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to capture screen
      final captureButton = find.byIcon(Icons.add_a_photo);
      if (captureButton.evaluate().isNotEmpty) {
        await tester.tap(captureButton);
        await tester.pumpAndSettle();
      }

      // Select traces category
      await tester.tap(find.text('Traces'));
      await tester.pumpAndSettle();

      // Verify trace form is visible
      expect(find.text('Surface'), findsOneWidget);

      // Switch to different category
      await tester.tap(find.text('Lost'));
      await tester.pumpAndSettle();

      // Verify trace form is hidden
      expect(find.text('Surface'), findsNothing);

      // Switch back to traces
      await tester.tap(find.text('Traces'));
      await tester.pumpAndSettle();

      // Verify trace form is visible again
      expect(find.text('Surface'), findsOneWidget);
    });

    testWidgets('Draft persistence on app lifecycle', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to capture screen
      final captureButton = find.byIcon(Icons.add_a_photo);
      if (captureButton.evaluate().isNotEmpty) {
        await tester.tap(captureButton);
        await tester.pumpAndSettle();
      }

      // Make some selections
      await tester.tap(find.text('Curious'));
      await tester.pumpAndSettle();

      // Add caption
      final captionField = find.byType(TextField).first;
      await tester.enterText(captionField, 'Draft test caption');
      await tester.pumpAndSettle();

      // Simulate app going to background (draft should be saved)
      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.paused,
      );
      await tester.pumpAndSettle();

      // Simulate app coming back
      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pumpAndSettle();

      // Verify draft was preserved
      expect(find.text('Draft test caption'), findsOneWidget);
    });
  });
}
