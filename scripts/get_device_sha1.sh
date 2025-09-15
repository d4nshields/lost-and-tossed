#!/bin/bash

echo "========================================="
echo "Get Current App SHA-1 from Device"
echo "========================================="
echo ""

PACKAGE="com.tinkerplexlabs.lost_and_tossed"

# Method 1: Using pm dump
echo "Method 1 - Package Manager Dump:"
CERT_HEX=$(adb shell "pm dump $PACKAGE | grep 'signatures=' | head -1" | sed 's/.*signatures=\[//' | sed 's/\].*//')

if [ ! -z "$CERT_HEX" ]; then
    # Convert hex to SHA1
    echo "Raw cert data found, extracting SHA-1..."
    
    # Save cert to temp file
    TEMP_CERT=$(mktemp)
    echo "$CERT_HEX" | xxd -r -p > "$TEMP_CERT"
    
    # Get SHA1
    SHA1=$(openssl x509 -inform DER -in "$TEMP_CERT" -noout -fingerprint -sha1 2>/dev/null | cut -d'=' -f2)
    
    if [ ! -z "$SHA1" ]; then
        echo "SHA-1: $SHA1"
        echo ""
        echo "SHA-1 (no colons): $(echo $SHA1 | tr -d ':')"
    else
        echo "Could not extract SHA-1 from certificate"
    fi
    
    rm -f "$TEMP_CERT"
else
    echo "No certificate data found via pm dump"
fi

echo ""
echo "Method 2 - Dumpsys Package:"
adb shell "dumpsys package $PACKAGE" | grep -A 20 "Signatures:" | head -25

echo ""
echo "========================================="
echo "IMPORTANT:"
echo "========================================="
echo "The SHA-1 shown above is what's ACTUALLY on your device."
echo "This EXACT SHA-1 must be registered in Firebase Console."
echo ""
echo "To fix:"
echo "1. Copy the SHA-1 (with colons) from above"
echo "2. Go to Firebase Console → Project Settings → Your Android App"
echo "3. Add this SHA-1 as a new fingerprint"
echo "4. Download the updated google-services.json"
echo "5. Replace android/app/google-services.json"
echo "6. Run: flutter clean && flutter pub get && flutter run"
