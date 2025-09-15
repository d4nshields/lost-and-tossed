#!/bin/bash

echo "========================================="
echo "Package Name Fix Script"
echo "========================================="
echo ""

OLD_PACKAGE="com.tinkerplexlabs.lost_and_tossed"
NEW_PACKAGE="com.tinkerplexlabs.lost_and_tossed"

echo "Changing package name from:"
echo "  $OLD_PACKAGE"
echo "to:"
echo "  $NEW_PACKAGE"
echo ""

# Files to update
FILES_TO_UPDATE=(
    "android/app/build.gradle"
    "android/app/src/main/AndroidManifest.xml"
    "docs/OAUTH_SETUP.md"
    "docs/AUTH_IMPLEMENTATION.md"
    "scripts/oauth_setup.sh"
    "scripts/oauth_check.sh"
    "scripts/fix_google_signin.sh"
    "scripts/diagnose_signin.sh"
    "android/app/google-services.json.template"
)

echo "Files to update:"
for file in "${FILES_TO_UPDATE[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file (not found)"
    fi
done

echo ""
read -p "Do you want to proceed with the replacement? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    for file in "${FILES_TO_UPDATE[@]}"; do
        if [ -f "$file" ]; then
            echo "Updating $file..."
            sed -i "s/$OLD_PACKAGE/$NEW_PACKAGE/g" "$file"
        fi
    done
    
    # Also need to rename the Kotlin directory
    if [ -d "android/app/src/main/kotlin/com/tinkerplexlabs/lost_and_tossed" ]; then
        echo "Renaming Kotlin directory..."
        mkdir -p "android/app/src/main/kotlin/com/tinkerplexlabs"
        echo "Kotlin directory already in correct location"
        # Remove old empty directory if it exists
        rmdir "android/app/src/main/kotlin/com/tinkerplex" 2>/dev/null
    fi
    
    echo ""
    echo "✅ Package name updated successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Run: flutter clean"
    echo "2. Run: flutter pub get"
    echo "3. Update your OAuth clients in GCP with the new package name"
    echo "4. If using google-services.json, regenerate it with the new package name"
else
    echo "Cancelled."
fi
