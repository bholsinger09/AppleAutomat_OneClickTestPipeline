#!/bin/bash
################################################################################
# Git Batch Operations
# Perform git operations across multiple repositories
################################################################################

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Default search path
SEARCH_PATH="${1:-$HOME/Documents}"

echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║              Git Batch Operations Tool                        ║${NC}"
echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BOLD}Searching for Git repositories in: ${CYAN}$SEARCH_PATH${NC}"
echo ""

# Find all git repositories
repos=()
while IFS= read -r -d '' dir; do
    repos+=("$dir")
done < <(find "$SEARCH_PATH" -name ".git" -type d -prune -print0 2>/dev/null | sed 's/\/.git//g' | tr '\0' '\0')

if [ ${#repos[@]} -eq 0 ]; then
    echo -e "${RED}No Git repositories found${NC}"
    exit 1
fi

echo -e "${BOLD}Found ${#repos[@]} repositories${NC}"
echo ""

# Show menu
echo -e "${BOLD}Select an operation:${NC}"
echo -e "  1. ${CYAN}Status${NC} - Check status of all repos"
echo -e "  2. ${GREEN}Pull${NC} - Pull latest changes from all repos"
echo -e "  3. ${YELLOW}Fetch${NC} - Fetch updates from all remotes"
echo -e "  4. ${MAGENTA}Branch${NC} - Show current branch of all repos"
echo -e "  5. ${RED}Uncommitted${NC} - List repos with uncommitted changes"
echo -e "  6. ${CYAN}Behind${NC} - List repos behind remote"
echo ""

read -p "Enter operation number: " operation

echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

perform_status() {
    for repo in "${repos[@]}"; do
        cd "$repo"
        echo -e "${BOLD}${CYAN}▶ $(basename "$repo")${NC} ${YELLOW}($repo)${NC}"
        
        if git status --short | grep -q .; then
            git status --short
            echo -e "${RED}✗ Has uncommitted changes${NC}"
        else
            echo -e "${GREEN}✓ Clean working directory${NC}"
        fi
        echo ""
    done
}

perform_pull() {
    for repo in "${repos[@]}"; do
        cd "$repo"
        echo -e "${BOLD}${CYAN}▶ $(basename "$repo")${NC}"
        
        if git pull; then
            echo -e "${GREEN}✓ Pulled successfully${NC}"
        else
            echo -e "${RED}✗ Pull failed${NC}"
        fi
        echo ""
    done
}

perform_fetch() {
    for repo in "${repos[@]}"; do
        cd "$repo"
        echo -e "${BOLD}${CYAN}▶ $(basename "$repo")${NC}"
        
        if git fetch --all; then
            echo -e "${GREEN}✓ Fetched successfully${NC}"
        else
            echo -e "${RED}✗ Fetch failed${NC}"
        fi
        echo ""
    done
}

perform_branch() {
    for repo in "${repos[@]}"; do
        cd "$repo"
        branch=$(git branch --show-current)
        remote_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "No remote")
        
        echo -e "${BOLD}$(basename "$repo")${NC}: ${CYAN}$branch${NC} → ${YELLOW}$remote_branch${NC}"
    done
}

perform_uncommitted() {
    found=false
    for repo in "${repos[@]}"; do
        cd "$repo"
        if ! git diff-index --quiet HEAD -- 2>/dev/null; then
            found=true
            echo -e "${YELLOW}✗ $(basename "$repo")${NC} ${CYAN}($repo)${NC}"
            git status --short
            echo ""
        fi
    done
    
    if [ "$found" = false ]; then
        echo -e "${GREEN}All repositories have clean working directories${NC}"
    fi
}

perform_behind() {
    found=false
    for repo in "${repos[@]}"; do
        cd "$repo"
        git fetch --quiet 2>/dev/null || continue
        
        LOCAL=$(git rev-parse @ 2>/dev/null || echo "")
        REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "")
        
        if [ -n "$LOCAL" ] && [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]; then
            BEHIND=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
            AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
            
            if [ "$BEHIND" != "0" ] || [ "$AHEAD" != "0" ]; then
                found=true
                echo -e "${YELLOW}$(basename "$repo")${NC} ${CYAN}($repo)${NC}"
                [ "$BEHIND" != "0" ] && echo -e "  ${RED}Behind: $BEHIND commits${NC}"
                [ "$AHEAD" != "0" ] && echo -e "  ${GREEN}Ahead: $AHEAD commits${NC}"
                echo ""
            fi
        fi
    done
    
    if [ "$found" = false ]; then
        echo -e "${GREEN}All repositories are up to date${NC}"
    fi
}

# Execute operation
case $operation in
    1)
        perform_status
        ;;
    2)
        perform_pull
        ;;
    3)
        perform_fetch
        ;;
    4)
        perform_branch
        ;;
    5)
        perform_uncommitted
        ;;
    6)
        perform_behind
        ;;
    *)
        echo -e "${RED}Invalid operation${NC}"
        exit 1
        ;;
esac

echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}Operation completed!${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
