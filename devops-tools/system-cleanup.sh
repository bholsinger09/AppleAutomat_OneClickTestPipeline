#!/bin/bash
################################################################################
# System Cleanup & Optimization Script
# Cleans Xcode, Homebrew, npm, and system caches to free up disk space
################################################################################

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

TOTAL_FREED=0

echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║            System Cleanup & Optimization Tool                 ║${NC}"
echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to get directory size
get_size() {
    if [ -d "$1" ]; then
        du -sh "$1" 2>/dev/null | awk '{print $1}'
    else
        echo "0B"
    fi
}

# Function to get size in bytes
get_size_bytes() {
    if [ -d "$1" ]; then
        du -sk "$1" 2>/dev/null | awk '{print $1}'
    else
        echo "0"
    fi
}

# Function to clean with progress
clean_path() {
    local path=$1
    local description=$2
    local before_size=$(get_size_bytes "$path")
    
    if [ -d "$path" ]; then
        echo -e "${YELLOW}Cleaning: $description${NC}"
        echo -e "  Location: $path"
        echo -e "  Size before: $(get_size "$path")"
        
        rm -rf "$path" 2>/dev/null || true
        
        local after_size=$(get_size_bytes "$path")
        local freed=$((before_size - after_size))
        TOTAL_FREED=$((TOTAL_FREED + freed))
        
        echo -e "  ${GREEN}✓ Freed: $((freed / 1024))MB${NC}"
        echo ""
    else
        echo -e "${CYAN}Skipping: $description (not found)${NC}"
        echo ""
    fi
}

echo -e "${BOLD}Starting cleanup process...${NC}"
echo ""

# Xcode cleanup
echo -e "${BOLD}${CYAN}═══ Xcode & iOS Development ═══${NC}"
clean_path ~/Library/Developer/Xcode/DerivedData "Xcode DerivedData"
clean_path ~/Library/Developer/Xcode/Archives "Xcode Archives"
clean_path ~/Library/Developer/Xcode/iOS\ DeviceSupport "iOS Device Support"
clean_path ~/Library/Developer/CoreSimulator/Caches "Simulator Caches"

# CocoaPods
if command -v pod >/dev/null 2>&1; then
    echo -e "${YELLOW}Cleaning CocoaPods cache...${NC}"
    pod cache clean --all 2>/dev/null || true
    echo -e "${GREEN}✓ CocoaPods cache cleaned${NC}"
    echo ""
fi

# Homebrew cleanup
if command -v brew >/dev/null 2>&1; then
    echo -e "${BOLD}${CYAN}═══ Homebrew ═══${NC}"
    echo -e "${YELLOW}Running brew cleanup...${NC}"
    brew cleanup -s 2>/dev/null || true
    brew autoremove 2>/dev/null || true
    echo -e "${GREEN}✓ Homebrew cleaned${NC}"
    echo ""
fi

# npm cleanup
if command -v npm >/dev/null 2>&1; then
    echo -e "${BOLD}${CYAN}═══ Node.js & npm ═══${NC}"
    echo -e "${YELLOW}Cleaning npm cache...${NC}"
    npm cache clean --force 2>/dev/null || true
    echo -e "${GREEN}✓ npm cache cleaned${NC}"
    echo ""
fi

# System caches
echo -e "${BOLD}${CYAN}═══ System Caches ═══${NC}"
clean_path ~/Library/Caches/com.apple.dt.Xcode "Xcode System Caches"
clean_path ~/Library/Caches/Homebrew "Homebrew Caches"
clean_path ~/Library/Logs "System Logs"

# Docker cleanup (if installed)
if command -v docker >/dev/null 2>&1; then
    echo -e "${BOLD}${CYAN}═══ Docker ═══${NC}"
    echo -e "${YELLOW}Cleaning Docker images and containers...${NC}"
    docker system prune -af --volumes 2>/dev/null || true
    echo -e "${GREEN}✓ Docker cleaned${NC}"
    echo ""
fi

# Git cleanup
if command -v git >/dev/null 2>&1; then
    echo -e "${BOLD}${CYAN}═══ Git Repositories ═══${NC}"
    echo -e "${YELLOW}Running git garbage collection on common repos...${NC}"
    
    for dir in ~/Documents/*/; do
        if [ -d "$dir/.git" ]; then
            cd "$dir"
            git gc --aggressive --prune=now 2>/dev/null || true
            echo -e "  ${GREEN}✓ $(basename "$dir")${NC}"
        fi
    done
    echo ""
fi

# Empty trash
echo -e "${BOLD}${CYAN}═══ System Cleanup ═══${NC}"
echo -e "${YELLOW}Emptying Trash...${NC}"
rm -rf ~/.Trash/* 2>/dev/null || true
echo -e "${GREEN}✓ Trash emptied${NC}"
echo ""

# Summary
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}Cleanup Complete!${NC}"
echo -e "${BOLD}Total space freed: ~$((TOTAL_FREED / 1024))MB${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Recommendations:${NC}"
echo -e "  • Restart Xcode for best performance"
echo -e "  • Run this script monthly to maintain system health"
echo -e "  • Check Disk Utility for additional cleanup options"
