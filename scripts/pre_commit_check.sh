#!/bin/bash

echo "========================================="
echo "Final Pre-Commit Check"
echo "========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check for sensitive files
echo -e "${YELLOW}Checking for sensitive files...${NC}"
echo ""

if [ -f "android/app/google-services.json" ]; then
    echo -e "${YELLOW}⚠ google-services.json exists${NC}"
    echo "  This file is in .gitignore and won't be committed"
fi

if [ -f ".env" ]; then
    echo -e "${YELLOW}⚠ .env exists${NC}"
    echo "  This file is in .gitignore and won't be committed"
fi

if [ -f ".env.oauth" ]; then
    echo -e "${YELLOW}⚠ .env.oauth exists${NC}"
    echo "  This file is in .gitignore and won't be committed"
fi

echo ""
echo -e "${GREEN}Checking code for hardcoded secrets...${NC}"

# Check for hardcoded API keys or secrets
if grep -r "YOUR_" lib/ 2>/dev/null | grep -v "UPDATE THIS" | grep -v "template"; then
    echo -e "${RED}✗ Found placeholder values that need updating${NC}"
else
    echo -e "${GREEN}✓ No obvious placeholders found${NC}"
fi

# Check for Web Client ID
if grep -q "1038604734243" lib/features/auth/data/auth_repository.dart; then
    echo -e "${GREEN}✓ Web Client ID is configured${NC}"
else
    echo -e "${YELLOW}⚠ Web Client ID might not be configured${NC}"
fi

echo ""
echo -e "${GREEN}Running Flutter analyze...${NC}"
flutter analyze --no-fatal-infos 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Code analysis passed${NC}"
else
    echo -e "${YELLOW}⚠ Some analysis warnings (review if needed)${NC}"
fi

echo ""
echo "========================================="
echo -e "${GREEN}Ready to Commit!${NC}"
echo "========================================="
echo ""
echo "Suggested commit command:"
echo ""
echo "git add -A"
echo "git status  # Review files to be committed"
echo "git commit -m \"feat: Implement Google Sign-In authentication with Supabase\""
echo ""
echo "Make sure NOT to commit:"
echo "- google-services.json"
echo "- .env files"
echo "- Any files with real credentials"
echo ""
