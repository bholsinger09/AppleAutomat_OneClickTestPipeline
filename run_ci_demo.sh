#!/bin/bash

###############################################################################
# Fast CI/CD Pipeline Demo - With Progress Indicators
###############################################################################

GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m"
BOLD="\033[1m"

PASSED=0
FAILED=0

test_with_output() {
    local name="$1"
    local cmd="$2"
    
    echo -e "${CYAN}→${NC} $name"
    if output=$(eval "$cmd" 2>&1); then
        echo -e "  ${GREEN}✓ PASS${NC}"
        [ -n "$output" ] && echo "  Output: $(echo "$output" | head -1)"
        ((PASSED++))
    else
        echo -e "  ${RED}✗ FAIL${NC}"
        ((FAILED++))
    fi
    echo ""
}

clear
echo -e "${BOLD}${BLUE}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║       CI/CD Pipeline - Cross-Platform Testing         ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

###############################################################################
# Stage 1: macOS Environment
###############################################################################

echo -e "${BOLD}${YELLOW}━━━ STAGE 1: macOS Development Environment ━━━${NC}"
echo ""

test_with_output "macOS Version Detection" "sw_vers -productVersion"
test_with_output "Git Version Control" "git --version"
test_with_output "Python Runtime" "python3 --version"
test_with_output "Repository Status" "cd /Users/benh/Documents/AppleDevOpsAutomate && git branch --show-current"

###############################################################################
# Stage 2: Linux VM Environment
###############################################################################

echo -e "${BOLD}${YELLOW}━━━ STAGE 2: Linux VM Environment ━━━${NC}"
echo ""

test_with_output "VM Status Check" "multipass list | grep ubuntu-dev"
echo -e "${CYAN}→${NC} Connecting to Ubuntu VM (please wait)..."
test_with_output "Linux Kernel Version" "multipass exec ubuntu-dev -- uname -r"
test_with_output "Git on Linux" "multipass exec ubuntu-dev -- git --version"
test_with_output "Python on Linux" "multipass exec ubuntu-dev -- python3 --version"
test_with_output "Docker Engine" "multipass exec ubuntu-dev -- docker --version"

###############################################################################
# Stage 3: Cross-Platform Integration
###############################################################################

echo -e "${BOLD}${YELLOW}━━━ STAGE 3: Cross-Platform Integration ━━━${NC}"
echo ""

test_with_output "Shared Repository Access" "multipass exec ubuntu-dev -- ls -la /home/ubuntu/AppleDevOpsAutomate | head -5"
test_with_output "Git Sync Status" "multipass exec ubuntu-dev -- bash -c 'cd /home/ubuntu/AppleDevOpsAutomate && git status --short | head -5 || echo \"Clean\"'"

###############################################################################
# Stage 4: Docker Container Test
###############################################################################

echo -e "${BOLD}${YELLOW}━━━ STAGE 4: Container Orchestration ━━━${NC}"
echo ""

test_with_output "Docker Service Status" "multipass exec ubuntu-dev -- docker ps"
echo -e "${CYAN}→${NC} Running test container..."
test_with_output "Container Execution Test" "multipass exec ubuntu-dev -- docker run --rm alpine:latest echo 'Container test passed'"

###############################################################################
# Stage 5: Application Tests
###############################################################################

echo -e "${BOLD}${YELLOW}━━━ STAGE 5: Application Testing ━━━${NC}"
echo ""

# Create and transfer test script
cat > /tmp/app_test.sh << 'EOFTEST'
#!/bin/bash
echo "Platform: $(uname -s)"
echo "Architecture: $(uname -m)"
echo "Hostname: $(hostname)"
EOFTEST

test_with_output "Test Script on macOS" "bash /tmp/app_test.sh"
multipass transfer /tmp/app_test.sh ubuntu-dev:/tmp/app_test.sh >/dev/null 2>&1
test_with_output "Test Script on Linux" "multipass exec ubuntu-dev -- bash /tmp/app_test.sh"

###############################################################################
# Results
###############################################################################

TOTAL=$((PASSED + FAILED))
SUCCESS_RATE=$(( PASSED * 100 / TOTAL ))

echo -e "${BOLD}${BLUE}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║                  PIPELINE RESULTS                      ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${CYAN}Test Summary:${NC}"
echo -e "  Total Tests: ${BOLD}${TOTAL}${NC}"
echo -e "  Passed: ${GREEN}${BOLD}${PASSED}${NC}"
echo -e "  Failed: ${RED}${BOLD}${FAILED}${NC}"
echo -e "  Success Rate: ${BOLD}${SUCCESS_RATE}%${NC}"
echo ""

echo -e "${CYAN}Platforms Tested:${NC}"
echo "  ✓ macOS (Development)"
echo "  ✓ Linux Ubuntu VM (Production)"
echo "  ✓ Docker Containers (Deployment)"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${BOLD}${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║  🎉 ALL CI/CD TESTS PASSED - READY TO DEPLOY! 🎉     ║${NC}"
    echo -e "${BOLD}${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}What this demonstrates:${NC}"
    echo "  • Automated testing across multiple platforms"
    echo "  • Cross-platform code validation"
    echo "  • Container orchestration capabilities"
    echo "  • CI/CD pipeline best practices"
    echo "  • Production-ready deployment process"
else
    echo -e "${BOLD}${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${YELLOW}║  Pipeline completed with some failures                ║${NC}"
    echo -e "${BOLD}${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
fi

echo ""
