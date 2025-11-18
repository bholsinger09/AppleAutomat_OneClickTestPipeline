#!/bin/bash
################################################################################
# Auto-Update All Development Tools
# Updates Homebrew, CocoaPods, npm, gems, and all installed packages
################################################################################

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

UPDATE_COUNT=0

echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║           Auto-Update All Development Tools                   ║${NC}"
echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to run update with error handling
update_tool() {
    local name=$1
    shift
    local cmd="$@"
    
    echo -e "${BOLD}${MAGENTA}═══ Updating $name ═══${NC}"
    
    if eval "$cmd"; then
        echo -e "${GREEN}✓ $name updated successfully${NC}"
        ((UPDATE_COUNT++))
    else
        echo -e "${RED}✗ Failed to update $name${NC}"
    fi
    echo ""
}

# Homebrew
if command -v brew >/dev/null 2>&1; then
    update_tool "Homebrew" "brew update && brew upgrade && brew upgrade --cask && brew cleanup"
else
    echo -e "${YELLOW}⚠ Homebrew not installed, skipping${NC}"
    echo ""
fi

# CocoaPods
if command -v pod >/dev/null 2>&1; then
    update_tool "CocoaPods" "sudo gem install cocoapods"
else
    echo -e "${YELLOW}⚠ CocoaPods not installed, skipping${NC}"
    echo ""
fi

# npm
if command -v npm >/dev/null 2>&1; then
    update_tool "npm" "npm install -g npm && npm update -g"
else
    echo -e "${YELLOW}⚠ npm not installed, skipping${NC}"
    echo ""
fi

# Ruby Gems
if command -v gem >/dev/null 2>&1; then
    update_tool "Ruby Gems" "sudo gem update --system && sudo gem update"
else
    echo -e "${YELLOW}⚠ gem not installed, skipping${NC}"
    echo ""
fi

# pip
if command -v pip3 >/dev/null 2>&1; then
    update_tool "Python pip" "pip3 install --upgrade pip && pip3 list --outdated --format=freeze | cut -d = -f 1 | xargs -n1 pip3 install -U"
else
    echo -e "${YELLOW}⚠ pip not installed, skipping${NC}"
    echo ""
fi

# Fastlane
if command -v fastlane >/dev/null 2>&1; then
    update_tool "Fastlane" "brew upgrade fastlane"
else
    echo -e "${YELLOW}⚠ Fastlane not installed, skipping${NC}"
    echo ""
fi

# GitHub CLI
if command -v gh >/dev/null 2>&1; then
    update_tool "GitHub CLI" "brew upgrade gh"
else
    echo -e "${YELLOW}⚠ GitHub CLI not installed, skipping${NC}"
    echo ""
fi

# Docker (check for updates)
if command -v docker >/dev/null 2>&1; then
    echo -e "${BOLD}${MAGENTA}═══ Docker ═══${NC}"
    echo -e "${CYAN}Current Docker version:${NC}"
    docker --version
    echo -e "${YELLOW}Note: Docker Desktop must be updated via the app itself${NC}"
    echo ""
fi

# Xcode Command Line Tools
echo -e "${BOLD}${MAGENTA}═══ Xcode Command Line Tools ═══${NC}"
if softwareupdate -l 2>&1 | grep -q "Command Line Tools"; then
    echo -e "${YELLOW}Updates available for Xcode Command Line Tools${NC}"
    echo -e "${CYAN}Run: softwareupdate -i --all${NC}"
else
    echo -e "${GREEN}✓ Xcode Command Line Tools are up to date${NC}"
fi
echo ""

# Summary
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}Update Process Complete!${NC}"
echo -e "${BOLD}Tools updated: $UPDATE_COUNT${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  • Restart Terminal/iTerm for changes to take effect"
echo -e "  • Run 'check-devtools.sh' to verify installations"
echo -e "  • Update Xcode from App Store if needed"
