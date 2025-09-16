#!/bin/bash

echo "========================================="
echo "Google Sign-In Diagnostic Tool"
echo "========================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 1. Check SHA-1
echo -e "${BLUE}1. SHA-1 Fingerprint:${NC}"
SHA1=$(keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA1 | cut -d' ' -f3)
echo "   $SHA1"
echo ""

# 2. Check package name
echo -e "${BLUE}2. Package Name:${NC}"
PACKAGE=$(grep applicationId android/app/build.gradle | grep -o '"[^"]*"' | sed 's/"//g' | head -1)
echo "   $PACKAGE"
echo ""

# 3. Check if google-services.json exists and is valid
echo -e "${BLUE}3. Google Services Configuration:${NC}"
if [ -f android/app/google-services.json ]; then
    echo -e "   ${GREEN}✓ google-services.json exists${NC}"
    
    # Check if it's our template or real
    if grep -q "YOUR_" android/app/google-services.json; then
        echo -e "   ${RED}✗ Contains template placeholders - needs configuration${NC}"
    else
        echo -e "   ${GREEN}✓ Appears to be configured${NC}"
    fi
else
    echo -e "   ${YELLOW}⚠ google-services.json not found${NC}"
    echo "   The app will try to use OAuth client from GCP directly"
fi
echo ""

# 4. Check Web Client ID in code
echo -e "${BLUE}4. Web Client ID Configuration:${NC}"
if grep -q "YOUR_LOST_AND_TOSSED_WEB_CLIENT_ID" lib/features/auth/data/auth_repository.dart; then
    echo -e "   ${RED}✗ Web Client ID not configured in code${NC}"
else
    echo -e "   ${GREEN}✓ Web Client ID appears to be configured${NC}"
fi
echo ""

# 5. Solution
echo "========================================="
echo -e "${YELLOW}TO FIX ERROR CODE 10:${NC}"
echo "========================================="
echo ""
echo "You need EITHER:"
echo ""
echo -e "${GREEN}Option 1: Fix in Google Cloud Console (Easier)${NC}"
echo "1. Go to: https://console.cloud.google.com/apis/credentials?project=tinkerplexlabs"
echo "2. Find or create an Android OAuth client with:"
echo "   - Package: $PACKAGE"
echo "   - SHA-1: $SHA1"
echo ""
echo -e "${GREEN}Option 2: Use Firebase (More Complete)${NC}"
echo "1. Go to: https://console.firebase.google.com"
echo "2. Select or create 'tinkerplexlabs' project"
echo "3. Add Android app with:"
echo "   - Package: $PACKAGE"
echo "   - SHA-1: $SHA1"
echo "   - App nickname: Lost and Tossed"
echo "4. Download google-services.json"
echo "5. Copy to: android/app/google-services.json"
echo "6. Run: flutter clean && flutter pub get"
echo ""
echo -e "${BLUE}Quick Links:${NC}"
echo "GCP: https://console.cloud.google.com/apis/credentials?project=tinkerplexlabs"
echo "Firebase: https://console.firebase.google.com/project/tinkerplexlabs/settings/general"
echo ""
