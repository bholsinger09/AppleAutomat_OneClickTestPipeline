#!/bin/bash

###############################################################################
# One-Click iOS/macOS Build & Test Pipeline
# Main entry point for the automated build and test pipeline
###############################################################################

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SCRIPT_DIR}/scripts"
CONFIG_DIR="${SCRIPT_DIR}/config"
LOGS_DIR="${SCRIPT_DIR}/logs"

# Source utility scripts
source "${SCRIPTS_DIR}/logger.sh"
source "${SCRIPTS_DIR}/notifications.sh"

# Load environment variables if .env exists
if [ -f "${SCRIPT_DIR}/.env" ]; then
    set -a
    source "${SCRIPT_DIR}/.env"
    set +a
fi

# Default values
PLATFORM=""
WORKSPACE=""
PROJECT=""
SCHEME=""
CONFIGURATION="Debug"
CLEAN_BUILD=false
RUN_TESTS=true
TESTS_ONLY=false
SKIP_TESTS=false
VERBOSE=false
CONFIG_FILE="${CONFIG_DIR}/pipeline_config.yaml"

# Usage information
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

One-Click iOS/macOS Build & Test Pipeline

OPTIONS:
    -p, --platform PLATFORM       Platform to build (ios|macos) [REQUIRED]
    -s, --scheme SCHEME           Xcode scheme name [REQUIRED]
    -w, --workspace WORKSPACE     Path to .xcworkspace file
    -P, --project PROJECT         Path to .xcodeproj file
    -c, --configuration CONFIG    Build configuration (Debug|Release) [Default: Debug]
    --clean                       Clean build before building
    --tests-only                  Run tests only (skip build)
    --skip-tests                  Skip running tests
    --config FILE                 Path to configuration file
    -v, --verbose                 Verbose output
    -h, --help                    Show this help message

EXAMPLES:
    # Build and test iOS app
    $0 --platform ios --scheme "MyApp"
    
    # Build macOS app in Release configuration
    $0 --platform macos --scheme "MyApp" --configuration Release
    
    # Clean build for iOS
    $0 --platform ios --scheme "MyApp" --clean
    
    # Run tests only
    $0 --platform ios --scheme "MyApp" --tests-only

EOF
    exit 1
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--platform)
                PLATFORM="$2"
                shift 2
                ;;
            -s|--scheme)
                SCHEME="$2"
                shift 2
                ;;
            -w|--workspace)
                WORKSPACE="$2"
                shift 2
                ;;
            -P|--project)
                PROJECT="$2"
                shift 2
                ;;
            -c|--configuration)
                CONFIGURATION="$2"
                shift 2
                ;;
            --clean)
                CLEAN_BUILD=true
                shift
                ;;
            --tests-only)
                TESTS_ONLY=true
                shift
                ;;
            --skip-tests)
                SKIP_TESTS=true
                shift
                ;;
            --config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                ;;
        esac
    done
}

# Validate required arguments
validate_args() {
    if [ -z "$PLATFORM" ]; then
        log_error "Platform is required. Use --platform ios or --platform macos"
        usage
    fi
    
    if [ "$PLATFORM" != "ios" ] && [ "$PLATFORM" != "macos" ]; then
        log_error "Invalid platform: $PLATFORM. Must be 'ios' or 'macos'"
        usage
    fi
    
    if [ -z "$SCHEME" ]; then
        log_error "Scheme is required. Use --scheme YourSchemeName"
        usage
    fi
    
    if [ "$TESTS_ONLY" = true ] && [ "$SKIP_TESTS" = true ]; then
        log_error "Cannot use --tests-only and --skip-tests together"
        exit 1
    fi
}

# Initialize logging
init_logging() {
    mkdir -p "$LOGS_DIR"
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    LOG_FILE="${LOGS_DIR}/pipeline_${TIMESTAMP}.log"
    
    log_info "Logging to: $LOG_FILE"
    exec > >(tee -a "$LOG_FILE")
    exec 2>&1
}

# Load configuration from YAML file
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        log_info "Loading configuration from: $CONFIG_FILE"
        
        # Extract values from YAML (basic parsing)
        if [ -z "$WORKSPACE" ]; then
            WORKSPACE=$(grep -E '^\s*workspace:' "$CONFIG_FILE" | sed 's/.*: *//' | tr -d '"' | envsubst || echo "")
        fi
        
        if [ -z "$CONFIGURATION" ] || [ "$CONFIGURATION" = "Debug" ]; then
            CONFIG_FROM_FILE=$(grep -E '^\s*configuration:' "$CONFIG_FILE" | sed 's/.*: *//' | tr -d '"' | envsubst || echo "")
            if [ -n "$CONFIG_FROM_FILE" ]; then
                CONFIGURATION="$CONFIG_FROM_FILE"
            fi
        fi
    else
        log_warning "Configuration file not found: $CONFIG_FILE"
    fi
}

# Display pipeline configuration
display_config() {
    log_section "Pipeline Configuration"
    echo "Platform:        $PLATFORM"
    echo "Scheme:          $SCHEME"
    echo "Configuration:   $CONFIGURATION"
    echo "Workspace:       ${WORKSPACE:-Not specified}"
    echo "Project:         ${PROJECT:-Not specified}"
    echo "Clean Build:     $CLEAN_BUILD"
    echo "Run Tests:       $([ "$SKIP_TESTS" = false ] && echo "Yes" || echo "No")"
    echo "Tests Only:      $TESTS_ONLY"
    echo ""
}

# Run cleanup if requested
run_cleanup() {
    if [ "$CLEAN_BUILD" = true ]; then
        log_info "Running cleanup..."
        if [ -f "${SCRIPTS_DIR}/cleanup.sh" ]; then
            bash "${SCRIPTS_DIR}/cleanup.sh"
        else
            log_warning "Cleanup script not found, skipping..."
        fi
    fi
}

# Run build
run_build() {
    log_section "Building $PLATFORM Application"
    
    local BUILD_SCRIPT=""
    case "$PLATFORM" in
        ios)
            BUILD_SCRIPT="${SCRIPTS_DIR}/build_ios.sh"
            ;;
        macos)
            BUILD_SCRIPT="${SCRIPTS_DIR}/build_macos.sh"
            ;;
    esac
    
    if [ ! -f "$BUILD_SCRIPT" ]; then
        log_error "Build script not found: $BUILD_SCRIPT"
        return 1
    fi
    
    # Prepare build arguments
    local BUILD_ARGS=("--scheme" "$SCHEME" "--configuration" "$CONFIGURATION")
    
    # Auto-detect project/workspace if PROJECT_PATH is set
    if [ -z "$WORKSPACE" ] && [ -z "$PROJECT" ] && [ -n "${PROJECT_PATH:-}" ]; then
        if [ -d "$PROJECT_PATH" ]; then
            # Look for workspace first, then project
            local FOUND_WORKSPACE=$(find "$PROJECT_PATH" -maxdepth 1 -name "*.xcworkspace" | head -1)
            local FOUND_PROJECT=$(find "$PROJECT_PATH" -maxdepth 1 -name "*.xcodeproj" | head -1)
            
            if [ -n "$FOUND_WORKSPACE" ]; then
                WORKSPACE="$FOUND_WORKSPACE"
                log_info "Auto-detected workspace from PROJECT_PATH: $WORKSPACE"
            elif [ -n "$FOUND_PROJECT" ]; then
                PROJECT="$FOUND_PROJECT"
                log_info "Auto-detected project from PROJECT_PATH: $PROJECT"
            fi
        fi
    fi
    
    if [ -n "$WORKSPACE" ]; then
        BUILD_ARGS+=("--workspace" "$WORKSPACE")
    elif [ -n "$PROJECT" ]; then
        BUILD_ARGS+=("--project" "$PROJECT")
    fi
    
    if [ "$VERBOSE" = true ]; then
        BUILD_ARGS+=("--verbose")
    fi
    
    # Run the build
    bash "$BUILD_SCRIPT" "${BUILD_ARGS[@]}"
    return $?
}

# Run tests
run_tests() {
    log_section "Running Tests"
    
    local TEST_SCRIPT="${SCRIPTS_DIR}/run_tests.sh"
    
    if [ ! -f "$TEST_SCRIPT" ]; then
        log_error "Test script not found: $TEST_SCRIPT"
        return 1
    fi
    
    # Prepare test arguments
    local TEST_ARGS=("--platform" "$PLATFORM" "--scheme" "$SCHEME")
    
    # Auto-detect project/workspace if PROJECT_PATH is set (same as build)
    if [ -z "$WORKSPACE" ] && [ -z "$PROJECT" ] && [ -n "${PROJECT_PATH:-}" ]; then
        if [ -d "$PROJECT_PATH" ]; then
            local FOUND_WORKSPACE=$(find "$PROJECT_PATH" -maxdepth 1 -name "*.xcworkspace" | head -1)
            local FOUND_PROJECT=$(find "$PROJECT_PATH" -maxdepth 1 -name "*.xcodeproj" | head -1)
            
            if [ -n "$FOUND_WORKSPACE" ]; then
                WORKSPACE="$FOUND_WORKSPACE"
            elif [ -n "$FOUND_PROJECT" ]; then
                PROJECT="$FOUND_PROJECT"
            fi
        fi
    fi
    
    if [ -n "$WORKSPACE" ]; then
        TEST_ARGS+=("--workspace" "$WORKSPACE")
    elif [ -n "$PROJECT" ]; then
        TEST_ARGS+=("--project" "$PROJECT")
    fi
    
    if [ "$VERBOSE" = true ]; then
        TEST_ARGS+=("--verbose")
    fi
    
    # Run the tests
    bash "$TEST_SCRIPT" "${TEST_ARGS[@]}"
    return $?
}

# Main pipeline execution
main() {
    local START_TIME=$(date +%s)
    
    # Parse and validate arguments
    parse_args "$@"
    validate_args
    
    # Initialize
    init_logging
    load_config
    
    # Display configuration
    log_header "One-Click Build & Test Pipeline"
    display_config
    
    # Send start notification
    send_notification "Pipeline started for $PLATFORM - $SCHEME" "info"
    
    local BUILD_SUCCESS=true
    local TEST_SUCCESS=true
    
    # Run cleanup if needed
    run_cleanup
    
    # Run build (unless tests-only mode)
    if [ "$TESTS_ONLY" = false ]; then
        if run_build; then
            log_success "Build completed successfully!"
        else
            log_error "Build failed!"
            BUILD_SUCCESS=false
        fi
    fi
    
    # Run tests (unless skipped or build failed)
    if [ "$SKIP_TESTS" = false ] && [ "$BUILD_SUCCESS" = true ]; then
        if run_tests; then
            log_success "Tests completed successfully!"
        else
            log_error "Tests failed!"
            TEST_SUCCESS=false
        fi
    fi
    
    # Calculate duration
    local END_TIME=$(date +%s)
    local DURATION=$((END_TIME - START_TIME))
    
    # Final status
    log_section "Pipeline Summary"
    echo "Duration: ${DURATION}s"
    
    if [ "$BUILD_SUCCESS" = true ] && [ "$TEST_SUCCESS" = true ]; then
        log_success "✅ Pipeline completed successfully!"
        send_notification "Pipeline succeeded for $PLATFORM - $SCHEME (${DURATION}s)" "success"
        exit 0
    else
        log_error "❌ Pipeline failed!"
        send_notification "Pipeline failed for $PLATFORM - $SCHEME (${DURATION}s)" "error"
        exit 1
    fi
}

# Run main function
main "$@"
