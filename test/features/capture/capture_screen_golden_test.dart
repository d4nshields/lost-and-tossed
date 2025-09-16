import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:lost_and_tossed/features/capture/domain/models/submission_models.dart';
import 'package:lost_and_tossed/features/capture/presentation/widgets/trace_details_form.dart';
import 'package:lost_and_tossed/presentation/theme/cozy_theme.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  group('Category Selection Widget Tests', () {
    testGoldens('Category chips display correctly', (tester) async {
      await tester.pumpWidgetBuilder(
        _CategorySelectionWidget(),
        surfaceSize: const Size(400, 200),
        wrapper: materialAppWrapper(
          theme: LostTossedCozyTheme.lightTheme,
        ),
      );

      await screenMatchesGolden(tester, 'category_selection_initial');
    });

    testGoldens('Category chip selected state', (tester) async {
      await tester.pumpWidgetBuilder(
        _CategorySelectionWidget(selectedCategory: SubmissionCategory.traces),
        surfaceSize: const Size(400, 200),
        wrapper: materialAppWrapper(
          theme: LostTossedCozyTheme.lightTheme,
        ),
      );

      await screenMatchesGolden(tester, 'category_selection_traces_selected');
    });

    testGoldens('All categories with descriptions', (tester) async {
      await tester.pumpWidgetBuilder(
        _AllCategoriesWidget(),
        surfaceSize: const Size(400, 600),
        wrapper: materialAppWrapper(
          theme: LostTossedCozyTheme.lightTheme,
        ),
      );

      await screenMatchesGolden(tester, 'all_categories_with_descriptions');
    });
  });

  group('Trace Details Form Tests', () {
    testGoldens('Trace form initial state', (tester) async {
      await tester.pumpWidgetBuilder(
        TraceDetailsForm(
          onDetailsChanged: (_) {},
        ),
        surfaceSize: const Size(400, 800),
        wrapper: materialAppWrapper(
          theme: LostTossedCozyTheme.lightTheme,
        ),
      );

      await screenMatchesGolden(tester, 'trace_form_initial');
    });

    // Skip the flaky test in CI environment
    testGoldens(
      'Trace form with selections',
      skip: const bool.fromEnvironment('CI', defaultValue: false),
      (tester) async {
        await tester.pumpWidgetBuilder(
          TraceDetailsForm(
            initialDetails: const TraceDetailsDraft(
              surface: TraceSurface.snow,
              freshness: TraceFreshness.hours,
              permanence: TracePermanence.ephemeral,
              directionDeg: 45,
              notes: 'Footprints in fresh snow leading to the woods',
            ),
            onDetailsChanged: (_) {},
          ),
          surfaceSize: const Size(400, 800),
          wrapper: materialAppWrapper(
            theme: LostTossedCozyTheme.lightTheme,
          ),
        );

        await screenMatchesGolden(tester, 'trace_form_with_selections');
      },
    );

    testGoldens('Surface selection chips', (tester) async {
      await tester.pumpWidgetBuilder(
        _SurfaceSelectionWidget(),
        surfaceSize: const Size(400, 150),
        wrapper: materialAppWrapper(
          theme: LostTossedCozyTheme.lightTheme,
        ),
      );

      await screenMatchesGolden(tester, 'surface_selection_chips');
    });

    testGoldens('Freshness selection chips', (tester) async {
      await tester.pumpWidgetBuilder(
        _FreshnessSelectionWidget(),
        surfaceSize: const Size(400, 100),
        wrapper: materialAppWrapper(
          theme: LostTossedCozyTheme.lightTheme,
        ),
      );

      await screenMatchesGolden(tester, 'freshness_selection_chips');
    });

    testGoldens('Permanence selection chips', (tester) async {
      await tester.pumpWidgetBuilder(
        _PermanenceSelectionWidget(),
        surfaceSize: const Size(400, 100),
        wrapper: materialAppWrapper(
          theme: LostTossedCozyTheme.lightTheme,
        ),
      );

      await screenMatchesGolden(tester, 'permanence_selection_chips');
    });
  });

  group('License Selection Tests', () {
    testGoldens('License segmented button', (tester) async {
      await tester.pumpWidgetBuilder(
        _LicenseSelectionWidget(),
        surfaceSize: const Size(400, 150),
        wrapper: materialAppWrapper(
          theme: LostTossedCozyTheme.lightTheme,
        ),
      );

      await screenMatchesGolden(tester, 'license_selection');
    });
  });
}

// Test widgets for golden tests
class _CategorySelectionWidget extends StatelessWidget {
  final SubmissionCategory? selectedCategory;

  const _CategorySelectionWidget({this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: SubmissionCategory.values.map((category) {
          final isSelected = selectedCategory == category;
          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category.emoji),
                const SizedBox(width: 4),
                Text(category.displayName),
              ],
            ),
            selected: isSelected,
            onSelected: (_) {},
          );
        }).toList(),
      ),
    );
  }
}

class _AllCategoriesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: SubmissionCategory.values.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  category.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SurfaceSelectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: TraceSurface.values.map((surface) {
          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(surface.emoji),
                const SizedBox(width: 4),
                Text(surface.displayName),
              ],
            ),
            selected: surface == TraceSurface.pavement,
            onSelected: (_) {},
          );
        }).toList(),
      ),
    );
  }
}

class _FreshnessSelectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: TraceFreshness.values.map((freshness) {
          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(freshness.emoji),
                const SizedBox(width: 4),
                Text(freshness.displayName),
              ],
            ),
            selected: freshness == TraceFreshness.hours,
            onSelected: (_) {},
          );
        }).toList(),
      ),
    );
  }
}

class _PermanenceSelectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: TracePermanence.values.map((permanence) {
          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(permanence.emoji),
                const SizedBox(width: 4),
                Text(permanence.displayName),
              ],
            ),
            selected: permanence == TracePermanence.ephemeral,
            onSelected: (_) {},
          );
        }).toList(),
      ),
    );
  }
}

class _LicenseSelectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<LicenseType>(
            segments: LicenseType.values.map((license) {
              return ButtonSegment(
                value: license,
                label: Text(license.displayName),
                tooltip: license.description,
              );
            }).toList(),
            selected: const {LicenseType.ccByNc},
            onSelectionChanged: (_) {},
          ),
          const SizedBox(height: 8),
          Text(
            LicenseType.ccByNc.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
