#!/bin/bash
# Make all scripts executable

chmod +x scripts/increment_version.sh
chmod +x scripts/check_version.sh
chmod +x scripts/quick_release.sh
chmod +x scripts/test_deployment.sh
chmod +x scripts/rebuild_after_fix.sh

echo "✅ All scripts are now executable!"
echo ""
echo "Available version management scripts:"
echo "  📈 increment_version.sh - Increment version (major/minor/patch)"
echo "  🔍 check_version.sh     - Check current version info"
echo "  🚀 quick_release.sh     - Complete release workflow"
echo ""
echo "Example usage:"
echo "  ./scripts/increment_version.sh patch"
echo "  ./scripts/check_version.sh"
echo "  ./scripts/quick_release.sh patch beta"
