#!/bin/bash

echo "========================================="
echo "SHA-1 Fingerprint Checker"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Debug keystore
echo -e "${BLUE}1. Debug Keystore SHA-1:${NC}"
if [ -f ~/.android/debug.keystore ]; then
    DEBUG_SHA1=$(keytool -list -v \
        -keystore ~/.android/debug.keystore \
        -alias androiddebugkey \
        -storepass android \
        -keypass android 2>/dev/null | grep SHA1 | awk '{print $2}')
    echo -e "${GREEN}   $DEBUG_SHA1${NC}"
else
    echo -e "${YELLOW}   Debug keystore not found${NC}"
fi
echo ""

# Upload/Release keystore
echo -e "${BLUE}2. Upload/Release Keystore SHA-1:${NC}"
echo "   Enter path to your upload keystore (or press Enter to skip):"
read -r KEYSTORE_PATH

if [ ! -z "$KEYSTORE_PATH" ] && [ -f "$KEYSTORE_PATH" ]; then
    echo "   Enter keystore password:"
    read -s KEYSTORE_PASS
    echo ""
    
    # Try PKCS12 format first
    UPLOAD_SHA1=$(keytool -list -v \
        -keystore "$KEYSTORE_PATH" \
        -storetype PKCS12 \
        -storepass "$KEYSTORE_PASS" 2>/dev/null | grep SHA1 | head -1 | awk '{print $2}')
    
    # If that fails, try JKS format
    if [ -z "$UPLOAD_SHA1" ]; then
        UPLOAD_SHA1=$(keytool -list -v \
            -keystore "$KEYSTORE_PATH" \
            -storepass "$KEYSTORE_PASS" 2>/dev/null | grep SHA1 | head -1 | awk '{print $2}')
    fi
    
    if [ ! -z "$UPLOAD_SHA1" ]; then
        echo -e "${GREEN}   $UPLOAD_SHA1${NC}"
    else
        echo -e "${YELLOW}   Could not extract SHA1 - check password and keystore format${NC}"
    fi
else
    echo -e "${YELLOW}   Skipped${NC}"
fi
echo ""

# Instructions for Play Store
echo -e "${BLUE}3. Play Store App Signing SHA-1:${NC}"
echo "   To get this:"
echo "   1. Go to Google Play Console"
echo "   2. Select your app"
echo "   3. Navigate to: Setup → App signing"
echo "   4. Copy the SHA-1 from 'App signing key certificate'"
echo ""

# Check google-services.json
echo -e "${BLUE}4. Checking google-services.json:${NC}"
GOOGLE_SERVICES_PATH="android/app/google-services.json"

if [ -f "$GOOGLE_SERVICES_PATH" ]; then
    echo -e "${GREEN}   ✓ File exists${NC}"
    
    # Extract OAuth client info
    if command -v jq &> /dev/null; then
        echo "   OAuth clients found:"
        jq -r '.client[0].oauth_client[].android_info.certificate_hash // empty' "$GOOGLE_SERVICES_PATH" 2>/dev/null | while read -r hash; do
            if [ ! -z "$hash" ]; then
                echo "   - $hash"
            fi
        done
    else
        echo "   (Install 'jq' to see OAuth client details)"
    fi
else
    echo -e "${YELLOW}   File not found at $GOOGLE_SERVICES_PATH${NC}"
fi
echo ""

echo "========================================="
echo "Next Steps:"
echo "========================================="
echo ""
echo "1. Add ALL SHA-1 fingerprints to Firebase Console:"
echo "   - Debug SHA-1"
echo "   - Upload/Release SHA-1"
echo "   - Play Store App Signing SHA-1"
echo ""
echo "2. Download the updated google-services.json"
echo ""
echo "3. Test with:"
echo "   - Debug build: flutter run"
echo "   - Release build: flutter run --release"
echo ""
echo "4. Update GitHub secret GOOGLE_SERVICES_JSON_BASE64"
echo ""

# Build type detection
echo -e "${BLUE}Current Build Configuration:${NC}"
if [ -f "android/app/build.gradle" ]; then
    if grep -q "signingConfig.*release" android/app/build.gradle; then
        echo "   Release signing is configured ✓"
    else
        echo "   Only debug signing detected"
    fi
fi
