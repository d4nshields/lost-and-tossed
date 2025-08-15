#!/bin/bash
# Quick release script for Lost & Tossed
# Usage: ./quick_release.sh [patch|minor|major] [internal|alpha|beta|production]

set -e

# Set defaults
INCREMENT_TYPE=${1:-patch}
RELEASE_TRACK=${2:-internal}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Lost & Tossed Quick Release Tool${NC}"
echo "══════════════════════════════════════"
echo ""

# Change to project root
cd "$(dirname "$0")/.."

# Check for uncommitted changes
if [ $(git status --porcelain | wc -l) -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Warning: You have uncommitted changes${NC}"
    echo "Files changed:"
    git status --short | sed 's/^/  /'
    echo ""
    read -p "Do you want to commit these changes first? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter commit message: " COMMIT_MSG
        git add -A
        git commit -m "$COMMIT_MSG"
        echo -e "${GREEN}✅ Changes committed${NC}"
    else
        echo -e "${RED}❌ Aborting - please commit or stash changes first${NC}"
        exit 1
    fi
fi

# Increment version
echo -e "${BLUE}📦 Incrementing version ($INCREMENT_TYPE)...${NC}"
./scripts/increment_version.sh $INCREMENT_TYPE

# Read the new version
NEW_VERSION=$(grep -E "^version:" pubspec.yaml | awk '{print $2}' | tr -d "'\"" | cut -d'+' -f1)

# Determine tag based on release track
case $RELEASE_TRACK in
    production)
        TAG="v$NEW_VERSION"
        echo -e "${RED}🎯 Production release${NC}"
        ;;
    beta)
        # Find the next beta number
        BETA_COUNT=$(git tag | grep -c "v$NEW_VERSION-beta" || echo "0")
        BETA_NUM=$((BETA_COUNT + 1))
        TAG="v$NEW_VERSION-beta.$BETA_NUM"
        echo -e "${YELLOW}🧪 Beta release #$BETA_NUM${NC}"
        ;;
    alpha)
        # Find the next alpha number
        ALPHA_COUNT=$(git tag | grep -c "v$NEW_VERSION-alpha" || echo "0")
        ALPHA_NUM=$((ALPHA_COUNT + 1))
        TAG="v$NEW_VERSION-alpha.$ALPHA_NUM"
        echo -e "${BLUE}🔬 Alpha release #$ALPHA_NUM${NC}"
        ;;
    internal|*)
        # Find the next internal number
        INTERNAL_COUNT=$(git tag | grep -c "v$NEW_VERSION-internal" || echo "0")
        INTERNAL_NUM=$((INTERNAL_COUNT + 1))
        TAG="v$NEW_VERSION-internal.$INTERNAL_NUM"
        echo -e "${GREEN}🏠 Internal release #$INTERNAL_NUM${NC}"
        ;;
esac

# Commit version changes
echo ""
echo -e "${BLUE}📝 Committing version bump...${NC}"
git add pubspec.yaml android/app/build.gradle
git commit -m "Bump version to $NEW_VERSION for $RELEASE_TRACK release"

# Create and push tag
echo -e "${BLUE}🏷️  Creating tag: $TAG${NC}"
git tag -a "$TAG" -m "$RELEASE_TRACK release: $NEW_VERSION"

# Show summary
echo ""
echo -e "${GREEN}✅ Release prepared successfully!${NC}"
echo "══════════════════════════════════════"
echo "  Version: $NEW_VERSION"
echo "  Tag: $TAG"
echo "  Track: $RELEASE_TRACK"
echo ""
echo "Next steps:"
echo "  1. Push changes: git push && git push --tags"
echo "  2. Create GitHub release: gh release create $TAG --title \"$TAG\" --generate-notes"
echo ""
echo "Or push everything now:"
echo -e "  ${GREEN}git push && git push --tags && gh release create $TAG --title \"$TAG\" --generate-notes${NC}"
echo ""

# Ask if user wants to push now
read -p "Push changes and create release now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}📤 Pushing to GitHub...${NC}"
    git push
    git push --tags
    
    # Create release notes
    NOTES="Lost & Tossed $RELEASE_TRACK release

Version: $NEW_VERSION

This release will be automatically deployed to the **$RELEASE_TRACK** track on Google Play Store.

## What's Changed
(Auto-generated notes will be added)"
    
    echo -e "${BLUE}📋 Creating GitHub release...${NC}"
    gh release create "$TAG" --title "$TAG" --notes "$NOTES" --generate-notes || {
        echo -e "${YELLOW}Note: GitHub CLI (gh) not installed or not authenticated${NC}"
        echo "Create release manually at: https://github.com/YOUR_REPO/releases/new?tag=$TAG"
    }
    
    echo ""
    echo -e "${GREEN}🎉 Release complete!${NC}"
    echo "The GitHub Actions workflow will now build and deploy to $RELEASE_TRACK."
    echo ""
    echo "Monitor progress at: https://github.com/YOUR_REPO/actions"
else
    echo -e "${YELLOW}📦 Release prepared but not pushed${NC}"
    echo "When ready, run:"
    echo "  git push && git push --tags"
fi

echo ""
echo -e "${BLUE}🎨 Lost & Tossed: \"Your release begins its deployment adventure!\"${NC}"
