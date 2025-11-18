#!/bin/bash
################################################################################
# DevOps Tools Health Check
# Checks installation, versions, and health of essential development tools
################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

BOLD='\033[1m'

# Icons
CHECK="✓"
CROSS="✗"
WARNING="⚠"
INFO="ℹ"

# Counters
INSTALLED=0
MISSING=0
OUTDATED=0

echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║          DevOps Tools Health Check & Diagnostic              ║${NC}"
echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get version
get_version() {
    local cmd=$1
    local flag=${2:---version}
    
    if command_exists "$cmd"; then
        $cmd $flag 2>&1 | head -1 | sed 's/.*version //i' | sed 's/[(),].*$//' | awk '{print $1}'
    else
        echo "Not installed"
    fi
}

# Function to check tool
check_tool() {
    local name=$1
    local cmd=$2
    local version_flag=${3:---version}
    local brew_name=${4:-$cmd}
    
    printf "%-25s " "$name"
    
    if command_exists "$cmd"; then
        version=$(get_version "$cmd" "$version_flag")
        echo -e "${GREEN}${CHECK} Installed${NC} ${CYAN}($version)${NC}"
        ((INSTALLED++))
    else
        echo -e "${RED}${CROSS} Not installed${NC} ${YELLOW}(Install: brew install $brew_name)${NC}"
        ((MISSING++))
    fi
}

# Function to check GUI app
check_app() {
    local name=$1
    local bundle_id=$2
    local brew_name=${3:-}
    
    printf "%-25s " "$name"
    
    if mdfind "kMDItemCFBundleIdentifier == '$bundle_id'" 2>/dev/null | grep -q ".app"; then
        app_path=$(mdfind "kMDItemCFBundleIdentifier == '$bundle_id'" 2>/dev/null | head -1)
        version=$(defaults read "$app_path/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "Unknown")
        
        # Check if running
        if pgrep -f "$bundle_id" >/dev/null 2>&1; then
            echo -e "${GREEN}${CHECK} Installed & Running${NC} ${CYAN}($version)${NC}"
        else
            echo -e "${GREEN}${CHECK} Installed${NC} ${CYAN}($version)${NC} ${YELLOW}(Not running)${NC}"
        fi
        ((INSTALLED++))
    else
        if [ -n "$brew_name" ]; then
            echo -e "${RED}${CROSS} Not installed${NC} ${YELLOW}(Install: brew install --cask $brew_name)${NC}"
        else
            echo -e "${RED}${CROSS} Not installed${NC}"
        fi
        ((MISSING++))
    fi
}

echo -e "${BOLD}${MAGENTA}═══ Development Tools ═══${NC}"
check_tool "Xcode" "xcodebuild" "-version" "N/A"
check_tool "Swift" "swift" "--version" "N/A"
check_tool "Git" "git" "--version" "git"
check_tool "GitHub CLI" "gh" "--version" "gh"

echo ""
echo -e "${BOLD}${MAGENTA}═══ Package Managers ═══${NC}"
check_tool "Homebrew" "brew" "--version" "N/A"
check_tool "CocoaPods" "pod" "--version" "cocoapods"
check_tool "Fastlane" "fastlane" "--version" "fastlane"
check_tool "Carthage" "carthage" "version" "carthage"
check_tool "npm" "npm" "--version" "node"
check_tool "pip" "pip3" "--version" "python"
check_tool "gem" "gem" "--version" "ruby"

echo ""
echo -e "${BOLD}${MAGENTA}═══ Programming Languages & Runtimes ═══${NC}"
check_tool "Node.js" "node" "--version" "node"
check_tool "Python" "python3" "--version" "python"
check_tool "Ruby" "ruby" "--version" "ruby"
check_tool "Go" "go" "version" "go"
check_tool "Rust" "rustc" "--version" "rust"
check_tool "Java" "java" "-version" "openjdk"

echo ""
echo -e "${BOLD}${MAGENTA}═══ Development Applications ═══${NC}"
check_app "Visual Studio Code" "com.microsoft.VSCode" "visual-studio-code"
check_app "Xcode" "com.apple.dt.Xcode" "N/A"
check_app "iTerm2" "com.googlecode.iterm2" "iterm2"
check_app "Docker Desktop" "com.docker.docker" "docker"
check_app "Postman" "com.postmanlabs.mac" "postman"

echo ""
echo -e "${BOLD}${MAGENTA}═══ Utility Tools ═══${NC}"
check_app "Raycast" "com.raycast.macos" "raycast"
check_app "Stats" "eu.exelban.Stats" "stats"
check_app "TablePlus" "com.tinyapp.TablePlus" "tableplus"
check_app "Charles Proxy" "com.xk72.Charles" "charles"
check_app "SF Symbols" "com.apple.SFSymbols" "N/A"

echo ""
echo -e "${BOLD}${MAGENTA}═══ DevOps & CI/CD Tools ═══${NC}"
check_tool "Docker" "docker" "--version" "docker"
check_tool "kubectl" "kubectl" "version --client" "kubernetes-cli"
check_tool "Terraform" "terraform" "--version" "terraform"
check_tool "Ansible" "ansible" "--version" "ansible"
check_tool "Jenkins CLI" "jenkins-cli" "--version" "jenkins"

echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Summary:${NC}"
echo -e "  ${GREEN}${CHECK} Installed: $INSTALLED${NC}"
echo -e "  ${RED}${CROSS} Missing:   $MISSING${NC}"

if [ $MISSING -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}${WARNING} Run 'brew bundle' or install missing tools individually${NC}"
fi

echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
