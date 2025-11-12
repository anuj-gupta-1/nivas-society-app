#!/bin/bash

# Nivas Deploy Script
# Deploys app to Firebase App Distribution for beta testing

set -e  # Exit on error

echo "🚀 Nivas Deploy Script"
echo "======================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI is not installed${NC}"
    echo "Install it with: npm install -g firebase-tools"
    exit 1
fi

echo -e "${GREEN}✓ Firebase CLI found${NC}"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Flutter found${NC}"
echo ""

# Check if user is logged in to Firebase
echo "🔐 Checking Firebase authentication..."
firebase projects:list > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Not logged in to Firebase${NC}"
    echo "Logging in..."
    firebase login
fi
echo -e "${GREEN}✓ Firebase authenticated${NC}"
echo ""

# Get Firebase App ID
echo "📱 Firebase App Configuration"
echo "Enter your Firebase App ID (found in Firebase Console):"
echo "Example: 1:1234567890:android:abcdef1234567890"
read -p "Firebase App ID: " FIREBASE_APP_ID

if [ -z "$FIREBASE_APP_ID" ]; then
    echo -e "${RED}❌ Firebase App ID is required${NC}"
    exit 1
fi

# Get release notes
echo ""
echo "📝 Release Notes"
echo "Enter release notes for this build:"
read -p "Release notes: " RELEASE_NOTES

if [ -z "$RELEASE_NOTES" ]; then
    RELEASE_NOTES="Beta build - $(date +%Y-%m-%d)"
fi

# Get tester groups
echo ""
echo "👥 Tester Groups"
echo "Enter tester group names (comma-separated):"
echo "Example: beta-testers,internal-team"
read -p "Tester groups: " TESTER_GROUPS

if [ -z "$TESTER_GROUPS" ]; then
    TESTER_GROUPS="beta-testers"
fi

# Build APK
echo ""
echo "📱 Building release APK..."
flutter build apk --release
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ APK built successfully${NC}"
echo ""

# Deploy to Firebase App Distribution
echo "🚀 Deploying to Firebase App Distribution..."
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app "$FIREBASE_APP_ID" \
  --groups "$TESTER_GROUPS" \
  --release-notes "$RELEASE_NOTES"

if [ $? -eq 0 ]; then
    echo ""
    echo "================================"
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo "================================"
    echo ""
    echo "Your app has been deployed to Firebase App Distribution"
    echo "Testers in groups: $TESTER_GROUPS"
    echo "They will receive an email with download link"
    echo ""
    echo "View distribution: https://console.firebase.google.com/project/_/appdistribution"
    echo ""
else
    echo -e "${RED}❌ Deployment failed${NC}"
    echo "Check your Firebase configuration and try again"
    exit 1
fi
