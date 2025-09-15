#!/bin/bash

echo "========================================="
echo "Google Sign-In Configuration Validator"
echo "========================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check package name
echo -e "${BLUE}1. Package Name:${NC}"
PACKAGE=$(grep applicationId android/app/build.gradle | grep -o '"[^"]*"' | sed 's/"//g' | head -1)
if [ "$PACKAGE" = "com.tinkerplexlabs.lost_and_tossed" ]; then
    echo -e "   ${GREEN}✓ $PACKAGE${NC}"
else
    echo -e "   ${RED}✗ $PACKAGE (should be com.tinkerplexlabs.lost_and_tossed)${NC}"
fi
echo ""

# Check SHA-1
echo -e "${BLUE}2. Debug SHA-1 Fingerprint:${NC}"
if [ -f ~/.android/debug.keystore ]; then
    SHA1=$(keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA1 | cut -d' ' -f3)
    echo -e "   ${GREEN}$SHA1${NC}"
else
    echo -e "   ${RED}✗ Debug keystore not found${NC}"
fi
echo ""

# Check Kotlin directory
echo -e "${BLUE}3. Kotlin Package Structure:${NC}"
if [ -d "android/app/src/main/kotlin/com/tinkerplexlabs/lost_and_tossed" ]; then
    echo -e "   ${GREEN}✓ Correct directory structure${NC}"
else
    echo -e "   ${RED}✗ Directory not found at expected location${NC}"
fi
echo ""

# Check MainActivity package
echo -e "${BLUE}4. MainActivity Package:${NC}"
if [ -f "android/app/src/main/kotlin/com/tinkerplexlabs/lost_and_tossed/MainActivity.kt" ]; then
    if grep -q "package com.tinkerplexlabs.lost_and_tossed" "android/app/src/main/kotlin/com/tinkerplexlabs/lost_and_tossed/MainActivity.kt"; then
        echo -e "   ${GREEN}✓ Correct package declaration${NC}"
    else
        echo -e "   ${RED}✗ Incorrect package declaration${NC}"
    fi
else
    echo -e "   ${RED}✗ MainActivity.kt not found${NC}"
fi
echo ""

echo "========================================="
echo -e "${YELLOW}OAuth Configuration Requirements:${NC}"
echo "========================================="
echo ""
echo "In Google Cloud Console, you need an Android OAuth client with:"
echo -e "  Package: ${GREEN}com.tinkerplexlabs.lost_and_tossed${NC}"
echo -e "  SHA-1:   ${GREEN}$SHA1${NC}"
echo ""
echo "Quick link to GCP:"
echo "https://console.cloud.google.com/apis/credentials?project=tinkerplexlabs"
echo ""
echo "Or in Firebase Console:"
echo "https://console.firebase.google.com/project/tinkerplexlabs/settings/general"
echo ""

# Offer to copy SHA-1 to clipboard if xclip is available
if command -v xclip &> /dev/null; then
    echo -e "${BLUE}Copy SHA-1 to clipboard? (y/n)${NC}"
    read -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -n "$SHA1" | xclip -selection clipboard
        echo -e "${GREEN}✓ SHA-1 copied to clipboard${NC}"
    fi
fi
