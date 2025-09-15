#!/bin/bash

echo "========================================="
echo "🔧 Fix Google Sign-In OAuth Mismatch"
echo "========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Extract client IDs from google-services.json
if [ -f android/app/google-services.json ]; then
    echo -e "${GREEN}✓ google-services.json found${NC}"
    echo ""
    
    # Extract Web Client ID using grep and sed
    WEB_CLIENT_ID=$(grep -A1 '"client_type": 3' android/app/google-services.json | grep client_id | sed 's/.*"client_id": "\(.*\)".*/\1/')
    
    # Extract Android Client ID
    ANDROID_CLIENT_ID=$(grep -A3 '"client_type": 1' android/app/google-services.json | grep client_id | head -1 | sed 's/.*"client_id": "\(.*\)".*/\1/')
    
    echo -e "${BLUE}Your OAuth Client IDs:${NC}"
    echo ""
    echo "Web Client ID (Type 3):"
    echo -e "${GREEN}$WEB_CLIENT_ID${NC}"
    echo ""
    echo "Android Client ID (Type 1):"
    echo -e "${YELLOW}$ANDROID_CLIENT_ID${NC}"
    echo ""
else
    echo -e "${RED}✗ google-services.json not found${NC}"
    exit 1
fi

echo "========================================="
echo -e "${YELLOW}TO FIX THE AUTH ERROR:${NC}"
echo "========================================="
echo ""

echo -e "${BLUE}Step 1: Update Supabase${NC}"
echo "1. Go to: https://supabase.com/dashboard/project/itosryiospovqdcrnjxr/auth/providers"
echo "2. Click on 'Google' provider"
echo "3. In 'Authorized Client IDs', add or replace with:"
echo -e "   ${GREEN}$WEB_CLIENT_ID${NC}"
echo "4. Click 'Save'"
echo ""

echo -e "${BLUE}Step 2: (Optional) Update Flutter Code${NC}"
echo "Update lib/features/auth/data/auth_repository.dart:"
echo ""
echo "Replace:"
echo "  clientId: kIsWeb"
echo "    ? 'YOUR_LOST_AND_TOSSED_WEB_CLIENT_ID.apps.googleusercontent.com'"
echo "    : null,"
echo ""
echo "With:"
echo "  clientId: kIsWeb"
echo "    ? '$WEB_CLIENT_ID'"
echo "    : null,"
echo ""

echo -e "${BLUE}Step 3: Verify the Web Client Secret${NC}"
echo "If Supabase also asks for a 'Secret':"
echo "1. Go to: https://console.cloud.google.com/apis/credentials?project=tinkerplexlabs-74d71"
echo "2. Find the Web OAuth client (not Android)"
echo "3. Copy the Client Secret"
echo "4. Paste it in Supabase"
echo ""

echo "========================================="
echo -e "${GREEN}Quick Copy:${NC}"
echo "========================================="
echo ""
echo "Web Client ID to copy:"
echo "$WEB_CLIENT_ID"
echo ""

# Offer to update the Flutter code automatically
echo -e "${YELLOW}Do you want to automatically update auth_repository.dart? (y/n)${NC}"
read -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Update the auth_repository.dart file
    sed -i "s/'YOUR_LOST_AND_TOSSED_WEB_CLIENT_ID.apps.googleusercontent.com'/'$WEB_CLIENT_ID'/g" lib/features/auth/data/auth_repository.dart
    echo -e "${GREEN}✓ Updated auth_repository.dart${NC}"
    echo ""
    echo "Now just update Supabase with the same Client ID!"
fi
