#!/bin/bash

echo "Running all tests with fixed timer issue..."
cd /home/daniel/work/lost-and-tossed
flutter test --reporter compact
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ All tests pass!"
    echo ""
    echo "Test Summary:"
    echo "============="
    flutter test --reporter compact | grep -E "^\+[0-9]+" | tail -1
else
    echo ""
    echo "❌ Some tests failed."
    echo "Running failed tests individually for details..."
    flutter test test/app_test.dart --reporter compact
fi

exit $EXIT_CODE
