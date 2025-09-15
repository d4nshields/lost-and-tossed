#!/bin/bash

echo "========================================="
echo "Google Sign-In Debug Helper"
echo "========================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Step 1: Get package name from build.gradle
echo -e "${BLUE}1. Checking Package Name:${NC}"
PACKAGE_NAME=$(grep applicationId android/app/build.gradle | head -1 | awk -F'"' '{print $2}')
echo "   Package: $PACKAGE_NAME"
echo ""

# Step 2: Check current build variant
echo -e "${BLUE}2. Current Build Configuration:${NC}"
if [ -f android/app/google-services.json ]; then
    echo -e "${GREEN}   ✓ google-services.json exists${NC}"
    
    # Check package name in google-services.json
    if command -v jq &> /dev/null; then
        JSON_PACKAGE=$(jq -r '.client[0].client_info.android_client_info.package_name' android/app/google-services.json)
        if [ "$JSON_PACKAGE" = "$PACKAGE_NAME" ]; then
            echo -e "${GREEN}   ✓ Package name matches: $JSON_PACKAGE${NC}"
        else
            echo -e "${RED}   ✗ Package name mismatch!${NC}"
            echo "     Build.gradle: $PACKAGE_NAME"
            echo "     google-services.json: $JSON_PACKAGE"
        fi
        
        echo ""
        echo "   OAuth Clients in google-services.json:"
        jq -r '.client[0].oauth_client[] | "   - Type: \(.client_type) SHA1: \(.android_info.certificate_hash // "N/A")"' android/app/google-services.json 2>/dev/null
    fi
else
    echo -e "${RED}   ✗ google-services.json not found${NC}"
fi
echo ""

# Step 3: Get SHA-1 from currently installed APK
echo -e "${BLUE}3. SHA-1 of Currently Installed App:${NC}"
# Get the base APK path (first line, contains base.apk)
APK_PATH=$(adb shell pm path $PACKAGE_NAME 2>/dev/null | grep base.apk | head -1 | sed 's/package://' | tr -d '\r\n')
if [ ! -z "$APK_PATH" ]; then
    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    
    # Pull APK (handle potential spaces and special chars)
    adb pull "$APK_PATH" "$TEMP_DIR/current.apk" 2>/dev/null
    
    if [ -f "$TEMP_DIR/current.apk" ]; then
        CURRENT_SHA1=$(keytool -printcert -jarfile "$TEMP_DIR/current.apk" 2>/dev/null | grep SHA1: | awk '{print $2}')
        echo -e "${GREEN}   Current app SHA-1: $CURRENT_SHA1${NC}"
        
        # Check if this SHA1 is in google-services.json
        if command -v jq &> /dev/null && [ -f android/app/google-services.json ]; then
            SHA1_NO_COLON=$(echo $CURRENT_SHA1 | tr -d ':' | tr '[:upper:]' '[:lower:]')
            if jq -r '.client[0].oauth_client[].android_info.certificate_hash // empty' android/app/google-services.json 2>/dev/null | grep -qi "$SHA1_NO_COLON"; then
                echo -e "${GREEN}   ✓ This SHA-1 is registered in google-services.json${NC}"
            else
                echo -e "${RED}   ✗ This SHA-1 is NOT in google-services.json!${NC}"
                echo -e "${YELLOW}   You need to add this SHA-1 to Firebase Console${NC}"
            fi
        fi
    else
        echo -e "${RED}   Failed to pull APK${NC}"
        echo "   Trying alternative method..."
        # Alternative: Get SHA1 directly from device
        CERT_INFO=$(adb shell "dumpsys package $PACKAGE_NAME | grep -A 20 'Signatures:'" 2>/dev/null)
        if [ ! -z "$CERT_INFO" ]; then
            echo "   Package signature info found (check manually in Firebase)"
        fi
    fi
    
    # Cleanup
    rm -rf "$TEMP_DIR"
else
    echo -e "${YELLOW}   App not installed on device${NC}"
fi
echo ""

# Step 4: Check all known SHA-1s
echo -e "${BLUE}4. All Known SHA-1 Fingerprints:${NC}"
echo ""

# Debug keystore
echo "   Debug Keystore:"
if [ -f ~/.android/debug.keystore ]; then
    DEBUG_SHA1=$(keytool -list -v \
        -keystore ~/.android/debug.keystore \
        -alias androiddebugkey \
        -storepass android \
        -keypass android 2>/dev/null | grep SHA1: | awk '{print $2}')
    echo "   $DEBUG_SHA1"
else
    echo "   Not found"
fi
echo ""

# Upload keystore (if accessible)
echo "   Upload/Release Keystore:"
if [ -f android/app/lost-and-tossed-upload-key.p12 ]; then
    echo "   (Enter keystore password to see SHA-1)"
    read -s KEYSTORE_PASS
    UPLOAD_SHA1=$(keytool -list -v \
        -keystore android/app/lost-and-tossed-upload-key.p12 \
        -storetype PKCS12 \
        -storepass "$KEYSTORE_PASS" 2>/dev/null | grep SHA1: | head -1 | awk '{print $2}')
    echo "   $UPLOAD_SHA1"
elif [ -f /home/daniel/lost-and-tossed-upload-key.p12 ]; then
    echo "   Found at /home/daniel/lost-and-tossed-upload-key.p12"
    echo "   (Enter keystore password to see SHA-1)"
    read -s KEYSTORE_PASS
    UPLOAD_SHA1=$(keytool -list -v \
        -keystore /home/daniel/lost-and-tossed-upload-key.p12 \
        -storetype PKCS12 \
        -storepass "$KEYSTORE_PASS" 2>/dev/null | grep SHA1: | head -1 | awk '{print $2}')
    echo "   $UPLOAD_SHA1"
else
    echo "   Not found in expected locations"
fi
echo ""

# Step 5: Recommendations
echo -e "${BLUE}5. Next Steps:${NC}"
echo ""
echo "1. The SHA-1 shown in 'Current app SHA-1' above MUST be added to Firebase"
echo ""
echo "2. Go to Firebase Console → Project Settings → Your Android App"
echo ""
echo "3. Add ALL these SHA-1 fingerprints:"
echo "   - Debug SHA-1 (for local debug builds)"
echo "   - Upload SHA-1 (for local release builds)"
echo "   - Current app SHA-1 (from step 3 above)"
echo "   - Play Store SHA-1 (from Play Console → Setup → App signing)"
echo ""
echo "4. Download the updated google-services.json"
echo ""
echo "5. Place it in android/app/google-services.json"
echo ""
echo "6. Clean rebuild:"
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter run --release  # or just 'flutter run' for debug"
echo ""

# Step 6: Quick Firebase update command
echo -e "${BLUE}6. Quick Command to Update GitHub Secret:${NC}"
echo ""
echo "After downloading new google-services.json:"
echo "base64 -w 0 android/app/google-services.json"
echo ""
echo "Then update GOOGLE_SERVICES_JSON_BASE64 in GitHub Secrets"
