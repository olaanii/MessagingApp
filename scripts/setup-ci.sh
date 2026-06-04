#!/bin/bash
# CI/CD Setup Script
# This script helps set up the CI/CD pipeline for the chat application

set -e

echo "=========================================="
echo "CI/CD Pipeline Setup"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running in repository root
if [ ! -d ".github/workflows" ]; then
    echo -e "${RED}Error: Must run from repository root${NC}"
    exit 1
fi

echo "This script will help you set up the CI/CD pipeline."
echo ""

# Check prerequisites
echo "Checking prerequisites..."
echo ""

# Check Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git not found${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Git installed${NC}"
fi

# Check Dart
if ! command -v dart &> /dev/null; then
    echo -e "${YELLOW}⚠ Dart not found (required for local testing)${NC}"
else
    echo -e "${GREEN}✓ Dart installed${NC}"
fi

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}⚠ Flutter not found (required for local testing)${NC}"
else
    echo -e "${GREEN}✓ Flutter installed${NC}"
fi

# Check Serverpod CLI
if ! dart pub global list | grep -q "serverpod_cli"; then
    echo -e "${YELLOW}⚠ Serverpod CLI not installed${NC}"
    echo "  Install with: dart pub global activate serverpod_cli"
else
    echo -e "${GREEN}✓ Serverpod CLI installed${NC}"
fi

echo ""
echo "=========================================="
echo "GitHub Secrets Configuration"
echo "=========================================="
echo ""
echo "You need to configure the following secrets in GitHub:"
echo ""
echo "Go to: Settings → Secrets and variables → Actions"
echo ""
echo "Required secrets:"
echo "  Staging:"
echo "    - STAGING_DB_HOST"
echo "    - STAGING_DB_PORT"
echo "    - STAGING_DB_NAME"
echo "    - STAGING_DB_USER"
echo "    - STAGING_DB_PASSWORD"
echo "    - STAGING_SERVERPOD_HOST"
echo "    - STAGING_SERVERPOD_PORT"
echo ""
echo "  Production:"
echo "    - PROD_DB_HOST"
echo "    - PROD_DB_PORT"
echo "    - PROD_DB_NAME"
echo "    - PROD_DB_USER"
echo "    - PROD_DB_PASSWORD"
echo "    - PROD_SERVERPOD_HOST"
echo "    - PROD_SERVERPOD_PORT"
echo ""
echo "See .github/SECRETS_SETUP.md for detailed instructions."
echo ""

read -p "Have you configured all required secrets? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please configure secrets first, then run this script again."
    exit 1
fi

echo ""
echo "=========================================="
echo "Testing Local Setup"
echo "=========================================="
echo ""

# Test Serverpod code generation
echo "Testing Serverpod code generation..."
if [ -d "server" ]; then
    cd server
    if serverpod generate; then
        echo -e "${GREEN}✓ Serverpod code generation successful${NC}"
    else
        echo -e "${RED}✗ Serverpod code generation failed${NC}"
        exit 1
    fi
    cd ..
else
    echo -e "${YELLOW}⚠ Server directory not found${NC}"
fi

echo ""

# Test backend
echo "Testing backend..."
if [ -d "server/chat_server" ]; then
    cd server/chat_server
    if dart pub get && dart analyze; then
        echo -e "${GREEN}✓ Backend analysis successful${NC}"
    else
        echo -e "${RED}✗ Backend analysis failed${NC}"
        exit 1
    fi
    cd ../..
else
    echo -e "${YELLOW}⚠ Backend directory not found${NC}"
fi

echo ""

# Test Flutter app
echo "Testing Flutter app..."
if [ -d "chat" ]; then
    cd chat
    if flutter pub get && flutter analyze; then
        echo -e "${GREEN}✓ Flutter analysis successful${NC}"
    else
        echo -e "${RED}✗ Flutter analysis failed${NC}"
        exit 1
    fi
    cd ..
else
    echo -e "${YELLOW}⚠ Chat directory not found${NC}"
fi

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Commit and push your changes"
echo "  2. Create a pull request to test CI"
echo "  3. Merge to 'develop' to deploy to staging"
echo "  4. Merge to 'main' to deploy to production"
echo ""
echo "Useful commands:"
echo "  - Generate code: cd server && serverpod generate"
echo "  - Run backend tests: cd server/chat_server && dart test"
echo "  - Run Flutter tests: cd chat && flutter test"
echo ""
echo "Documentation:"
echo "  - CI/CD Overview: docs/ci-cd/README.md"
echo "  - Workflow Details: .github/workflows/README.md"
echo "  - Secrets Setup: .github/SECRETS_SETUP.md"
echo ""
echo -e "${GREEN}Happy coding!${NC}"
