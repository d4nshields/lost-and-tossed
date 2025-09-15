#!/bin/bash

echo "========================================="
echo "Running Tests After Fixes"
echo "========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Run all tests
echo -e "${YELLOW}Running all tests...${NC}"
flutter test --reporter compact

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ All tests pass!${NC}"
    echo ""
    echo "You can now commit your code with confidence!"
else
    echo ""
    echo -e "${YELLOW}Testing specific fixed files...${NC}"
    echo ""
    
    # Test the fixed files individually
    echo "Testing explore_screen_test.dart..."
    flutter test test/features/explore/explore_screen_test.dart --reporter compact
    
    echo ""
    echo "Testing app_test.dart..."
    flutter test test/app_test.dart --reporter compact
fi
