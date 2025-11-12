#!/bin/bash

# Nivas Build Script
# Builds Android APK and App Bundle for release

set -e  # Exit on error

echo "🚀 Nivas Build Script"
echo "===================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Flutter found${NC}"
flutter --version
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
echo -e "${GREEN}✓ Clean complete${NC}"
echo ""

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Run code analysis
echo "🔍 Running code analysis..."
flutter analyze
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Code analysis found issues. Continue anyway? (y/n)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
echo -e "${GREEN}✓ Analysis complete${NC}"
echo ""

# Format code
echo "✨ Formatting code..."
flutter format .
echo -e "${GREEN}✓ Code formatted${NC}"
echo ""

# Build options
echo "Select build type:"
echo "1) APK (single file, larger size)"
echo "2) App Bundle (for Play Store, recommended)"
echo "3) Split APKs (multiple files, smaller size)"
echo "4) All of the above"
read -p "Enter choice (1-4): " choice

case $choice in
    1)
        echo ""
        echo "📱 Building APK..."
        flutter build apk --release
        echo -e "${GREEN}✓ APK built successfully${NC}"
        echo "📍 Location: build/app/outputs/flutter-apk/app-release.apk"
        ;;
    2)
        echo ""
        echo "📦 Building App Bundle..."
        flutter build appbundle --release
        echo -e "${GREEN}✓ App Bundle built successfully${NC}"
        echo "📍 Location: build/app/outputs/bundle/release/app-release.aab"
        ;;
    3)
        echo ""
        echo "📱 Building Split APKs..."
        flutter build apk --split-per-abi --release
        echo -e "${GREEN}✓ Split APKs built successfully${NC}"
        echo "📍 Location: build/app/outputs/flutter-apk/"
        echo "   - app-armeabi-v7a-release.apk (32-bit ARM)"
        echo "   - app-arm64-v8a-release.apk (64-bit ARM)"
        echo "   - app-x86_64-release.apk (64-bit Intel)"
        ;;
    4)
        echo ""
        echo "📱 Building APK..."
        flutter build apk --release
        echo -e "${GREEN}✓ APK built${NC}"
        echo ""
        echo "📦 Building App Bundle..."
        flutter build appbundle --release
        echo -e "${GREEN}✓ App Bundle built${NC}"
        echo ""
        echo "📱 Building Split APKs..."
        flutter build apk --split-per-abi --release
        echo -e "${GREEN}✓ Split APKs built${NC}"
        echo ""
        echo -e "${GREEN}✓ All builds completed successfully${NC}"
        echo "📍 Locations:"
        echo "   APK: build/app/outputs/flutter-apk/app-release.apk"
        echo "   Bundle: build/app/outputs/bundle/release/app-release.aab"
        echo "   Split APKs: build/app/outputs/flutter-apk/"
        ;;
    *)
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}🎉 Build complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Test the APK on a real device"
echo "2. Upload to Firebase App Distribution for beta testing"
echo "3. Upload App Bundle to Google Play Console for production"
echo ""
