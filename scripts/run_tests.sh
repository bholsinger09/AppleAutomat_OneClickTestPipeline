#!/bin/bash

###############################################################################
# Test Runner Script
# Handles running XCTests for iOS and macOS applications
###############################################################################

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/logger.sh"

# Default values
PLATFORM=""
SCHEME=""
WORKSPACE=""
PROJECT=""
DESTINATION=""
DERIVED_DATA_PATH="./DerivedData"
TEST_PLAN=""
CODE_COVERAGE=true
PARALLEL_TESTING=true
VERBOSE=false
RESULT_BUNDLE_PATH="./TestResults"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        --scheme)
            SCHEME="$2"
            shift 2
            ;;
        --workspace)
            WORKSPACE="$2"
            shift 2
            ;;
        --project)
            PROJECT="$2"
            shift 2
            ;;
        --destination)
            DESTINATION="$2"
            shift 2
            ;;
        --test-plan)
            TEST_PLAN="$2"
            shift 2
            ;;
        --no-coverage)
            CODE_COVERAGE=false
            shift
            ;;
        --no-parallel)
            PARALLEL_TESTING=false
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate required parameters
if [ -z "$PLATFORM" ]; then
    log_error "Platform is required. Use --platform ios or --platform macos"
    exit 1
fi

if [ -z "$SCHEME" ]; then
    log_error "Scheme is required. Use --scheme YourSchemeName"
    exit 1
fi

# Set default destination based on platform if not provided
if [ -z "$DESTINATION" ]; then
    case "$PLATFORM" in
        ios)
            DESTINATION="platform=iOS Simulator,name=iPhone 15,OS=latest"
            ;;
        macos)
            DESTINATION="platform=macOS"
            ;;
        *)
            log_error "Invalid platform: $PLATFORM"
            exit 1
            ;;
    esac
fi

# Determine project or workspace
PROJECT_ARGS=()
if [ -n "$WORKSPACE" ]; then
    if [ ! -f "$WORKSPACE" ]; then
        log_error "Workspace not found: $WORKSPACE"
        exit 1
    fi
    PROJECT_ARGS+=("-workspace" "$WORKSPACE")
    log_info "Using workspace: $WORKSPACE"
elif [ -n "$PROJECT" ]; then
    if [ ! -f "$PROJECT" ]; then
        log_error "Project not found: $PROJECT"
        exit 1
    fi
    PROJECT_ARGS+=("-project" "$PROJECT")
    log_info "Using project: $PROJECT"
else
    # Try to find workspace or project automatically
    WORKSPACES=(*.xcworkspace)
    PROJECTS=(*.xcodeproj)
    
    if [ -e "${WORKSPACES[0]}" ]; then
        WORKSPACE="${WORKSPACES[0]}"
        PROJECT_ARGS+=("-workspace" "$WORKSPACE")
        log_info "Auto-detected workspace: $WORKSPACE"
    elif [ -e "${PROJECTS[0]}" ]; then
        PROJECT="${PROJECTS[0]}"
        PROJECT_ARGS+=("-project" "$PROJECT")
        log_info "Auto-detected project: $PROJECT"
    else
        log_error "No workspace or project found in current directory"
        exit 1
    fi
fi

# Create result bundle directory
mkdir -p "$RESULT_BUNDLE_PATH"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULT_BUNDLE="${RESULT_BUNDLE_PATH}/TestResults_${TIMESTAMP}.xcresult"

# Check if xcpretty is available
XCPRETTY_AVAILABLE=false
if command -v xcpretty &> /dev/null; then
    XCPRETTY_AVAILABLE=true
    log_info "xcpretty detected - output will be formatted"
fi

# Build test command
log_info "Preparing to run tests..."
log_info "Platform: $PLATFORM"
log_info "Destination: $DESTINATION"
log_info "Code Coverage: $CODE_COVERAGE"
log_info "Parallel Testing: $PARALLEL_TESTING"

TEST_CMD=(
    xcodebuild
    "${PROJECT_ARGS[@]}"
    -scheme "$SCHEME"
    -destination "$DESTINATION"
    -derivedDataPath "$DERIVED_DATA_PATH"
    -resultBundlePath "$RESULT_BUNDLE"
)

# Add test plan if specified
if [ -n "$TEST_PLAN" ]; then
    TEST_CMD+=("-testPlan" "$TEST_PLAN")
    log_info "Test Plan: $TEST_PLAN"
fi

# Add code coverage flag
if [ "$CODE_COVERAGE" = true ]; then
    TEST_CMD+=("-enableCodeCoverage" "YES")
fi

# Add parallel testing flag
if [ "$PARALLEL_TESTING" = true ]; then
    TEST_CMD+=("-parallel-testing-enabled" "YES")
else
    TEST_CMD+=("-parallel-testing-enabled" "NO")
fi

# Add test action
TEST_CMD+=("test")

# Run tests
log_section "Running Tests"

if [ "$VERBOSE" = true ]; then
    log_info "Test command: ${TEST_CMD[*]}"
fi

if [ "$XCPRETTY_AVAILABLE" = true ] && [ "$VERBOSE" = false ]; then
    "${TEST_CMD[@]}" | xcpretty --color --report junit --output "${RESULT_BUNDLE_PATH}/junit_${TIMESTAMP}.xml"
else
    "${TEST_CMD[@]}"
fi

EXIT_CODE=$?

# Check test results
if [ $EXIT_CODE -eq 0 ]; then
    log_success "All tests passed!"
    log_info "Test results: $RESULT_BUNDLE"
    
    # Display code coverage summary if enabled
    if [ "$CODE_COVERAGE" = true ] && command -v xcrun &> /dev/null; then
        log_section "Code Coverage Summary"
        xcrun xccov view --report --only-targets "$RESULT_BUNDLE" 2>/dev/null || log_info "Code coverage report not available"
    fi
    
    exit 0
else
    log_error "Tests failed with exit code: $EXIT_CODE"
    log_info "Test results: $RESULT_BUNDLE"
    
    # Try to display test failures
    if command -v xcrun &> /dev/null; then
        log_section "Test Failures"
        xcrun xcresulttool get --path "$RESULT_BUNDLE" --format json 2>/dev/null | \
            grep -i "fail" || log_info "Could not extract failure details"
    fi
    
    exit $EXIT_CODE
fi
