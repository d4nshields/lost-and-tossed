#!/bin/bash

echo "========================================="
echo "Detailed Output for Failing Tests Only"
echo "========================================="
echo ""

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# The known failing test files based on your summary
FAILING_FILES=(
    "test/features/explore/explore_screen_test.dart"
    "test/app_test.dart"
)

for test_file in "${FAILING_FILES[@]}"; do
    if [ -f "$test_file" ]; then
        echo ""
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}Testing: $(basename $test_file)${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        # Run just this test file and capture output
        flutter test "$test_file" --reporter expanded 2>&1 | tee /tmp/test_detail_$(basename $test_file).txt | grep -A 10 -E "^[[:space:]]*✖|^[[:space:]]*Expected:|^[[:space:]]*Actual:|^[[:space:]]*Which:|Error:|Exception:|NoSuchMethodError|type.*is not a subtype" | head -50
        
        echo ""
        echo -e "${YELLOW}First error location:${NC}"
        grep -m 1 -A 3 "package:lost_and_tossed" /tmp/test_detail_$(basename $test_file).txt
    fi
done

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Quick Analysis${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check for common issues
echo ""
echo "Checking for common test issues..."

# Check if it's a widget test issue
if grep -q "pumpWidget\|TestWidgetsFlutterBinding\|WidgetTester" /tmp/test_detail_*.txt 2>/dev/null; then
    echo -e "${YELLOW}⚠ Widget testing issue detected${NC}"
    echo "  Likely missing mock providers or test setup"
fi

if grep -q "type.*is not a subtype\|NoSuchMethodError" /tmp/test_detail_*.txt 2>/dev/null; then
    echo -e "${YELLOW}⚠ Type or method error detected${NC}"
    echo "  Likely mock setup or dependency injection issue"
fi

if grep -q "ProviderScope\|ProviderContainer" /tmp/test_detail_*.txt 2>/dev/null; then
    echo -e "${YELLOW}⚠ Riverpod provider issue detected${NC}"
    echo "  Tests may need ProviderScope wrapper"
fi

echo ""
echo -e "${YELLOW}Full output saved to:${NC}"
echo "  /tmp/test_detail_explore_screen_test.dart.txt"
echo "  /tmp/test_detail_app_test.dart.txt"
echo ""
echo -e "${YELLOW}To see full stack trace for a specific test:${NC}"
echo "  cat /tmp/test_detail_explore_screen_test.dart.txt"
