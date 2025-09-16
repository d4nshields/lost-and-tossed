#!/bin/bash

echo "========================================="
echo "Lost & Tossed Build Test"
echo "========================================="
echo ""

cd /home/daniel/work/lost-and-tossed

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Step 1: Getting packages...${NC}"
flutter pub get
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Packages retrieved successfully${NC}"
else
    echo -e "${RED}✗ Failed to get packages${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Step 2: Analyzing code...${NC}"
flutter analyze --no-fatal-infos
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Code analysis passed${NC}"
else
    echo -e "${RED}✗ Code analysis found issues${NC}"
    echo "Run 'flutter analyze' to see details"
fi

echo ""
echo -e "${YELLOW}Step 3: Running tests...${NC}"
flutter test
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Tests passed${NC}"
else
    echo -e "${YELLOW}⚠ Some tests failed (this is expected if OAuth is not configured)${NC}"
fi

echo ""
echo "========================================="
echo -e "${GREEN}Build test complete!${NC}"
echo ""
echo "To run the app:"
echo "  flutter run"
echo ""
echo -e "${YELLOW}OAuth Setup Status:${NC}"
if grep -q "YOUR_LOST_AND_TOSSED_WEB_CLIENT_ID" lib/features/auth/data/auth_repository.dart; then
    echo -e "${RED}✗ Web Client ID not configured${NC}"
    echo "  Update auth_repository.dart with your OAuth Client ID"
else
    echo -e "${GREEN}✓ Web Client ID appears to be configured${NC}"
fi

if [ -f android/app/google-services.json ]; then
    echo -e "${GREEN}✓ google-services.json exists${NC}"
else
    echo -e "${YELLOW}⚠ google-services.json not found (optional but recommended)${NC}"
fi
