#!/bin/bash

echo "========================================="
echo "Running Tests with Filtered Output"
echo "========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Run tests and capture output
echo -e "${YELLOW}Running tests...${NC}"
flutter test --no-pub --reporter compact > /tmp/test_output.txt 2>&1
TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
fi

echo -e "${RED}❌ Some tests failed${NC}"
echo ""
echo "Failed Tests Summary:"
echo "====================="

# Extract just the test names and failure reasons
grep -E "^[[:space:]]*✖|FAILED:|Expected:|Actual:|Which:|package:test" /tmp/test_output.txt | grep -v "package:test_api" | head -50

echo ""
echo "Test Statistics:"
echo "================"
grep -E "^[0-9]+ test.*passed" /tmp/test_output.txt

echo ""
echo -e "${YELLOW}To see full output with stack traces, run:${NC}"
echo "cat /tmp/test_output.txt"
echo ""
echo -e "${YELLOW}To run a specific test file:${NC}"
echo "flutter test test/path/to/specific_test.dart"
echo ""
echo -e "${YELLOW}To see which test files are failing:${NC}"
echo ""

# List which test files have failures
echo "Failed test files:"
grep -l "✖" test/**/*_test.dart 2>/dev/null || echo "Checking test files..."

# Alternative way to find failed tests
flutter test --reporter json 2>/dev/null | grep -o '"test":{"name":"[^"]*"' | grep -o '"[^"]*"$' | sed 's/"//g' | head -10
