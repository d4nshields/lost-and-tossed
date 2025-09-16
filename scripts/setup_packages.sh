#!/bin/bash

# Get Flutter packages for Lost & Tossed

echo "Getting Flutter packages..."
flutter pub get

echo "Running build runner for code generation..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "Package setup complete!"
