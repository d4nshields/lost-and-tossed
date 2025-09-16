#!/bin/bash

echo "========================================="
echo "Quick Test Summary"
echo "========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Run tests with JSON reporter for clean parsing
echo -e "${YELLOW}Running all tests...${NC}"
flutter test --reporter json 2>/dev/null > /tmp/test_json_output.txt

# Parse JSON output to find failures
echo ""
echo -e "${RED}Failed Tests:${NC}"
grep '"result":"error"' /tmp/test_json_output.txt | grep -o '"name":"[^"]*"' | sed 's/"name":"//g' | sed 's/"//g' | sort | uniq

echo ""
echo -e "${YELLOW}Test files with failures:${NC}"
# List test files that have failures
for file in test/**/*_test.dart test/*_test.dart; do
    if [ -f "$file" ]; then
        flutter test "$file" --reporter json 2>/dev/null | grep -q '"result":"error"' && echo "  ✖ $file"
    fi
done

echo ""
echo -e "${GREEN}Quick Fix Suggestions:${NC}"
echo ""
echo "1. For mock-related failures:"
echo "   These tests might be testing mock behavior rather than real functionality."
echo "   Consider simplifying or focusing on integration tests instead."
echo ""
echo "2. To skip failing tests temporarily:"
echo "   Add 'skip: true' to the test, e.g.:"
echo "   test('description', () { ... }, skip: true);"
echo ""
echo "3. To run only passing tests:"
echo "   flutter test --exclude-tags failing"
echo "   (after tagging failing tests with @Tags(['failing']))"
echo ""
echo "4. To see detailed output for a specific test:"
echo "   flutter test test/path/to/test.dart --name 'test name'"
