#!/bin/bash
# Script to check current version information for Lost & Tossed

set -e

# Set the root directory to the project root
cd "$(dirname "$0")/.."

echo "🔍 Lost & Tossed Version Information"
echo "════════════════════════════════════"
echo ""

# Read version from pubspec.yaml
PUBSPEC_VERSION=$(grep -E "^version:" pubspec.yaml | awk '{print $2}' | tr -d "'\"")
echo "📦 pubspec.yaml version: $PUBSPEC_VERSION"

# Split version to show components
IFS='+' read -r VERSION_NAME VERSION_CODE <<< "$PUBSPEC_VERSION"
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION_NAME"

echo "   Major: $MAJOR"
echo "   Minor: $MINOR"
echo "   Patch: $PATCH"
echo "   Build: $VERSION_CODE"
echo ""

# Read from build.gradle
echo "🤖 Android build.gradle:"
grep -E "versionCode|versionName" android/app/build.gradle | head -2 | sed 's/^/   /'
echo ""

# Check for git tags
echo "🏷️  Recent Git tags:"
git tag --sort=-version:refname | head -5 | sed 's/^/   /' || echo "   No tags found"
echo ""

# Check current branch and status
echo "🌿 Git status:"
echo "   Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
echo "   Status: $(git status --porcelain | wc -l) uncommitted changes"
echo ""

# Last commit
echo "📝 Last commit:"
git log -1 --oneline | sed 's/^/   /'
echo ""

# Calculate what the next version code would be
CURRENT_YEAR=$(date +"%Y")
YEAR_OFFSET=$((CURRENT_YEAR - 2025))
NEXT_VERSION_CODE=$(printf "%02d%s" $YEAR_OFFSET $(date +"%m%d%H%M"))
NEXT_VERSION_CODE=$((10#$NEXT_VERSION_CODE))

echo "⏰ If you increment now:"
echo "   Next version code would be: $NEXT_VERSION_CODE"
echo "   Timestamp: $(date +'%Y-%m-%d %H:%M:%S %Z')"
echo ""

# Check if we're release-ready
if [ $(git status --porcelain | wc -l) -eq 0 ]; then
    echo "✅ Working directory is clean - ready for release!"
else
    echo "⚠️  You have uncommitted changes - commit before releasing"
fi
