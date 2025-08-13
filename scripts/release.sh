#!/bin/bash

# Release build script for Lost & Tossed
# Usage: ./scripts/release.sh [version_name]
# Example: ./scripts/release.sh 0.1.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Lost & Tossed Release Builder${NC}"
echo "=================================="

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Error: Must run from project root directory${NC}"
    exit 1
fi

# Check if signing key exists
if [ ! -f "android/key.properties" ]; then
    echo -e "${RED}❌ Error: android/key.properties not found${NC}"
    echo "Please set up your signing key first:"
    echo "1. Generate P12 key: keytool -genkey -v -keystore android/app/lost-and-tossed-upload-key.p12 -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 -alias upload"
    echo "2. Copy android/key.properties.template to android/key.properties"
    echo "3. Fill in your key information"
    exit 1
fi

# Get version name (default or from argument)
VERSION_NAME=${1:-"0.1.0"}

# Generate version numbers using Dart script
echo -e "${YELLOW}📊 Generating version numbers...${NC}"
VERSION_INFO=$(dart scripts/generate_version.dart "$VERSION_NAME")
VERSION_NAME=$(echo "$VERSION_INFO" | grep "VERSION_NAME=" | cut -d'=' -f2)
VERSION_CODE=$(echo "$VERSION_INFO" | grep "VERSION_CODE=" | cut -d'=' -f2)

echo "Version Name: $VERSION_NAME"
echo "Version Code: $VERSION_CODE"

# Update pubspec.yaml
echo -e "${YELLOW}📝 Updating pubspec.yaml...${NC}"
sed -i.bak "s/^version: .*/version: $VERSION_NAME+$VERSION_CODE/" pubspec.yaml
rm pubspec.yaml.bak

# Clean and get dependencies
echo -e "${YELLOW}🧹 Cleaning and getting dependencies...${NC}"
flutter clean
flutter pub get

# Build App Bundle
echo -e "${YELLOW}🏗️ Building App Bundle...${NC}"
flutter build appbundle --release

# Build APK (for testing)
echo -e "${YELLOW}📱 Building APK...${NC}"
flutter build apk --release

# Show results
echo ""
echo -e "${GREEN}✅ Build Complete!${NC}"
echo "=================================="
echo "App ID: com.tinkerplex.lost_and_tossed"
echo "Version: $VERSION_NAME ($VERSION_CODE)"
echo ""
echo "Files generated:"
echo "📦 App Bundle: build/app/outputs/bundle/release/app-release.aab"
echo "📱 APK: build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Test the APK on a device"
echo "2. Upload the App Bundle (.aab) to Google Play Console"
echo "3. Create a release in GitHub with tag: v$VERSION_NAME"
