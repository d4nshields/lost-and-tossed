#!/bin/bash
# Script to increment version numbers in Lost & Tossed Flutter project
# Usage: ./increment_version.sh [major|minor|patch]

set -e  # Exit on error

# Set the root directory to the project root (script is in scripts/ folder)
cd "$(dirname "$0")/.."

# Default to patch increment if no argument provided
INCREMENT_TYPE=${1:-patch}

# Read current version from pubspec.yaml
PUBSPEC_PATH="pubspec.yaml"
CURRENT_VERSION=$(grep -E "^version:" "$PUBSPEC_PATH" | awk '{print $2}' | tr -d "'\"")

# Split version into components
IFS='+' read -r VERSION_NAME VERSION_CODE <<< "$CURRENT_VERSION"
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION_NAME"

# Increment based on the specified type
case $INCREMENT_TYPE in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    echo "🎯 Major version increment (breaking changes)"
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    echo "✨ Minor version increment (new features)"
    ;;
  patch)
    PATCH=$((PATCH + 1))
    echo "🔧 Patch version increment (bug fixes)"
    ;;
  *)
    echo "❌ Unknown increment type: $INCREMENT_TYPE"
    echo "Usage: $0 [major|minor|patch]"
    echo "  major - Breaking changes (1.0.0 → 2.0.0)"
    echo "  minor - New features (1.0.0 → 1.1.0)"
    echo "  patch - Bug fixes (1.0.0 → 1.0.1)"
    exit 1
    ;;
esac

# Create new version strings
NEW_VERSION_NAME="$MAJOR.$MINOR.$PATCH"

# Generate timestamp-based version code (YYMMDDHHMM format)
# YY = years since 2025 (2025=00, 2026=01, etc.)
# This ensures version codes are always increasing across years
CURRENT_YEAR=$(date +"%Y")
YEAR_OFFSET=$((CURRENT_YEAR - 2025))
TIMESTAMP_VERSION_CODE=$(printf "%02d%s" $YEAR_OFFSET $(date +"%m%d%H%M"))
# Remove leading zeros to ensure it's treated as a number
NEW_VERSION_CODE=$((10#$TIMESTAMP_VERSION_CODE))

NEW_VERSION="$NEW_VERSION_NAME+$NEW_VERSION_CODE"

echo ""
echo "📦 Version Update for Lost & Tossed"
echo "═══════════════════════════════════"
echo "  Old version: $CURRENT_VERSION"
echo "  New version: $NEW_VERSION"
echo ""
echo "🔢 Generated timestamp-based version code: $NEW_VERSION_CODE"
echo "   Year offset: $YEAR_OFFSET ($(date +'%Y-%m-%d %H:%M UTC'))"
echo ""

# Update pubspec.yaml
sed -i "s/^version:.*/version: $NEW_VERSION/" "$PUBSPEC_PATH"
echo "✅ Updated pubspec.yaml"

# Update build.gradle (Lost & Tossed uses .gradle not .gradle.kts)
GRADLE_PATH="android/app/build.gradle"

# Update versionCode and versionName in build.gradle
# Handle both direct assignment and flutter.versionCode patterns
sed -i "s/versionCode\s*=\s*flutter\.versionCode\s*?:\s*[0-9]\+/versionCode = $NEW_VERSION_CODE/" "$GRADLE_PATH"
sed -i "s/versionCode\s*=\s*[0-9]\+/versionCode = $NEW_VERSION_CODE/" "$GRADLE_PATH"
sed -i "s/versionName\s*=\s*flutter\.versionName\s*?:\s*\"[^\"]*\"/versionName = \"$NEW_VERSION_NAME\"/" "$GRADLE_PATH"
sed -i "s/versionName\s*=\s*\"[^\"]*\"/versionName = \"$NEW_VERSION_NAME\"/" "$GRADLE_PATH"

echo "✅ Updated build.gradle"

# Show verification
echo ""
echo "📋 Verification:"
echo "───────────────"
echo "pubspec.yaml:"
grep "^version:" "$PUBSPEC_PATH" | sed 's/^/  /'
echo ""
echo "build.gradle:"
grep -E "versionCode|versionName" "$GRADLE_PATH" | head -2 | sed 's/^/  /'

# Generate git tag suggestion based on increment type
if [ "$INCREMENT_TYPE" == "patch" ] && [ "$PATCH" -gt 0 ]; then
    TAG_SUGGESTION="v$NEW_VERSION_NAME"
elif [ "$INCREMENT_TYPE" == "minor" ]; then
    TAG_SUGGESTION="v$NEW_VERSION_NAME-beta.1"
elif [ "$INCREMENT_TYPE" == "major" ]; then
    TAG_SUGGESTION="v$NEW_VERSION_NAME-alpha.1"
else
    TAG_SUGGESTION="v$NEW_VERSION_NAME"
fi

echo ""
echo "🚀 Version increment complete!"
echo ""
echo "📝 Next steps:"
echo "  1. Run: flutter pub get"
echo "  2. Test your changes"
echo "  3. Commit: git add -A && git commit -m \"Bump version to $NEW_VERSION_NAME\""
echo "  4. Tag: git tag $TAG_SUGGESTION"
echo "  5. Push: git push && git push --tags"
echo ""
echo "💡 Deployment tracks based on tag format:"
echo "  • v$NEW_VERSION_NAME → Production"
echo "  • v$NEW_VERSION_NAME-beta.1 → Beta testing"
echo "  • v$NEW_VERSION_NAME-alpha.1 → Alpha testing"
echo "  • v$NEW_VERSION_NAME-internal.1 → Internal testing"
echo ""
echo "🎨 Lost & Tossed: \"A version number begins its solo adventure!\""
