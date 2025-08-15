#!/bin/bash

# Clean and rebuild the app after fixing package structure

echo "🧹 Cleaning Flutter build..."
flutter clean

echo "📦 Getting packages..."
flutter pub get

echo "🔨 Building debug APK..."
flutter build apk --debug

echo "✅ Build complete! You can now install the APK:"
echo "   adb install build/app/outputs/flutter-apk/app-debug.apk"
echo ""
echo "Or run directly:"
echo "   flutter run"
