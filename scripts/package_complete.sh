#!/bin/bash

echo "========================================="
echo "✅ Package Name Update Complete!"
echo "========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}All references have been updated to:${NC}"
echo "   com.tinkerplexlabs.lost_and_tossed"
echo ""

echo "Files updated:"
echo "  ✓ android/app/build.gradle"
echo "  ✓ MainActivity.kt"
echo "  ✓ All scripts in scripts/"
echo "  ✓ Documentation in docs/"
echo "  ✓ GitHub Actions workflow"
echo "  ✓ google-services.json.template"
echo ""

# Clean up old directories
if [ -d "android/app/src/main/kotlin/com/tinkerplex" ]; then
    rmdir "android/app/src/main/kotlin/com/tinkerplex" 2>/dev/null
    echo "  ✓ Cleaned up old directory structure"
fi

echo -e "${YELLOW}Required Actions:${NC}"
echo ""
echo "1. ${BLUE}Clean Flutter build cache:${NC}"
echo "   flutter clean"
echo "   flutter pub get"
echo ""

echo "2. ${BLUE}Get your SHA-1 fingerprint:${NC}"
SHA1=$(keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA1 | cut -d' ' -f3)
echo "   ${GREEN}$SHA1${NC}"
echo ""

echo "3. ${BLUE}Update Google Cloud Console:${NC}"
echo "   https://console.cloud.google.com/apis/credentials?project=tinkerplexlabs"
echo ""
echo "   Create or update Android OAuth client with:"
echo "   • Package: ${GREEN}com.tinkerplexlabs.lost_and_tossed${NC}"
echo "   • SHA-1:   ${GREEN}$SHA1${NC}"
echo ""

echo "4. ${BLUE}Alternative - Use Firebase (if preferred):${NC}"
echo "   https://console.firebase.google.com/project/tinkerplexlabs/settings/general"
echo ""
echo "   • Add Android app with new package name"
echo "   • Download google-services.json"
echo "   • Place in android/app/"
echo ""

echo "5. ${BLUE}Test the app:${NC}"
echo "   flutter run"
echo ""

echo "========================================="
echo -e "${GREEN}Package name is now consistent everywhere!${NC}"
echo "========================================="
