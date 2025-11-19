#!/bin/bash
################################################################################
# DevOps Tools Master Menu
# Central hub for all DevOps enhancement scripts
################################################################################

set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

clear

echo -e "${BOLD}${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║        ██████╗ ███████╗██╗   ██╗ ██████╗ ██████╗ ███████╗    ║
║        ██╔══██╗██╔════╝██║   ██║██╔═══██╗██╔══██╗██╔════╝    ║
║        ██║  ██║█████╗  ██║   ██║██║   ██║██████╔╝███████╗    ║
║        ██║  ██║██╔══╝  ╚██╗ ██╔╝██║   ██║██╔═══╝ ╚════██║    ║
║        ██████╔╝███████╗ ╚████╔╝ ╚██████╔╝██║     ███████║    ║
║        ╚═════╝ ╚══════╝  ╚═══╝   ╚═════╝ ╚═╝     ╚══════╝    ║
║                                                               ║
║              Enhancement Tools & Automation Suite             ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BOLD}${GREEN}Available Tools:${NC}"
echo ""
echo -e "  ${BOLD}1.${NC} ${CYAN}Health Check${NC}         - Check installation & versions of dev tools"
echo -e "  ${BOLD}2.${NC} ${GREEN}Auto Update${NC}          - Update all development tools & packages"
echo -e "  ${BOLD}3.${NC} ${YELLOW}System Cleanup${NC}        - Clean caches & free disk space"
echo -e "  ${BOLD}4.${NC} ${MAGENTA}Xcode Quick Actions${NC}   - Batch build, test, clean Xcode projects"
echo -e "  ${BOLD}5.${NC} ${CYAN}Git Batch Ops${NC}         - Perform git operations on multiple repos"
echo -e "  ${BOLD}6.${NC} ${BLUE}Performance Monitor${NC}   - Track build performance & generate reports"
echo -e "  ${BOLD}7.${NC} ${GREEN}Run Pipeline${NC}          - Execute AppleAutomat build pipeline"
echo ""
echo -e "  ${BOLD}0.${NC} Exit"
echo ""

read -p "$(echo -e ${BOLD}Select a tool:${NC} )" choice

case $choice in
    1)
        echo ""
        echo -e "${CYAN}Running Health Check...${NC}"
        echo ""
        "$SCRIPT_DIR/check-devtools.sh"
        ;;
    2)
        echo ""
        echo -e "${GREEN}Running Auto Update...${NC}"
        echo ""
        "$SCRIPT_DIR/auto-update.sh"
        ;;
    3)
        echo ""
        echo -e "${YELLOW}Running System Cleanup...${NC}"
        echo ""
        read -p "This will delete caches and temporary files. Continue? (y/n): " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            "$SCRIPT_DIR/system-cleanup.sh"
        else
            echo "Cancelled"
        fi
        ;;
    4)
        echo ""
        echo -e "${MAGENTA}Running Xcode Quick Actions...${NC}"
        echo ""
        "$SCRIPT_DIR/xcode-quick-actions.sh"
        ;;
    5)
        echo ""
        echo -e "${CYAN}Running Git Batch Operations...${NC}"
        echo ""
        "$SCRIPT_DIR/git-batch.sh"
        ;;
    6)
        echo ""
        echo -e "${BLUE}Running Performance Monitor...${NC}"
        echo ""
        "$SCRIPT_DIR/performance-monitor.sh"
        ;;
    7)
        echo ""
        echo -e "${GREEN}Running AppleAutomat Pipeline...${NC}"
        echo ""
        cd "$SCRIPT_DIR/.."
        ./one_click_pipeline.sh
        ;;
    0)
        echo -e "${GREEN}Goodbye!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid selection${NC}"
        exit 1
        ;;
esac

echo ""
read -p "Press Enter to return to menu or Ctrl+C to exit..."
exec "$0"
