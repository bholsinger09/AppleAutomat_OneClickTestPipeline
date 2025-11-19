#!/bin/bash
################################################################################
# DevOps Tools Health Check
# Checks installation, versions, and health of essential development tools
################################################################################

set -uo pipefail

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

# Arrays to track missing tools
declare -a MISSING_TOOLS=()
declare -a MISSING_CASKS=()

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
        if [ "$brew_name" != "N/A" ]; then
            MISSING_TOOLS+=("$brew_name")
        fi
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
            if [ "$brew_name" != "N/A" ]; then
                MISSING_CASKS+=("$brew_name")
            fi
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

# Offer to install missing tools
if [ $MISSING -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}${WARNING} Found $MISSING missing tools${NC}"
    
    # Show what will be installed
    if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
        echo -e "${BOLD}Command-line tools to install:${NC}"
        for tool in "${MISSING_TOOLS[@]}"; do
            echo -e "  ${CYAN}• $tool${NC}"
        done
    fi
    
    if [ ${#MISSING_CASKS[@]} -gt 0 ]; then
        echo -e "${BOLD}GUI applications to install:${NC}"
        for cask in "${MISSING_CASKS[@]}"; do
            echo -e "  ${CYAN}• $cask${NC}"
        done
    fi
    
    echo ""
    read -p "Would you like to install missing tools now? (y/n) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${BOLD}${GREEN}Starting installation...${NC}"
        
        # Install command-line tools
        if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
            echo ""
            echo -e "${BOLD}${MAGENTA}Installing command-line tools...${NC}"
            for tool in "${MISSING_TOOLS[@]}"; do
                echo -e "${CYAN}Installing $tool...${NC}"
                if brew install "$tool"; then
                    echo -e "${GREEN}${CHECK} $tool installed successfully${NC}"
                else
                    echo -e "${RED}${CROSS} Failed to install $tool${NC}"
                fi
            done
        fi
        
        # Install GUI applications
        if [ ${#MISSING_CASKS[@]} -gt 0 ]; then
            echo ""
            echo -e "${BOLD}${MAGENTA}Installing GUI applications...${NC}"
            for cask in "${MISSING_CASKS[@]}"; do
                echo -e "${CYAN}Installing $cask...${NC}"
                if brew install --cask "$cask"; then
                    echo -e "${GREEN}${CHECK} $cask installed successfully${NC}"
                else
                    echo -e "${RED}${CROSS} Failed to install $cask${NC}"
                fi
            done
        fi
        
        echo ""
        echo -e "${BOLD}${GREEN}Installation complete!${NC}"
        echo -e "${YELLOW}${INFO} Run this script again to verify all installations${NC}"
    else
        echo -e "${YELLOW}Skipping installation. You can install manually with:${NC}"
        if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
            echo -e "  ${CYAN}brew install ${MISSING_TOOLS[*]}${NC}"
        fi
        if [ ${#MISSING_CASKS[@]} -gt 0 ]; then
            echo -e "  ${CYAN}brew install --cask ${MISSING_CASKS[*]}${NC}"
        fi
    fi
fi

echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"

# Verify critical apps are running
echo ""
echo -e "${BOLD}${MAGENTA}Verifying critical applications...${NC}"

REQUIRED_APPS=(
    "com.apple.dt.Xcode:Xcode:/Applications/Xcode.app"
    "com.microsoft.VSCode:Visual Studio Code:/Applications/Visual Studio Code.app"
    "com.googlecode.iterm2:iTerm2:/Applications/iTerm.app"
    "eu.exelban.Stats:Stats:/Applications/Stats.app"
)

ALL_RUNNING=true
APPS_TO_START=()

for app_info in "${REQUIRED_APPS[@]}"; do
    IFS=':' read -r bundle_id app_name app_path <<< "$app_info"
    printf "%-25s " "$app_name"
    
    if pgrep -f "$bundle_id" >/dev/null 2>&1; then
        echo -e "${GREEN}${CHECK} Running${NC}"
    else
        echo -e "${RED}${CROSS} Not running${NC}"
        ALL_RUNNING=false
        APPS_TO_START+=("$app_name:$app_path")
    fi
done

echo ""
if [ "$ALL_RUNNING" = true ]; then
    echo -e "${BOLD}${GREEN}✓ CHECK COMPLETE - All critical apps are running${NC}"
else
    echo -e "${BOLD}${YELLOW}⚠ Some critical apps are not running${NC}"
    
    if [ ${#APPS_TO_START[@]} -gt 0 ]; then
        echo ""
        echo -e "${BOLD}Starting missing applications...${NC}"
        
        for app_info in "${APPS_TO_START[@]}"; do
            IFS=':' read -r app_name app_path <<< "$app_info"
            
            if [ -d "$app_path" ]; then
                echo -e "${CYAN}Launching $app_name...${NC}"
                open "$app_path" 2>/dev/null && \
                    echo -e "${GREEN}${CHECK} $app_name started${NC}" || \
                    echo -e "${RED}${CROSS} Failed to start $app_name${NC}"
            else
                echo -e "${YELLOW}${WARNING} $app_name not found at $app_path${NC}"
            fi
        done
        
        echo ""
        echo -e "${BOLD}${GREEN}✓ CHECK COMPLETE - Applications started${NC}"
    fi
fi

echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
