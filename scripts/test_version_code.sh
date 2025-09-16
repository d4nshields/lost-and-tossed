#!/bin/bash

echo "========================================="
echo "Version Code Generator Test"
echo "========================================="
echo ""

# Test the version code generation logic
CURRENT_YEAR=$(date -u +"%Y")
BASE_YEAR=2025
YEAR_OFFSET=$((CURRENT_YEAR - BASE_YEAR))

# Format: YYMMDDHHMM (10 digits max for Android version code limit of 2100000000)
# Using seconds for more granularity
TIMESTAMP_PART=$(date -u +"%m%d%H%M%S")
VERSION_CODE=$(printf "%d%s" $YEAR_OFFSET $TIMESTAMP_PART)

# Ensure it's a valid integer and remove any leading zeros
VERSION_CODE=$((10#$VERSION_CODE))

echo "Current UTC Time: $(date -u +'%Y-%m-%d %H:%M:%S')"
echo "Base Year: $BASE_YEAR"
echo "Current Year: $CURRENT_YEAR"
echo "Year Offset: $YEAR_OFFSET"
echo "Timestamp Part: $TIMESTAMP_PART"
echo ""
echo "Generated Version Code: $VERSION_CODE"
echo ""

# Android's maximum version code
MAX_VERSION_CODE=2100000000
if [ $VERSION_CODE -gt $MAX_VERSION_CODE ]; then
  echo "❌ ERROR: Version code exceeds Android maximum ($MAX_VERSION_CODE)"
else
  echo "✅ Version code is valid"
fi

echo ""
echo "Format breakdown:"
echo "  Year offset: $YEAR_OFFSET (0 for 2025, 1 for 2026, etc.)"
echo "  Month: $(date -u +"%m")"
echo "  Day: $(date -u +"%d")"
echo "  Hour: $(date -u +"%H")"
echo "  Minute: $(date -u +"%M")"
echo "  Second: $(date -u +"%S")"
echo ""

# Test multiple consecutive generations
echo "Testing uniqueness (5 consecutive generations):"
for i in {1..5}; do
  sleep 1
  TIMESTAMP_PART=$(date -u +"%m%d%H%M%S")
  VERSION_CODE=$(printf "%d%s" $YEAR_OFFSET $TIMESTAMP_PART)
  VERSION_CODE=$((10#$VERSION_CODE))
  echo "  Generation $i: $VERSION_CODE ($(date -u +'%H:%M:%S'))"
done

echo ""
echo "========================================="
echo "GitHub Actions Usage:"
echo "========================================="
echo ""
echo "The GitHub Actions workflow will generate a unique version code"
echo "based on the exact time of the build, ensuring no duplicates."
echo ""
echo "Example version codes:"
echo "  2025-08-20 14:30:45 → 00820143045"
echo "  2026-01-15 09:15:30 → 10115091530"
echo "  2026-12-31 23:59:59 → 11231235959"
echo ""
