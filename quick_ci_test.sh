#!/bin/bash

GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

PASSED=0
FAILED=0

test_cmd() {
    echo -n "  Testing: $1... "
    if eval "$2" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((FAILED++))
    fi
}

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Quick CI/CD Pipeline Test              ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Stage 1: macOS Tests${NC}"
test_cmd "macOS system" "sw_vers"
test_cmd "Git" "git --version"
test_cmd "Python3" "python3 --version"
echo ""

echo -e "${YELLOW}Stage 2: Linux VM Tests${NC}"
echo "  Checking VM status..."
test_cmd "VM running" "multipass list | grep -q 'ubuntu-dev.*Running'"
echo "  Testing VM connectivity (this may take a moment)..."
test_cmd "VM responsive" "timeout 5 multipass exec ubuntu-dev -- echo test"
test_cmd "Git on Linux" "timeout 5 multipass exec ubuntu-dev -- git --version"
test_cmd "Docker on Linux" "timeout 5 multipass exec ubuntu-dev -- docker --version"
echo ""

echo -e "${YELLOW}Stage 3: Integration${NC}"
test_cmd "Repository sync" "timeout 5 multipass exec ubuntu-dev -- test -d /home/ubuntu/AppleDevOpsAutomate"
echo ""

TOTAL=$((PASSED + FAILED))
echo -e "${BLUE}Results: ${GREEN}${PASSED}${NC}/${TOTAL} passed${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
else
    echo -e "${YELLOW}⚠ Some tests failed${NC}"
fi
