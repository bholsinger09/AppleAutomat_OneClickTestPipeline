#!/bin/bash

###############################################################################
# Cross-Platform Development & Testing Script
# Tests scripts on both macOS and Linux (Ubuntu VM)
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Results tracking
MACOS_PASSED=0
MACOS_FAILED=0
LINUX_PASSED=0
LINUX_FAILED=0

echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Cross-Platform Development & Testing Suite          ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""

###############################################################################
# Test on macOS (Local)
###############################################################################

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  PHASE 1: Testing on macOS (Local)                     ${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

# Test 1: Git Batch Operations (Cross-platform)
echo -e "${YELLOW}[macOS] Test 1: Git Batch Operations${NC}"
if bash "$SCRIPT_DIR/devops-tools/git-batch.sh" status > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Git batch operations working${NC}"
    ((MACOS_PASSED++))
else
    echo -e "${RED}✗ Git batch operations failed${NC}"
    ((MACOS_FAILED++))
fi
echo ""

# Test 2: Check DevTools (Cross-platform with adaptations)
echo -e "${YELLOW}[macOS] Test 2: DevTools Check${NC}"
if bash "$SCRIPT_DIR/devops-tools/check-devtools.sh" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ DevTools check passed${NC}"
    ((MACOS_PASSED++))
else
    echo -e "${RED}✗ DevTools check failed${NC}"
    ((MACOS_FAILED++))
fi
echo ""

# Test 3: macOS-specific tools
echo -e "${YELLOW}[macOS] Test 3: macOS System Monitor${NC}"
if bash "$SCRIPT_DIR/devops-tools/mac-system-monitor.sh" quick > /dev/null 2>&1; then
    echo -e "${GREEN}✓ macOS system monitor working${NC}"
    ((MACOS_PASSED++))
else
    echo -e "${RED}✗ macOS system monitor failed${NC}"
    ((MACOS_FAILED++))
fi
echo ""

# Test 4: Project initialization (Cross-platform)
echo -e "${YELLOW}[macOS] Test 4: Project Initialization${NC}"
if bash "$SCRIPT_DIR/devops-tools/project-init.sh" --help > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Project init script working${NC}"
    ((MACOS_PASSED++))
else
    echo -e "${RED}✗ Project init script failed${NC}"
    ((MACOS_FAILED++))
fi
echo ""

###############################################################################
# Test on Linux (Ubuntu VM via Multipass)
###############################################################################

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  PHASE 2: Testing on Linux (Ubuntu VM)                 ${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

# Check if Multipass VM is running
echo -e "${YELLOW}Checking Ubuntu VM status...${NC}"
if multipass list | grep -q "ubuntu-dev.*Running"; then
    echo -e "${GREEN}✓ Ubuntu VM is running${NC}"
    echo ""
else
    echo -e "${RED}✗ Ubuntu VM is not running${NC}"
    echo "  Start it with: multipass start ubuntu-dev"
    exit 1
fi

# Test 1: Git operations on Linux
echo -e "${YELLOW}[Linux] Test 1: Git Batch Operations${NC}"
if multipass exec ubuntu-dev -- bash -c "cd /home/ubuntu/AppleDevOpsAutomate && bash devops-tools/git-batch.sh status" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Git batch operations working on Linux${NC}"
    ((LINUX_PASSED++))
else
    echo -e "${RED}✗ Git batch operations failed on Linux${NC}"
    ((LINUX_FAILED++))
fi
echo ""

# Test 2: DevTools check on Linux
echo -e "${YELLOW}[Linux] Test 2: DevTools Check${NC}"
if multipass exec ubuntu-dev -- bash -c "cd /home/ubuntu/AppleDevOpsAutomate && bash devops-tools/check-devtools.sh" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ DevTools check passed on Linux${NC}"
    ((LINUX_PASSED++))
else
    echo -e "${RED}✗ DevTools check failed on Linux${NC}"
    ((LINUX_FAILED++))
fi
echo ""

# Test 3: Docker on Linux
echo -e "${YELLOW}[Linux] Test 3: Docker Functionality${NC}"
if multipass exec ubuntu-dev -- docker ps > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Docker working on Linux${NC}"
    ((LINUX_PASSED++))
else
    echo -e "${RED}✗ Docker failed on Linux${NC}"
    ((LINUX_FAILED++))
fi
echo ""

# Test 4: Python environment on Linux
echo -e "${YELLOW}[Linux] Test 4: Python Environment${NC}"
if multipass exec ubuntu-dev -- python3 --version > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Python3 available on Linux${NC}"
    ((LINUX_PASSED++))
else
    echo -e "${RED}✗ Python3 not available on Linux${NC}"
    ((LINUX_FAILED++))
fi
echo ""

# Test 5: Create and test a simple cross-platform script
echo -e "${YELLOW}[Linux] Test 5: Cross-Platform Script Execution${NC}"
multipass exec ubuntu-dev -- bash -c "cat > /tmp/test_script.sh << 'EOF'
#!/bin/bash
echo \"Hello from \$(uname -s)\"
echo \"Architecture: \$(uname -m)\"
echo \"Kernel: \$(uname -r)\"
EOF
chmod +x /tmp/test_script.sh
bash /tmp/test_script.sh
" > /tmp/linux_output.txt 2>&1

if grep -q "Hello from Linux" /tmp/linux_output.txt; then
    echo -e "${GREEN}✓ Cross-platform script executed successfully${NC}"
    cat /tmp/linux_output.txt
    ((LINUX_PASSED++))
else
    echo -e "${RED}✗ Cross-platform script failed${NC}"
    ((LINUX_FAILED++))
fi
echo ""

###############################################################################
# Results Summary
###############################################################################

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  TEST RESULTS SUMMARY                                   ${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

TOTAL_PASSED=$((MACOS_PASSED + LINUX_PASSED))
TOTAL_FAILED=$((MACOS_FAILED + LINUX_FAILED))
TOTAL_TESTS=$((TOTAL_PASSED + TOTAL_FAILED))

echo -e "${YELLOW}macOS Tests:${NC}"
echo -e "  Passed: ${GREEN}${MACOS_PASSED}${NC}"
echo -e "  Failed: ${RED}${MACOS_FAILED}${NC}"
echo ""

echo -e "${YELLOW}Linux Tests:${NC}"
echo -e "  Passed: ${GREEN}${LINUX_PASSED}${NC}"
echo -e "  Failed: ${RED}${LINUX_FAILED}${NC}"
echo ""

echo -e "${YELLOW}Overall:${NC}"
echo -e "  Total Tests: ${TOTAL_TESTS}"
echo -e "  Passed: ${GREEN}${TOTAL_PASSED}${NC}"
echo -e "  Failed: ${RED}${TOTAL_FAILED}${NC}"
echo -e "  Success Rate: $(( TOTAL_PASSED * 100 / TOTAL_TESTS ))%"
echo ""

if [ $TOTAL_FAILED -eq 0 ]; then
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✓ ALL CROSS-PLATFORM TESTS PASSED!                  ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  ⚠ SOME TESTS FAILED - Review results above          ║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════════╝${NC}"
    exit 1
fi
