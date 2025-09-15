#!/bin/bash

echo "========================================="
echo "Supabase Google Auth Configuration Check"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Extract Web Client ID from google-services.json
echo -e "${BLUE}1. Web Client ID from google-services.json:${NC}"
if [ -f "android/app/google-services.json" ]; then
    WEB_CLIENT_ID=$(grep -A 2 '"client_type": 3' android/app/google-services.json | grep client_id | sed 's/.*"client_id": "//' | sed 's/".*//')
    
    if [ ! -z "$WEB_CLIENT_ID" ]; then
        echo -e "${GREEN}   $WEB_CLIENT_ID${NC}"
        echo ""
        echo "   First part: $(echo $WEB_CLIENT_ID | cut -d'-' -f1)"
    else
        echo -e "${YELLOW}   No web client found in google-services.json${NC}"
    fi
else
    echo -e "${YELLOW}   google-services.json not found${NC}"
fi

echo ""
echo -e "${BLUE}2. Supabase Configuration:${NC}"
echo "   URL: https://itosryiospovqdcrnjxr.supabase.co"
echo "   Project Ref: itosryiospovqdcrnjxr"

echo ""
echo -e "${BLUE}3. Required Supabase Settings:${NC}"
echo ""
echo "   Go to: https://app.supabase.com/project/itosryiospovqdcrnjxr/auth/providers"
echo ""
echo "   In the Google provider settings, you need:"
echo "   • Client ID: $WEB_CLIENT_ID"
echo "   • Client Secret: (from Google Cloud Console)"
echo ""

echo -e "${BLUE}4. To get the Client Secret:${NC}"
echo ""
echo "   1. Go to: https://console.cloud.google.com/apis/credentials"
echo "   2. Select your project"
echo "   3. Find the OAuth 2.0 Client ID that matches:"
echo "      $WEB_CLIENT_ID"
echo "   4. Click on it and copy the Client Secret"
echo ""

echo -e "${BLUE}5. Test the Integration:${NC}"
echo ""
echo "   After configuring Supabase:"
echo "   1. Run: flutter clean && flutter pub get"
echo "   2. Run: flutter run"
echo "   3. Try signing in with Google"
echo "   4. Check Supabase Dashboard → Authentication → Users"
echo "      to see if the user was created"
echo ""

echo -e "${BLUE}6. Common Issues:${NC}"
echo ""
echo "   • 'Invalid refresh token' - User needs to sign in again"
echo "   • 'User not found' - Check if user was created in Supabase"
echo "   • 'Invalid provider' - Google provider not enabled in Supabase"
echo "   • 'Invalid client' - Client ID/Secret mismatch"
