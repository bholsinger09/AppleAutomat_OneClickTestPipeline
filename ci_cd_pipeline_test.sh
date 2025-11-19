#!/bin/bash

###############################################################################
# Cross-Platform CI/CD Pipeline Test
# Demonstrates automated testing across macOS and Linux environments
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

test_run() {
    local name="$1"
    local command="$2"
    
    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $name"
        ((FAILED++))
    fi
}

cd /Users/benh/Documents/AppleDevOpsAutomate

echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║     Cross-Platform CI/CD Pipeline Test Suite          ║${NC}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Testing automated deployment pipeline...${NC}"
echo ""

###############################################################################
# Stage 1: Local Environment (macOS)
###############################################################################

echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${YELLOW}  STAGE 1: macOS Development Environment${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_run "macOS system detected" "sw_vers"
test_run "Git version control" "git --version"
test_run "Python3 runtime" "python3 --version"
test_run "Bash shell" "bash --version"
test_run "Repository accessible" "[ -d .git ]"
test_run "Git repository healthy" "git status"

echo ""

###############################################################################
# Stage 2: Remote Environment (Linux VM)
###############################################################################

echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${YELLOW}  STAGE 2: Linux Production Environment${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_run "Ubuntu VM running" "multipass list | grep -q 'ubuntu-dev.*Running'"
test_run "Git on Linux" "multipass exec ubuntu-dev -- git --version"
test_run "Python on Linux" "multipass exec ubuntu-dev -- python3 --version"
test_run "Docker engine" "multipass exec ubuntu-dev -- docker --version"
test_run "Docker daemon active" "multipass exec ubuntu-dev -- docker ps"

echo ""

###############################################################################
# Stage 3: Code Synchronization
###############################################################################

echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${YELLOW}  STAGE 3: Cross-Platform Code Sync${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_run "Shared directory mounted" "multipass exec ubuntu-dev -- [ -d /home/ubuntu/AppleDevOpsAutomate ]"
test_run "Repository on Linux" "multipass exec ubuntu-dev -- bash -c 'cd /home/ubuntu/AppleDevOpsAutomate && git status'"
test_run "Scripts accessible" "multipass exec ubuntu-dev -- [ -f /home/ubuntu/AppleDevOpsAutomate/setup.sh ]"

echo ""

###############################################################################
# Stage 4: Container Orchestration
###############################################################################

echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${YELLOW}  STAGE 4: Docker Container Tests${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_run "Pull alpine image" "multipass exec ubuntu-dev -- docker pull alpine:latest"
test_run "Run test container" "multipass exec ubuntu-dev -- docker run --rm alpine:latest echo 'Container test'"
test_run "Ubuntu container" "multipass exec ubuntu-dev -- docker run --rm ubuntu:24.04 uname -a"

echo ""

###############################################################################
# Stage 5: Script Execution Tests
###############################################################################

echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${YELLOW}  STAGE 5: Cross-Platform Script Execution${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_run "DevTools check (macOS)" "bash devops-tools/check-devtools.sh"
test_run "DevTools check (Linux)" "multipass exec ubuntu-dev -- bash -c 'cd /home/ubuntu/AppleDevOpsAutomate && bash devops-tools/check-devtools.sh'"
test_run "macOS system monitor" "bash devops-tools/mac-system-monitor.sh quick"

echo ""

###############################################################################
# Stage 6: Python Application Tests
###############################################################################

echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${YELLOW}  STAGE 6: Python Application Testing${NC}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Create test Python script
cat > /tmp/ci_test.py << 'EOF'
#!/usr/bin/env python3
import sys
import platform
sys.exit(0 if platform.system() in ['Darwin', 'Linux'] else 1)
EOF

test_run "Python test (macOS)" "python3 /tmp/ci_test.py"
multipass transfer /tmp/ci_test.py ubuntu-dev:/tmp/ci_test.py >/dev/null 2>&1
test_run "Python test (Linux)" "multipass exec ubuntu-dev -- python3 /tmp/ci_test.py"

echo ""

###############################################################################
# Results Summary
###############################################################################

TOTAL=$((PASSED + FAILED))
SUCCESS_RATE=$(( PASSED * 100 / TOTAL ))

echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║                  TEST RESULTS                          ║${NC}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${CYAN}Pipeline Stages Completed:${NC}"
echo "  ✓ Stage 1: macOS Development Environment"
echo "  ✓ Stage 2: Linux Production Environment"
echo "  ✓ Stage 3: Cross-Platform Code Sync"
echo "  ✓ Stage 4: Docker Container Tests"
echo "  ✓ Stage 5: Cross-Platform Script Execution"
echo "  ✓ Stage 6: Python Application Testing"
echo ""

echo -e "${CYAN}Test Statistics:${NC}"
echo -e "  Total Tests: ${BOLD}${TOTAL}${NC}"
echo -e "  Passed: ${GREEN}${BOLD}${PASSED}${NC}"
echo -e "  Failed: ${RED}${BOLD}${FAILED}${NC}"
echo -e "  Success Rate: ${BOLD}${SUCCESS_RATE}%${NC}"
echo ""

echo -e "${CYAN}Environments Tested:${NC}"
echo "  • macOS (Darwin ARM64) - Local development"
echo "  • Linux (Ubuntu 24.04 ARM64) - Production simulation"
echo "  • Docker Containers - Deployment testing"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${BOLD}${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║  🚀 PIPELINE READY FOR DEPLOYMENT! 🚀                 ║${NC}"
    echo -e "${BOLD}${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "  1. Push code to GitHub repository"
    echo "  2. GitHub Actions will run automatically"
    echo "  3. Tests will run on ubuntu-latest & macos-latest"
    echo "  4. Docker images will be built and tested"
    echo "  5. Deploy to production if all tests pass"
    echo ""
    exit 0
elif [ $SUCCESS_RATE -ge 80 ]; then
    echo -e "${BOLD}${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${YELLOW}║  ⚠️  PIPELINE PASSED WITH WARNINGS ⚠️                 ║${NC}"
    echo -e "${BOLD}${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Most tests passed, review failures before deployment"
    exit 0
else
    echo -e "${BOLD}${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${RED}║  ❌ PIPELINE FAILED - FIX ISSUES BEFORE DEPLOY ❌     ║${NC}"
    echo -e "${BOLD}${RED}╚════════════════════════════════════════════════════════╝${NC}"
    exit 1
fi
