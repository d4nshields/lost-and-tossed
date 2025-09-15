#!/bin/bash

# OAuth Setup Helper for Lost & Tossed

echo "========================================="
echo "Lost & Tossed - Google OAuth Setup Helper"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to get SHA-1 fingerprint
get_sha1() {
    echo -e "${YELLOW}Getting SHA-1 fingerprint for debug keystore...${NC}"
    
    if [ -f ~/.android/debug.keystore ]; then
        SHA1=$(keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA1 | cut -d' ' -f3)
        echo -e "${GREEN}SHA-1 Fingerprint: $SHA1${NC}"
        echo ""
        echo "Copy this SHA-1 fingerprint for the Android OAuth client in GCP"
        echo ""
    else
        echo -e "${RED}Debug keystore not found. Have you built the app yet?${NC}"
        echo "Run 'flutter build apk --debug' first to generate the keystore"
    fi
}

# Function to generate google-services.json template
create_google_services_template() {
    echo -e "${YELLOW}Creating google-services.json template...${NC}"
    
    cat > android/app/google-services.json.template << 'EOF'
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "YOUR_PROJECT_ID",
    "storage_bucket": "YOUR_PROJECT_ID.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:PROJECT_NUMBER:android:YOUR_APP_ID",
        "android_client_info": {
          "package_name": "com.tinkerplexlabs.lost_and_tossed"
        }
      },
      "oauth_client": [
        {
          "client_id": "YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com",
          "client_type": 1,
          "android_info": {
            "package_name": "com.tinkerplexlabs.lost_and_tossed",
            "certificate_hash": "YOUR_SHA1_WITHOUT_COLONS"
          }
        },
        {
          "client_id": "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "YOUR_API_KEY"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": [
            {
              "client_id": "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com",
              "client_type": 3
            }
          ]
        }
      }
    }
  ],
  "configuration_version": "1"
}
EOF
    
    echo -e "${GREEN}Template created at: android/app/google-services.json.template${NC}"
    echo "You'll need to fill this in with your actual values from GCP"
}

# Main menu
echo "What would you like to do?"
echo ""
echo "1) Get SHA-1 fingerprint for Android OAuth"
echo "2) Create google-services.json template"
echo "3) Check current configuration"
echo "4) Show setup checklist"
echo ""
read -p "Enter choice [1-4]: " choice

case $choice in
    1)
        get_sha1
        ;;
    2)
        create_google_services_template
        ;;
    3)
        echo -e "${YELLOW}Current Configuration Status:${NC}"
        echo ""
        
        # Check if google-services.json exists
        if [ -f android/app/google-services.json ]; then
            echo -e "${GREEN}✓ google-services.json exists${NC}"
        else
            echo -e "${RED}✗ google-services.json missing${NC}"
        fi
        
        # Check if .env.oauth has been configured
        if grep -q "YOUR_WEB_CLIENT_ID" .env.oauth 2>/dev/null; then
            echo -e "${RED}✗ OAuth credentials not configured in .env.oauth${NC}"
        else
            echo -e "${GREEN}✓ OAuth credentials configured in .env.oauth${NC}"
        fi
        
        # Check if auth_repository has client ID
        if grep -q "YOUR_WEB_CLIENT_ID" lib/features/auth/data/auth_repository.dart 2>/dev/null; then
            echo -e "${RED}✗ Web Client ID not set in auth_repository.dart${NC}"
        else
            echo -e "${GREEN}✓ Web Client ID appears to be set in code${NC}"
        fi
        ;;
    4)
        echo -e "${YELLOW}OAuth Setup Checklist:${NC}"
        echo ""
        echo "□ 1. Create GCP Project at https://console.cloud.google.com"
        echo "□ 2. Configure OAuth Consent Screen (External)"
        echo "□ 3. Create Web Application OAuth Client"
        echo "□ 4. Create Android OAuth Client (use SHA-1 from option 1)"
        echo "□ 5. Copy Web Client ID and Secret"
        echo "□ 6. Configure Supabase with Web OAuth credentials"
        echo "□ 7. Update auth_repository.dart with Web Client ID"
        echo "□ 8. Create google-services.json (option 2 for template)"
        echo "□ 9. Place google-services.json in android/app/"
        echo "□ 10. Run 'flutter pub get'"
        echo ""
        echo -e "${GREEN}Run this script with option 3 to check your configuration${NC}"
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        ;;
esac

echo ""
echo "========================================="
