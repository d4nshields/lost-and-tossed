#!/bin/bash

# Test script for Lost & Tossed deployment workflow
# This simulates the version extraction and track determination logic

set -e

echo "🧪 Lost & Tossed Deployment Test Script"
echo "======================================="
echo ""

# Function to determine track from tag
determine_track() {
    local TAG_NAME=$1
    local TRACK="internal"
    
    echo "Analyzing tag: $TAG_NAME"
    
    if [[ $TAG_NAME =~ ^v[0-9]+\.[0-9]+\.[0-9]+-alpha(\.[0-9]+)?$ ]]; then
        TRACK="alpha"
        echo "✅ Alpha release detected"
    elif [[ $TAG_NAME =~ ^v[0-9]+\.[0-9]+\.[0-9]+-beta(\.[0-9]+)?$ ]]; then
        TRACK="beta"
        echo "✅ Beta release detected (closed testing)"
    elif [[ $TAG_NAME =~ ^v[0-9]+\.[0-9]+\.[0-9]+-rc(\.[0-9]+)?$ ]]; then
        TRACK="beta"
        echo "✅ Release candidate detected (deploying to beta)"
    elif [[ $TAG_NAME =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        TRACK="production"
        echo "✅ Production release detected"
    else
        TRACK="internal"
        echo "ℹ️ Unknown tag pattern, defaulting to internal"
    fi
    
    echo "🚀 Would deploy to track: $TRACK"
    echo ""
}

# Function to extract version
extract_version() {
    local TAG_NAME=$1
    # Extract base version (remove pre-release suffixes)
    local VERSION_NAME=${TAG_NAME#v}
    VERSION_NAME=${VERSION_NAME%%-*}  # Remove everything after first dash
    echo "📦 Version: $VERSION_NAME"
    
    # Generate timestamp-based version code
    local CURRENT_YEAR=$(date -u +"%Y")
    local YEAR_OFFSET=$((CURRENT_YEAR - 2025))
    local TIMESTAMP_VERSION_CODE=$(printf "%02d%s" $YEAR_OFFSET $(date -u +"%m%d%H%M"))
    local VERSION_CODE=$((10#$TIMESTAMP_VERSION_CODE))
    
    echo "🔢 Version code: $VERSION_CODE (Year offset: $YEAR_OFFSET, UTC: $(date -u +'%Y-%m-%d %H:%M'))"
    echo ""
}

# Test various tag formats
echo "Testing tag format recognition:"
echo "-------------------------------"

TEST_TAGS=(
    "v1.0.0"
    "v1.0.0-alpha.1"
    "v1.0.0-beta.1"
    "v1.0.0-beta.2"
    "v1.0.0-rc.1"
    "v1.0.0-internal.1"
    "v2.1.3-alpha"
    "v2.1.3-beta"
    "v0.1.0-test"
    "random-tag"
)

for tag in "${TEST_TAGS[@]}"; do
    determine_track "$tag"
    extract_version "$tag"
    echo "---"
done

echo ""
echo "🎯 Test complete!"
echo ""
echo "To test the actual workflow locally, you can use:"
echo "  act -j test                    # Run tests only"
echo "  act -j build-and-deploy -s KEYSTORE_BASE64=\"...\" # Test build (requires secrets)"
echo ""
echo "Or trigger manually on GitHub:"
echo "  1. Go to Actions → 'Build and Deploy to Play Store'"
echo "  2. Click 'Run workflow'"
echo "  3. Select branch and track"
