#!/bin/bash

echo "Running Flutter Analysis..."
echo ""

flutter analyze --no-fatal-infos

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ All analysis checks passed!"
else
    echo ""
    echo "⚠️  Some analysis warnings remain (review above)"
fi
