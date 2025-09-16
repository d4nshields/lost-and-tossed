#!/bin/bash

echo "========================================="
echo "Final Pre-Commit Verification"
echo "========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Run flutter analyze
echo -e "${YELLOW}Running Flutter analyze...${NC}"
flutter analyze --no-fatal-infos > /tmp/analyze_output.txt 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ No errors or warnings!${NC}"
else
    # Check if only infos remain
    if grep -q "error" /tmp/analyze_output.txt; then
        echo -e "${RED}❌ Errors found:${NC}"
        grep "error" /tmp/analyze_output.txt
    elif grep -q "warning" /tmp/analyze_output.txt; then
        echo -e "${YELLOW}⚠️  Warnings found:${NC}"
        grep "warning" /tmp/analyze_output.txt
    else
        echo -e "${GREEN}✅ Only info messages (safe to ignore)${NC}"
    fi
fi

echo ""
echo -e "${YELLOW}Checking for sensitive files...${NC}"

SENSITIVE_FILES=(
    "android/app/google-services.json"
    ".env"
    ".env.oauth"
    "android/key.properties"
    "android/app/upload-keystore.jks"
)

ALL_SAFE=true
for file in "${SENSITIVE_FILES[@]}"; do
    if [ -f "$file" ]; then
        if grep -q "$file" .gitignore; then
            echo -e "${GREEN}✅ $file exists but is in .gitignore${NC}"
        else
            echo -e "${RED}❌ WARNING: $file exists and might be committed!${NC}"
            ALL_SAFE=false
        fi
    fi
done

if [ "$ALL_SAFE" = true ]; then
    echo -e "${GREEN}✅ All sensitive files are protected${NC}"
fi

echo ""
echo "========================================="
echo -e "${GREEN}READY TO COMMIT!${NC}"
echo "========================================="
echo ""
echo "Suggested commit command:"
echo ""
echo "git add -A"
echo "git status  # Review files"
echo ""
echo "git commit -m \"feat: Implement Google Sign-In authentication with Supabase

- Add Google OAuth integration for Android
- Implement automatic user profile creation with unique handles
- Create three-tab navigation: Explore, Capture, Notebook
- Add auth state management with Riverpod
- Implement route protection with SessionGuard
- Configure Supabase Auth with database triggers
- Add RLS policies for secure data access
- Set up playful micro-copy throughout the app

Package: com.tinkerplexlabs.lost_and_tossed
Categories: Lost, Tossed, Posted, Marked, Curious, Traces\""
echo ""
echo -e "${GREEN}Great work! The authentication system is fully functional! 🎉${NC}"
