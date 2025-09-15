#!/bin/bash

# OAuth Configuration Checker for Lost & Tossed

echo "================================================"
echo "Lost & Tossed OAuth Configuration Checker"
echo "================================================"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Current Setup:${NC}"
echo "• GCP Project: tinkerplexlabs (shared with Puzzle Nook)"
echo "• Package Name: com.tinkerplexlabs.lost_and_tossed"
echo "• Supabase URL: https://itosryiospovqdcrnjxr.supabase.co"
echo ""

echo -e "${YELLOW}Step 1: Your SHA-1 Fingerprint${NC}"
if [ -f ~/.android/debug.keystore ]; then
    SHA1=$(keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA1 | cut -d' ' -f3)
    echo -e "SHA-1: ${GREEN}$SHA1${NC}"
    echo ""
    echo "Verify this matches your Android OAuth client in GCP!"
else
    echo -e "${RED}Debug keystore not found${NC}"
fi
echo ""

echo -e "${YELLOW}Step 2: Required OAuth Clients in GCP${NC}"
echo ""
echo "You need these in your tinkerplexlabs project:"
echo ""
echo "1. ${GREEN}Web Application OAuth Client${NC} (for Lost & Tossed)"
echo "   Name: 'Lost and Tossed Web Client'"
echo "   Authorized JavaScript origins:"
echo "     • https://itosryiospovqdcrnjxr.supabase.co"
echo "   Authorized redirect URIs:"
echo "     • https://itosryiospovqdcrnjxr.supabase.co/auth/v1/callback"
echo ""
echo "2. ${GREEN}Android OAuth Client${NC} (auto-created is fine)"
echo "   Package: com.tinkerplexlabs.lost_and_tossed"
echo "   SHA-1: $SHA1"
echo ""

echo -e "${YELLOW}Step 3: Supabase Configuration${NC}"
echo "In Supabase Dashboard → Authentication → Providers → Google:"
echo "• Client ID: [Web Client ID from Lost & Tossed Web Client]"
echo "• Secret: [Web Client Secret from Lost & Tossed Web Client]"
echo ""

echo -e "${YELLOW}Step 4: Code Configuration${NC}"
echo "Update auth_repository.dart with your Web Client ID:"
echo "clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com'"
echo ""

echo -e "${BLUE}Navigation Help:${NC}"
echo ""
echo "GCP Credentials Page:"
echo "https://console.cloud.google.com/apis/credentials?project=tinkerplexlabs"
echo ""
echo "Supabase Auth Providers:"
echo "https://supabase.com/dashboard/project/itosryiospovqdcrnjxr/auth/providers"
echo ""

echo "================================================"
echo ""
echo -e "${GREEN}Key Point:${NC} You can use the same GCP project (tinkerplexlabs)"
echo "for multiple apps. Just create separate Web OAuth clients for"
echo "each app's Supabase project."
echo ""
echo "• Puzzle Nook → Uses its own Web OAuth client"
echo "• Lost & Tossed → Needs its own Web OAuth client"
echo "• Both can share the same GCP project"
echo ""
