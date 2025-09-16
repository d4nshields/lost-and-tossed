#!/bin/bash

echo "========================================="
echo "Test Runner - File by File"
echo "========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

FAILED_TESTS=()
PASSED_TESTS=()

# Find all test files
TEST_FILES=$(find test -name "*_test.dart" -type f 2>/dev/null)

if [ -z "$TEST_FILES" ]; then
    echo "No test files found"
    exit 1
fi

echo "Found test files:"
echo "$TEST_FILES" | wc -l
echo ""

# Run each test file separately
for test_file in $TEST_FILES; do
    echo -n "Testing $(basename $test_file)... "
    
    # Run test silently and check result
    flutter test "$test_file" --no-pub > /tmp/single_test_output.txt 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ PASSED${NC}"
        PASSED_TESTS+=("$test_file")
    else
        echo -e "${RED}✖ FAILED${NC}"
        FAILED_TESTS+=("$test_file")
        
        # Show just the failure reason (first few lines after the test name)
        echo "  Failure details:"
        grep -A 3 "✖" /tmp/single_test_output.txt | head -10 | sed 's/^/    /'
        echo ""
    fi
done

echo ""
echo "========================================="
echo "Test Summary"
echo "========================================="
echo ""

echo -e "${GREEN}Passed: ${#PASSED_TESTS[@]} tests${NC}"
for test in "${PASSED_TESTS[@]}"; do
    echo "  ✅ $(basename $test)"
done

echo ""
echo -e "${RED}Failed: ${#FAILED_TESTS[@]} tests${NC}"
for test in "${FAILED_TESTS[@]}"; do
    echo "  ✖ $(basename $test)"
done

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}To debug a specific failing test:${NC}"
    echo "flutter test ${FAILED_TESTS[0]} --reporter expanded"
    echo ""
    echo -e "${YELLOW}To run with verbose output:${NC}"
    echo "flutter test ${FAILED_TESTS[0]} -v"
fi
