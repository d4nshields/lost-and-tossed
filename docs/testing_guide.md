# Testing Guide for Capture Feature

## Running Tests

### First Time Setup (Generate Golden Files)

Golden tests need reference images to compare against. Run this command first:

```bash
flutter test --update-goldens test/features/capture/capture_screen_golden_test.dart
```

This will create golden reference images in `test/goldens/` directory.

### Running All Tests

After golden files are generated:

```bash
flutter test
```

### Running Specific Test Suites

```bash
# Golden tests only
flutter test test/features/capture/capture_screen_golden_test.dart

# Integration tests
flutter test integration_test/capture_flow_test.dart

# All capture-related tests
flutter test test/features/capture/
```

### Updating Golden Files

If you make intentional UI changes and need to update the golden files:

```bash
flutter test --update-goldens test/features/capture/capture_screen_golden_test.dart
```

## Test Coverage

### Unit Tests
- Repository methods
- State management
- Model serialization

### Widget Tests (Golden)
- Category selection UI
- Trace details form
- License selection
- Surface/Freshness/Permanence chips

### Integration Tests
- Complete capture flow
- Category switching
- Draft persistence
- App lifecycle handling

## Troubleshooting

### Golden Test Failures
- Golden files not found: Run with `--update-goldens` first
- Visual differences: Check if UI changes are intentional, update goldens if needed
- Font loading issues: Ensure `loadAppFonts()` is called in `setUpAll()`

### Compilation Errors
- Run `flutter pub get` after adding dependencies
- Check that all required providers are properly initialized
- Ensure SharedPreferences is mocked or overridden in tests

### Integration Test Issues
- Use `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`
- Mock external services (Supabase, location, etc.)
- Use `pumpAndSettle()` for animations to complete
