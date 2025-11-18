#!/bin/bash

###############################################################################
# Git Initialization Script
# Initializes git repository and prepares for first push to GitHub
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
echo "║   Git Repository Initialization                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed${NC}"
    exit 1
fi

# Check if already a git repository
if [ -d ".git" ]; then
    echo -e "${YELLOW}This is already a git repository${NC}"
    read -p "Reinitialize? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi
    rm -rf .git
fi

# Initialize git repository
echo -e "${BLUE}Initializing git repository...${NC}"
git init
echo -e "${GREEN}✓ Git repository initialized${NC}"

# Configure git (if not already configured)
if [ -z "$(git config --global user.name)" ]; then
    read -p "Enter your name: " GIT_NAME
    git config --global user.name "$GIT_NAME"
fi

if [ -z "$(git config --global user.email)" ]; then
    read -p "Enter your email: " GIT_EMAIL
    git config --global user.email "$GIT_EMAIL"
fi

# Create .gitattributes for better cross-platform compatibility
cat > .gitattributes << 'EOF'
# Auto detect text files and perform LF normalization
* text=auto

# Shell scripts
*.sh text eol=lf

# YAML files
*.yml text eol=lf
*.yaml text eol=lf

# Markdown files
*.md text eol=lf

# Xcode files
*.pbxproj text merge=union
*.xcworkspacedata text merge=union
EOF

echo -e "${GREEN}✓ Created .gitattributes${NC}"

# Add all files
echo -e "${BLUE}Adding files to git...${NC}"
git add .
echo -e "${GREEN}✓ Files added${NC}"

# Create initial commit
echo -e "${BLUE}Creating initial commit...${NC}"
git commit -m "Initial commit: Apple Automat One-Click Test Pipeline

Complete DevOps automation solution for iOS/macOS development including:
- One-click build and test pipeline
- iOS and macOS support
- Comprehensive testing with code coverage
- CI/CD workflows (GitHub Actions)
- Notification system (Slack, email, macOS)
- Code signing management
- Full documentation and guides

Ready for production use."

echo -e "${GREEN}✓ Initial commit created${NC}"

# Set main as default branch
git branch -M main
echo -e "${GREEN}✓ Default branch set to 'main'${NC}"

echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║   Git Repository Ready!                                       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}Next steps:${NC}"
echo ""
echo "1. Create a new repository on GitHub:"
echo -e "   ${YELLOW}https://github.com/new${NC}"
echo ""
echo "2. Add the remote repository:"
echo -e "   ${YELLOW}git remote add origin https://github.com/bholsinger09/AppleAutomat_OneClickTestPipeline.git${NC}"
echo ""
echo "3. Push to GitHub:"
echo -e "   ${YELLOW}git push -u origin main${NC}"
echo ""
echo "4. (Optional) Add GitHub secrets for CI/CD:"
echo "   - APPLE_CERTIFICATE_BASE64"
echo "   - APPLE_CERTIFICATE_PASSWORD"
echo "   - PROVISIONING_PROFILE_BASE64"
echo "   - KEYCHAIN_PASSWORD"
echo "   - SLACK_WEBHOOK_URL"
echo "   - TEAM_ID"
echo ""
echo -e "${GREEN}Repository initialized and ready to push! 🚀${NC}"
