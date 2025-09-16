#!/bin/bash

echo "========================================="
echo "App Icon Generation Script"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if icon.png exists
if [ ! -f "assets/images/icon.png" ]; then
    echo -e "${RED}❌ Error: assets/images/icon.png not found${NC}"
    echo "Please ensure you have an icon.png file in assets/images/"
    exit 1
fi

echo -e "${GREEN}✓ Found icon.png${NC}"

# Check icon dimensions
if command -v identify &> /dev/null; then
    DIMENSIONS=$(identify -format "%wx%h" assets/images/icon.png)
    echo -e "${BLUE}Icon dimensions: $DIMENSIONS${NC}"
    
    # Recommend 1024x1024 for best results
    if [ "$DIMENSIONS" != "1024x1024" ]; then
        echo -e "${YELLOW}⚠️  Recommendation: Use a 1024x1024 PNG for best results${NC}"
    fi
else
    echo -e "${YELLOW}ImageMagick not installed, skipping dimension check${NC}"
fi

echo ""
echo -e "${BLUE}Step 1: Installing dependencies...${NC}"
flutter pub get

echo ""
echo -e "${BLUE}Step 2: Generating app icons...${NC}"
echo "This will create icons in all required sizes for Android"
echo ""

# Run the icon generator
flutter pub run flutter_launcher_icons

echo ""
echo -e "${BLUE}Step 3: Verifying generated icons...${NC}"

# Check if icons were generated
ICON_COUNT=$(find android/app/src/main/res -name "ic_launcher.png" 2>/dev/null | wc -l)

if [ $ICON_COUNT -gt 0 ]; then
    echo -e "${GREEN}✓ Generated $ICON_COUNT icon sizes${NC}"
    echo ""
    echo "Icons generated in:"
    find android/app/src/main/res -name "ic_launcher.png" -o -name "ic_launcher_foreground.png" 2>/dev/null | head -10
else
    echo -e "${RED}❌ No icons found. Generation may have failed.${NC}"
fi

echo ""
echo -e "${BLUE}Step 4: Building and installing app...${NC}"
echo ""
echo "Choose build type:"
echo "1) Debug build (faster, for testing)"
echo "2) Release build (optimized, signed)"
echo ""
read -p "Enter choice (1 or 2): " BUILD_CHOICE

if [ "$BUILD_CHOICE" = "2" ]; then
    echo -e "${BLUE}Building release APK...${NC}"
    flutter build apk --release
    
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        echo -e "${GREEN}✓ Release APK built successfully${NC}"
        echo ""
        echo -e "${BLUE}Installing on device...${NC}"
        adb install -r build/app/outputs/flutter-apk/app-release.apk
    else
        echo -e "${RED}❌ Build failed${NC}"
    fi
else
    echo -e "${BLUE}Running debug build...${NC}"
    flutter run
fi

echo ""
echo "========================================="
echo "Icon Update Complete!"
echo "========================================="
echo ""
echo "The app icon should now be updated on your device."
echo "You may need to:"
echo "1. Uninstall and reinstall the app"
echo "2. Clear launcher cache (Settings → Apps → Launcher → Clear Cache)"
echo "3. Restart your device"
echo ""
echo "If the icon still doesn't update, try:"
echo "• Long press the app icon → App info → Clear cache"
echo "• Move the app icon to a different screen and back"
