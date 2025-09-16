#!/bin/bash

echo "========================================="
echo "Google Sign-In Configuration Helper"
echo "========================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get SHA-1
echo -e "${YELLOW}Your Debug SHA-1 Fingerprint:${NC}"
if [ -f ~/.android/debug.keystore ]; then
    SHA1=$(keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA1 | cut -d' ' -f3)
    echo -e "${GREEN}$SHA1${NC}"
    echo ""
    
    # Also get SHA-256 as Google sometimes requires both
    echo -e "${YELLOW}Your Debug SHA-256 Fingerprint:${NC}"
    SHA256=$(keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA256 | cut -d' ' -f3)
    echo -e "${GREEN}$SHA256${NC}"
else
    echo -e "${RED}Debug keystore not found${NC}"
fi

echo ""
echo "========================================="
echo -e "${BLUE}FIXING ERROR CODE 10 - STEPS:${NC}"
echo "========================================="
echo ""
echo "1. Go to: https://console.cloud.google.com/apis/credentials?project=tinkerplexlabs"
echo ""
echo "2. Find your Android OAuth client for Lost & Tossed"
echo "   - Look for one with package: com.tinkerplexlabs.lost_and_tossed"
echo ""
echo "3. Click on it to edit"
echo ""
echo "4. Make sure it has:"
echo "   - Package name: ${GREEN}com.tinkerplexlabs.lost_and_tossed${NC}"
echo "   - SHA-1: ${GREEN}$SHA1${NC}"
echo ""
echo "5. If no Android client exists, create one:"
echo "   - Click '+ CREATE CREDENTIALS' → 'OAuth client ID'"
echo "   - Type: Android"
echo "   - Name: Lost and Tossed Android Debug"
echo "   - Package: com.tinkerplexlabs.lost_and_tossed"
echo "   - SHA-1: $SHA1"
echo ""
echo "6. Save the changes"
echo ""
echo "========================================="
echo -e "${YELLOW}OPTIONAL: Create google-services.json${NC}"
echo "========================================="
echo ""
echo "For better integration, you can also:"
echo "1. Go to https://console.firebase.google.com"
echo "2. Create a new project or select existing 'tinkerplexlabs'"
echo "3. Add Android app with:"
echo "   - Package: com.tinkerplexlabs.lost_and_tossed"
echo "   - SHA-1: $SHA1"
echo "4. Download google-services.json"
echo "5. Place in android/app/"
echo ""
echo "========================================="
echo -e "${BLUE}Current App Configuration:${NC}"
echo "========================================="

# Check if google-services.json exists
if [ -f android/app/google-services.json ]; then
    echo -e "${GREEN}✓ google-services.json exists${NC}"
    # Try to extract package name from it
    if command -v python3 &> /dev/null; then
        PACKAGE=$(python3 -c "import json; data=json.load(open('android/app/google-services.json')); print(data['client'][0]['client_info']['android_client_info']['package_name'])" 2>/dev/null)
        if [ ! -z "$PACKAGE" ]; then
            echo "  Package in config: $PACKAGE"
        fi
    fi
else
    echo -e "${YELLOW}⚠ google-services.json not found${NC}"
    echo "  The app will use the OAuth client from GCP directly"
fi

# Check build.gradle for applicationId
if [ -f android/app/build.gradle ]; then
    APP_ID=$(grep applicationId android/app/build.gradle | grep -o '"[^"]*"' | sed 's/"//g' | head -1)
    echo ""
    echo "Package in build.gradle: ${GREEN}$APP_ID${NC}"
fi

echo ""
echo "========================================="
