#!/bin/bash

echo "========================================="
echo "Direct SHA-1 Extraction from Device"
echo "========================================="
echo ""

PACKAGE="com.tinkerplexlabs.lost_and_tossed"

# Method 1: Get APK and extract cert
echo "Method 1: Pulling APK from device..."
APK_PATH=$(adb shell pm path $PACKAGE | grep base.apk | head -1 | sed 's/package://' | tr -d '\r\n')

if [ ! -z "$APK_PATH" ]; then
    echo "Found APK at: $APK_PATH"
    
    # Create temp dir
    TEMP_DIR=$(mktemp -d)
    
    # Pull the APK
    echo "Pulling APK..."
    adb pull "$APK_PATH" "$TEMP_DIR/app.apk" 2>/dev/null
    
    if [ -f "$TEMP_DIR/app.apk" ]; then
        echo ""
        echo "✅ APK pulled successfully"
        echo ""
        echo "📝 Certificate Information:"
        echo "================================"
        keytool -printcert -jarfile "$TEMP_DIR/app.apk" | grep -E "Owner:|SHA1:|SHA256:|Valid"
        echo "================================"
        echo ""
        
        # Extract just the SHA1
        SHA1=$(keytool -printcert -jarfile "$TEMP_DIR/app.apk" 2>/dev/null | grep "SHA1:" | awk '{print $2}')
        
        if [ ! -z "$SHA1" ]; then
            echo "🔑 SHA-1 Fingerprint (with colons):"
            echo "   $SHA1"
            echo ""
            echo "🔑 SHA-1 Fingerprint (without colons, lowercase):"
            echo "   $(echo $SHA1 | tr -d ':' | tr '[:upper:]' '[:lower:]')"
            echo ""
            
            # Check if it matches known certificates
            DEBUG_SHA="65:CA:DB:32:FA:E7:CB:74:56:80:55:A2:80:24:9B:F5:8F:1F:48:8E"
            
            if [ "$SHA1" = "$DEBUG_SHA" ]; then
                echo "✅ This is the DEBUG certificate"
            else
                echo "⚠️  This is NOT the debug certificate"
                echo "   This might be your release/upload certificate"
            fi
        fi
    else
        echo "❌ Failed to pull APK"
    fi
    
    # Cleanup
    rm -rf "$TEMP_DIR"
else
    echo "❌ Could not find APK path"
fi

echo ""
echo "Method 2: Using aapt (if available)..."
# Try using aapt if available on the system
if command -v aapt &> /dev/null; then
    TEMP_DIR=$(mktemp -d)
    APK_PATH=$(adb shell pm path $PACKAGE | grep base.apk | head -1 | sed 's/package://' | tr -d '\r\n')
    adb pull "$APK_PATH" "$TEMP_DIR/app.apk" 2>/dev/null
    
    if [ -f "$TEMP_DIR/app.apk" ]; then
        aapt dump badging "$TEMP_DIR/app.apk" | grep -E "package:|application-label:"
    fi
    
    rm -rf "$TEMP_DIR"
else
    echo "aapt not found, skipping..."
fi

echo ""
echo "Method 3: Check what certificate your google-services.json expects..."
if [ -f "android/app/google-services.json" ]; then
    echo ""
    echo "📱 OAuth Clients in google-services.json:"
    echo "================================"
    
    if command -v jq &> /dev/null; then
        echo "Android Clients:"
        jq -r '.client[0].oauth_client[] | select(.client_type == 1) | "  SHA1: \(.android_info.certificate_hash // "N/A")"' android/app/google-services.json 2>/dev/null
        
        echo ""
        echo "Web Client:"
        jq -r '.client[0].oauth_client[] | select(.client_type == 3) | "  Client ID: \(.client_id | split(".")[0])"' android/app/google-services.json 2>/dev/null
    else
        # Fallback without jq
        echo "SHA1s registered:"
        grep -o '"certificate_hash":"[^"]*"' android/app/google-services.json | sed 's/"certificate_hash":"/  /' | sed 's/"//'
    fi
    echo "================================"
fi

echo ""
echo "========================================="
echo "🎯 WHAT TO DO NEXT:"
echo "========================================="
echo ""
echo "1. The SHA-1 shown above (Method 1) is what's on your device"
echo ""
echo "2. Compare it with the SHA1s in google-services.json (Method 3)"
echo ""
echo "3. If they DON'T match:"
echo "   a) Add the device SHA-1 to Firebase Console"
echo "   b) Download new google-services.json"
echo "   c) Replace android/app/google-services.json"
echo "   d) Run: flutter clean && flutter run"
echo ""
echo "4. Common SHA-1s to have in Firebase:"
echo "   • Debug: 65:CA:DB:32:FA:E7:CB:74:56:80:55:A2:80:24:9B:F5:8F:1F:48:8E"
echo "   • Upload/Release: [Get from your keystore]"
echo "   • Play Store: [Get from Play Console]"
