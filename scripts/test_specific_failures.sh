#!/bin/bash

echo "========================================="
echo "Running Only Failing Tests"
echo "========================================="
echo ""

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Based on your output, these specific tests are failing:
FAILING_TESTS=(
    "test/features/explore/explore_screen_test.dart::should display app bar with title and actions"
    "test/features/explore/explore_screen_test.dart::should display category filter chips"
    "test/features/explore/explore_screen_test.dart::should display items grid"
    "test/features/explore/explore_screen_test.dart::should handle category chip selection"
    "test/features/explore/explore_screen_test.dart::should render explore screen without errors"
    "test/app_test.dart::shows loading screen during initialization"
)

echo -e "${YELLOW}Running individual failing tests to isolate errors...${NC}"
echo ""

for test_spec in "${FAILING_TESTS[@]}"; do
    # Split file and test name
    IFS='::' read -r file test_name <<< "$test_spec"
    
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Test: $test_name${NC}"
    echo -e "${YELLOW}File: $(basename $file)${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Run specific test by name
    flutter test "$file" --name "$test_name" 2>&1 | grep -v "package:test_api\|package:matcher\|package:stack_trace" | grep -A 5 -B 2 -E "✖|Expected:|Actual:|Error:|Exception:|NoSuchMethodError|type.*is not a subtype"
    
    echo ""
done

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Summary${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Failing tests:"
echo "1. explore_screen_test.dart (5 tests) - Likely missing mock setup"
echo "2. app_test.dart (1 test) - Loading screen initialization issue"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Run: bash scripts/test_failing_details.sh"
echo "   To see detailed error messages"
echo ""
echo "2. Or skip these tests temporarily to commit:"
echo "   bash scripts/skip_specific_tests.sh"
