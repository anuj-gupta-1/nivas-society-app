#!/bin/bash

# Nivas Test Script
# Runs tests and code quality checks

set -e  # Exit on error

echo "🧪 Nivas Test Script"
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
echo ""

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Run code analysis
echo "🔍 Running code analysis..."
flutter analyze
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ No analysis issues found${NC}"
else
    echo -e "${RED}❌ Analysis found issues${NC}"
    exit 1
fi
echo ""

# Check code formatting
echo "✨ Checking code formatting..."
flutter format --set-exit-if-changed .
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Code is properly formatted${NC}"
else
    echo -e "${YELLOW}⚠️  Code formatting issues found. Run 'flutter format .' to fix${NC}"
fi
echo ""

# Run tests (if any exist)
echo "🧪 Running tests..."
if [ -d "test" ] && [ "$(ls -A test)" ]; then
    flutter test
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ All tests passed${NC}"
    else
        echo -e "${RED}❌ Some tests failed${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  No tests found in test/ directory${NC}"
    echo -e "${YELLOW}   Note: Comprehensive testing is pending (see docs/FEATURES_PENDING.md)${NC}"
fi
echo ""

# Check for common issues
echo "🔎 Checking for common issues..."

# Check for TODOs
echo "  Checking for TODOs..."
TODO_COUNT=$(grep -r "TODO" lib/ --include="*.dart" | wc -l)
if [ $TODO_COUNT -gt 0 ]; then
    echo -e "${YELLOW}  ⚠️  Found $TODO_COUNT TODO comments${NC}"
    echo "     Run: grep -r 'TODO' lib/ --include='*.dart' to see them"
else
    echo -e "${GREEN}  ✓ No TODOs found${NC}"
fi

# Check for print statements (should use debugPrint)
echo "  Checking for print statements..."
PRINT_COUNT=$(grep -r "print(" lib/ --include="*.dart" | grep -v "debugPrint" | wc -l)
if [ $PRINT_COUNT -gt 0 ]; then
    echo -e "${YELLOW}  ⚠️  Found $PRINT_COUNT print() statements (consider using debugPrint)${NC}"
else
    echo -e "${GREEN}  ✓ No print statements found${NC}"
fi

# Check for hardcoded strings (should use constants)
echo "  Checking for potential hardcoded strings..."
HARDCODED_COUNT=$(grep -r "Text('" lib/screens/ --include="*.dart" | wc -l)
if [ $HARDCODED_COUNT -gt 50 ]; then
    echo -e "${YELLOW}  ⚠️  Found many hardcoded strings (consider using constants or i18n)${NC}"
else
    echo -e "${GREEN}  ✓ Hardcoded strings look reasonable${NC}"
fi

echo ""

# Summary
echo "================================"
echo -e "${GREEN}✅ Test suite complete!${NC}"
echo "================================"
echo ""
echo "Summary:"
echo "  ✓ Code analysis passed"
echo "  ✓ Code formatting checked"
if [ -d "test" ] && [ "$(ls -A test)" ]; then
    echo "  ✓ Tests passed"
else
    echo "  ⚠️  No tests found (pending)"
fi
echo "  ✓ Common issues checked"
echo ""
echo "Next steps:"
echo "1. Fix any warnings mentioned above"
echo "2. Add comprehensive tests (see docs/FEATURES_PENDING.md)"
echo "3. Run manual testing on real device"
echo ""
