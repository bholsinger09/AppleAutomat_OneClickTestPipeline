#!/bin/bash

###############################################################################
# Cleanup Utility Script
# Handles cleanup of derived data, build artifacts, and logs
###############################################################################

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/logger.sh"

# Default paths
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-./DerivedData}"
BUILD_PATH="${BUILD_PATH:-./Build}"
LOGS_PATH="${LOGS_PATH:-./logs}"
TEST_RESULTS_PATH="${TEST_RESULTS_PATH:-./TestResults}"

# Cleanup options
CLEAN_DERIVED_DATA=false
CLEAN_BUILD=false
CLEAN_LOGS=false
CLEAN_TESTS=false
CLEAN_ALL=false
LOG_RETENTION_DAYS=${LOG_RETENTION_DAYS:-30}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --derived-data)
            CLEAN_DERIVED_DATA=true
            shift
            ;;
        --build)
            CLEAN_BUILD=true
            shift
            ;;
        --logs)
            CLEAN_LOGS=true
            shift
            ;;
        --tests)
            CLEAN_TESTS=true
            shift
            ;;
        --all)
            CLEAN_ALL=true
            shift
            ;;
        --log-retention)
            LOG_RETENTION_DAYS=$2
            shift 2
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# If no specific options, default to derived data only
if [ "$CLEAN_ALL" = false ] && [ "$CLEAN_DERIVED_DATA" = false ] && \
   [ "$CLEAN_BUILD" = false ] && [ "$CLEAN_LOGS" = false ] && [ "$CLEAN_TESTS" = false ]; then
    CLEAN_DERIVED_DATA=true
fi

# If --all is specified, clean everything
if [ "$CLEAN_ALL" = true ]; then
    CLEAN_DERIVED_DATA=true
    CLEAN_BUILD=true
    CLEAN_LOGS=true
    CLEAN_TESTS=true
fi

log_section "Cleanup"

# Clean derived data
if [ "$CLEAN_DERIVED_DATA" = true ]; then
    if [ -d "$DERIVED_DATA_PATH" ]; then
        log_progress "Cleaning derived data"
        rm -rf "$DERIVED_DATA_PATH"
        log_complete "Derived data cleaned"
    else
        log_info "No derived data to clean"
    fi
fi

# Clean build artifacts
if [ "$CLEAN_BUILD" = true ]; then
    if [ -d "$BUILD_PATH" ]; then
        log_progress "Cleaning build artifacts"
        rm -rf "$BUILD_PATH"
        log_complete "Build artifacts cleaned"
    else
        log_info "No build artifacts to clean"
    fi
fi

# Clean test results
if [ "$CLEAN_TESTS" = true ]; then
    if [ -d "$TEST_RESULTS_PATH" ]; then
        log_progress "Cleaning test results"
        rm -rf "$TEST_RESULTS_PATH"
        log_complete "Test results cleaned"
    else
        log_info "No test results to clean"
    fi
fi

# Clean old logs (keep logs newer than retention period)
if [ "$CLEAN_LOGS" = true ]; then
    if [ -d "$LOGS_PATH" ]; then
        log_progress "Cleaning logs older than ${LOG_RETENTION_DAYS} days"
        
        # Find and delete old log files
        DELETED_COUNT=$(find "$LOGS_PATH" -type f -name "*.log" -mtime +${LOG_RETENTION_DAYS} -delete -print | wc -l)
        
        if [ "$DELETED_COUNT" -gt 0 ]; then
            log_complete "Deleted ${DELETED_COUNT} old log file(s)"
        else
            log_info "No old logs to clean"
        fi
    else
        log_info "No logs directory to clean"
    fi
fi

# Clean Xcode caches (optional, more aggressive)
clean_xcode_caches() {
    log_warning "Cleaning Xcode caches (this may take a while)..."
    
    # Module cache
    if [ -d ~/Library/Developer/Xcode/DerivedData ]; then
        log_progress "Cleaning Xcode DerivedData"
        rm -rf ~/Library/Developer/Xcode/DerivedData
    fi
    
    # Archives
    if [ -d ~/Library/Developer/Xcode/Archives ]; then
        log_progress "Cleaning Xcode Archives"
        # Don't delete all archives, just old ones
        find ~/Library/Developer/Xcode/Archives -type d -name "*.xcarchive" -mtime +90 -delete
    fi
    
    # Device support
    if [ -d ~/Library/Developer/Xcode/iOS\ DeviceSupport ]; then
        log_progress "Cleaning old iOS DeviceSupport files"
        find ~/Library/Developer/Xcode/iOS\ DeviceSupport -type d -mtime +180 -delete
    fi
    
    log_complete "Xcode caches cleaned"
}

# Calculate space saved
calculate_space_saved() {
    local before=$1
    local after=$2
    local saved=$((before - after))
    local saved_mb=$((saved / 1024 / 1024))
    echo "${saved_mb} MB"
}

log_success "Cleanup completed!"
