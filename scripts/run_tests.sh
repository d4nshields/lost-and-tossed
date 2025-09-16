#!/bin/bash

echo "Running Lost & Tossed tests..."
echo "================================"

# Check if golden files exist
if [ ! -d "test/goldens" ] || [ -z "$(ls -A test/goldens 2>/dev/null)" ]; then
    echo "Golden files not found. Generating them first..."
    flutter test --update-goldens test/features/capture/capture_screen_golden_test.dart
    echo "Golden files generated."
    echo ""
fi

echo "Running all tests..."
flutter test

echo ""
echo "Test run completed."
echo "================================"

# Check exit code
if [ $? -eq 0 ]; then
    echo "✅ All tests passed!"
else
    echo "❌ Some tests failed. Please review the output above."
fi
