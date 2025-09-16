#!/bin/bash

cd /home/daniel/work/lost-and-tossed

echo "Getting Flutter packages..."
flutter pub get

echo ""
echo "Packages retrieved successfully!"
echo ""
echo "Now you can run:"
echo "  flutter run"
echo ""
echo "Remember to:"
echo "1. Add your Web OAuth Client ID to auth_repository.dart"
echo "2. Configure Supabase with your OAuth credentials"
echo "3. (Optional) Add google-services.json to android/app/"
