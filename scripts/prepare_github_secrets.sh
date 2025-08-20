#!/bin/bash

# Script to prepare GitHub secrets for deployment
# This helps encode the required files for GitHub Actions

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "GitHub Secrets Preparation Helper"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to encode file to base64
encode_file() {
    local file_path=$1
    local secret_name=$2
    
    if [ ! -f "$file_path" ]; then
        echo -e "${RED}❌ File not found: $file_path${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Found: $file_path${NC}"
    echo "Encoding to base64..."
    
    # Encode based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        base64 -i "$file_path" | tr -d '\n'
    else
        # Linux
        base64 -w 0 "$file_path"
    fi
    
    echo ""
    echo -e "${YELLOW}Add the above output as GitHub secret: $secret_name${NC}"
    echo ""
    return 0
}

# Check for google-services.json
echo "1. Checking google-services.json..."
GOOGLE_SERVICES_PATH="$PROJECT_ROOT/android/app/google-services.json"

if [ -f "$GOOGLE_SERVICES_PATH" ]; then
    echo -e "${GREEN}✅ google-services.json found${NC}"
    echo ""
    read -p "Do you want to encode google-services.json? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Base64 encoded google-services.json:"
        echo "======================================"
        encode_file "$GOOGLE_SERVICES_PATH" "GOOGLE_SERVICES_JSON_BASE64"
        echo "======================================"
    fi
else
    echo -e "${RED}❌ google-services.json not found at: $GOOGLE_SERVICES_PATH${NC}"
    echo "Please ensure you have downloaded it from Firebase Console"
    echo ""
fi

# Check for keystore
echo "2. Checking for keystore file..."
echo ""
echo "Common keystore locations:"
echo "  - $PROJECT_ROOT/android/app/*.jks"
echo "  - $PROJECT_ROOT/android/app/*.p12"
echo "  - $PROJECT_ROOT/android/app/*.keystore"
echo ""

read -p "Enter the path to your keystore file (or press Enter to skip): " KEYSTORE_PATH

if [ ! -z "$KEYSTORE_PATH" ] && [ -f "$KEYSTORE_PATH" ]; then
    echo ""
    echo "Base64 encoded keystore:"
    echo "======================================"
    encode_file "$KEYSTORE_PATH" "RELEASE_KEYSTORE_BASE64"
    echo "======================================"
else
    if [ ! -z "$KEYSTORE_PATH" ]; then
        echo -e "${RED}❌ Keystore file not found at: $KEYSTORE_PATH${NC}"
    else
        echo "Skipping keystore encoding"
    fi
fi

echo ""
echo "========================================="
echo "Next Steps:"
echo "========================================="
echo ""
echo "1. Go to your GitHub repository"
echo "2. Navigate to: Settings → Secrets and variables → Actions"
echo "3. Add the following secrets:"
echo ""
echo "   Required secrets:"
echo "   - GOOGLE_SERVICES_JSON_BASE64 (from above)"
echo "   - RELEASE_KEYSTORE_BASE64 (from above)"
echo "   - KEYSTORE_PASSWORD (your keystore password)"
echo "   - KEY_PASSWORD (your key password)"
echo "   - KEY_ALIAS (your key alias, e.g., 'upload')"
echo "   - GOOGLE_PLAY_SERVICE_ACCOUNT_JSON (from Play Console)"
echo ""
echo "4. The workflow will automatically decode these during deployment"
echo ""
echo "For detailed instructions, see: docs/DEPLOYMENT_SETUP.md"
echo ""
