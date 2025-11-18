#!/bin/bash

###############################################################################
# Quick Test Script
# Tests the pipeline with different scenarios
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="/Users/benh/Documents/DevRealatorApp"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Pipeline Test Suite                    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# Test 1: Build only (no tests)
echo -e "${BLUE}Test 1: Build iOS app (no tests)${NC}"
cd "$PROJECT_DIR" && "$SCRIPT_DIR/one_click_pipeline.sh" \
    --platform ios \
    --scheme "DevRealatorApp" \
    --skip-tests

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Test 1 passed${NC}"
else
    echo -e "${YELLOW}⚠ Test 1 failed${NC}"
fi

echo ""
echo -e "${BLUE}Test 2: Check cleanup${NC}"
"$SCRIPT_DIR/scripts/cleanup.sh" --derived-data

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Test 2 passed${NC}"
else
    echo -e "${YELLOW}⚠ Test 2 failed${NC}"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Test Suite Complete                    ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
