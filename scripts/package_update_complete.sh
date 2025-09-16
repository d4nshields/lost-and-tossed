#!/bin/bash

echo "========================================="
echo "Package Name Update Complete!"
echo "========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}✅ Package name has been updated to:${NC}"
echo "   com.tinkerplexlabs.lost_and_tossed"
echo ""

echo "Updated files:"
echo "  ✓ android/app/build.gradle"
echo "  ✓ MainActivity.kt"
echo "  ✓ google-services.json.template"
echo "  ✓ Kotlin directory structure"
echo ""

echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1. Clean and rebuild:"
echo "   flutter clean"
echo "   flutter pub get"
echo ""
echo "2. Update OAuth clients in Google Cloud Console:"
echo "   https://console.cloud.google.com/apis/credentials?project=tinkerplexlabs"
echo ""
echo "   Find or create Android OAuth client with:"
echo "   - Package: com.tinkerplexlabs.lost_and_tossed"
echo "   - SHA-1: (run keytool command below to get it)"
echo ""
echo "3. Get your SHA-1 fingerprint:"
echo "   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1"
echo ""
echo "4. If using Firebase/google-services.json:"
echo "   - Go to Firebase Console"
echo "   - Update or recreate the Android app with new package name"
echo "   - Download new google-services.json"
echo "   - Place in android/app/"
echo ""
echo "5. Test the app:"
echo "   flutter run"
echo ""
