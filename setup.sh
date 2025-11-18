#!/bin/bash

###############################################################################
# Setup Script for Apple Automat One-Click Test Pipeline
# Run this script after cloning the repository
###############################################################################

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║   Apple Automat One-Click Test Pipeline - Setup              ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

# Check macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error: This script requires macOS${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Running on macOS${NC}"

# Check Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: Xcode command line tools not found${NC}"
    echo "Install with: xcode-select --install"
    exit 1
fi
XCODE_VERSION=$(xcodebuild -version | head -n1)
echo -e "${GREEN}✓ ${XCODE_VERSION}${NC}"

# Check Ruby (for xcpretty)
if ! command -v gem &> /dev/null; then
    echo -e "${YELLOW}⚠ Ruby/gem not found - xcpretty won't be available${NC}"
else
    echo -e "${GREEN}✓ Ruby/gem available${NC}"
fi

echo ""

# Make scripts executable
echo -e "${BLUE}Making scripts executable...${NC}"
chmod +x one_click_pipeline.sh
chmod +x scripts/*.sh
echo -e "${GREEN}✓ Scripts are now executable${NC}"

echo ""

# Create necessary directories
echo -e "${BLUE}Creating directories...${NC}"
mkdir -p logs
mkdir -p TestResults
mkdir -p DerivedData
mkdir -p Build
echo -e "${GREEN}✓ Directories created${NC}"

echo ""

# Copy configuration templates
echo -e "${BLUE}Setting up configuration files...${NC}"

if [ ! -f ".env" ]; then
    cp .env.example .env
    echo -e "${GREEN}✓ Created .env file${NC}"
    echo -e "${YELLOW}  → Please edit .env with your project settings${NC}"
else
    echo -e "${YELLOW}⚠ .env already exists, skipping${NC}"
fi

if [ ! -f "config/pipeline_config.yaml" ]; then
    cp config/pipeline_config.example.yaml config/pipeline_config.yaml
    echo -e "${GREEN}✓ Created pipeline_config.yaml${NC}"
    echo -e "${YELLOW}  → Please edit config/pipeline_config.yaml with your settings${NC}"
else
    echo -e "${YELLOW}⚠ pipeline_config.yaml already exists, skipping${NC}"
fi

echo ""

# Optional: Install xcpretty
echo -e "${BLUE}Optional: Install xcpretty for better output formatting?${NC}"
read -p "Install xcpretty? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing xcpretty..."
    if command -v gem &> /dev/null; then
        sudo gem install xcpretty || gem install xcpretty
        echo -e "${GREEN}✓ xcpretty installed${NC}"
    else
        echo -e "${RED}Error: gem not found${NC}"
    fi
else
    echo "Skipping xcpretty installation"
fi

echo ""

# Initialize git repository if not already initialized
if [ ! -d ".git" ]; then
    echo -e "${BLUE}Initialize git repository?${NC}"
    read -p "Initialize git? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git init
        git add .
        git commit -m "Initial commit: Apple Automat Pipeline setup"
        echo -e "${GREEN}✓ Git repository initialized${NC}"
    fi
fi

echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║   Setup Complete!                                             ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}Next steps:${NC}"
echo "1. Edit .env with your project settings"
echo "2. Edit config/pipeline_config.yaml with your configuration"
echo "3. Run your first build:"
echo -e "   ${YELLOW}./one_click_pipeline.sh --platform ios --scheme \"YourApp\"${NC}"
echo ""
echo -e "${BLUE}Documentation:${NC}"
echo "  - README.md - Project overview and quick start"
echo "  - docs/configuration.md - Configuration guide"
echo "  - docs/troubleshooting.md - Common issues and solutions"
echo "  - docs/advanced_usage.md - Advanced features"
echo ""
echo -e "${BLUE}Need help?${NC}"
echo "  - GitHub: https://github.com/bholsinger09/AppleAutomat_OneClickTestPipeline"
echo "  - Issues: https://github.com/bholsinger09/AppleAutomat_OneClickTestPipeline/issues"
echo ""
echo -e "${GREEN}Happy building! 🚀${NC}"
