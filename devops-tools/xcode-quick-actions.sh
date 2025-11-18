#!/bin/bash
################################################################################
# Xcode Project Quick Actions
# Batch operations on Xcode projects: clean, build, archive, test
################################################################################

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Default values
ACTION="menu"
PROJECT_PATH=""
SCHEME=""
CONFIGURATION="Debug"
CLEAN=false

show_usage() {
    cat << EOF
${BOLD}${CYAN}Xcode Project Quick Actions${NC}

${BOLD}Usage:${NC}
  $0 [OPTIONS]

${BOLD}Options:${NC}
  -a, --action       Action to perform (clean|build|test|archive|all)
  -p, --project      Path to .xcodeproj or .xcworkspace
  -s, --scheme       Scheme name
  -c, --config       Configuration (Debug|Release) [default: Debug]
  --clean            Clean before build
  -h, --help         Show this help message

${BOLD}Examples:${NC}
  $0 -a build -p MyApp.xcodeproj -s MyApp
  $0 -a test -p MyApp.xcworkspace -s MyApp --clean
  $0 -a all -p MyApp.xcodeproj -s MyApp -c Release

${BOLD}Interactive Menu:${NC}
  Run without options for interactive mode
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        -p|--project)
            PROJECT_PATH="$2"
            shift 2
            ;;
        -s|--scheme)
            SCHEME="$2"
            shift 2
            ;;
        -c|--config)
            CONFIGURATION="$2"
            shift 2
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Interactive menu
if [ "$ACTION" == "menu" ]; then
    echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║            Xcode Project Quick Actions Menu                   ║${NC}"
    echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Find Xcode projects
    echo -e "${BOLD}Finding Xcode projects...${NC}"
    projects=($(find . -maxdepth 2 -name "*.xcodeproj" -o -name "*.xcworkspace" 2>/dev/null))
    
    if [ ${#projects[@]} -eq 0 ]; then
        echo -e "${RED}No Xcode projects found in current directory${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${BOLD}Select a project:${NC}"
    for i in "${!projects[@]}"; do
        echo -e "  $((i+1)). ${CYAN}${projects[$i]}${NC}"
    done
    echo ""
    
    read -p "Enter project number: " proj_num
    PROJECT_PATH="${projects[$((proj_num-1))]}"
    
    echo ""
    echo -e "${BOLD}Select an action:${NC}"
    echo -e "  1. ${GREEN}Clean${NC}"
    echo -e "  2. ${CYAN}Build${NC}"
    echo -e "  3. ${YELLOW}Test${NC}"
    echo -e "  4. ${MAGENTA}Archive${NC}"
    echo -e "  5. ${BOLD}All (Clean + Build + Test)${NC}"
    echo ""
    
    read -p "Enter action number: " action_num
    case $action_num in
        1) ACTION="clean" ;;
        2) ACTION="build" ;;
        3) ACTION="test" ;;
        4) ACTION="archive" ;;
        5) ACTION="all" ;;
        *) echo -e "${RED}Invalid selection${NC}"; exit 1 ;;
    esac
    
    echo ""
    read -p "Enter scheme name: " SCHEME
    
    echo ""
    read -p "Configuration (Debug/Release) [Debug]: " config_input
    CONFIGURATION=${config_input:-Debug}
fi

# Validate inputs
if [ -z "$PROJECT_PATH" ] || [ -z "$SCHEME" ]; then
    echo -e "${RED}Error: Project path and scheme are required${NC}"
    show_usage
    exit 1
fi

if [ ! -e "$PROJECT_PATH" ]; then
    echo -e "${RED}Error: Project not found: $PROJECT_PATH${NC}"
    exit 1
fi

# Determine project type
if [[ "$PROJECT_PATH" == *.xcworkspace ]]; then
    PROJECT_FLAG="-workspace"
else
    PROJECT_FLAG="-project"
fi

echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Project:       ${CYAN}$PROJECT_PATH${NC}"
echo -e "${BOLD}Scheme:        ${CYAN}$SCHEME${NC}"
echo -e "${BOLD}Configuration: ${CYAN}$CONFIGURATION${NC}"
echo -e "${BOLD}Action:        ${CYAN}$ACTION${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Clean function
do_clean() {
    echo -e "${BOLD}${YELLOW}[CLEAN]${NC} Cleaning build artifacts..."
    xcodebuild clean \
        $PROJECT_FLAG "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION"
    
    echo -e "${GREEN}✓ Clean completed${NC}"
    echo ""
}

# Build function
do_build() {
    echo -e "${BOLD}${CYAN}[BUILD]${NC} Building project..."
    xcodebuild build \
        $PROJECT_FLAG "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO
    
    echo -e "${GREEN}✓ Build completed${NC}"
    echo ""
}

# Test function
do_test() {
    echo -e "${BOLD}${MAGENTA}[TEST]${NC} Running tests..."
    xcodebuild test \
        $PROJECT_FLAG "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination 'platform=macOS' \
        CODE_SIGNING_REQUIRED=NO
    
    echo -e "${GREEN}✓ Tests completed${NC}"
    echo ""
}

# Archive function
do_archive() {
    echo -e "${BOLD}${YELLOW}[ARCHIVE]${NC} Creating archive..."
    ARCHIVE_PATH="./build/Archives/${SCHEME}_$(date +%Y%m%d_%H%M%S).xcarchive"
    
    xcodebuild archive \
        $PROJECT_FLAG "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -archivePath "$ARCHIVE_PATH"
    
    echo -e "${GREEN}✓ Archive created: $ARCHIVE_PATH${NC}"
    echo ""
}

# Execute action
case $ACTION in
    clean)
        do_clean
        ;;
    build)
        [ "$CLEAN" == true ] && do_clean
        do_build
        ;;
    test)
        [ "$CLEAN" == true ] && do_clean
        do_test
        ;;
    archive)
        [ "$CLEAN" == true ] && do_clean
        do_archive
        ;;
    all)
        do_clean
        do_build
        do_test
        ;;
    *)
        echo -e "${RED}Invalid action: $ACTION${NC}"
        show_usage
        exit 1
        ;;
esac

echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║                   Operation Completed!                        ║${NC}"
echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
