#!/bin/bash

###############################################################################
# macOS Build Script
# Handles building macOS applications with xcodebuild
###############################################################################

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/logger.sh"

# Default values
SCHEME=""
WORKSPACE=""
PROJECT=""
CONFIGURATION="Debug"
DESTINATION="platform=macOS"
DERIVED_DATA_PATH="./DerivedData"
VERBOSE=false
ARCHIVE=false
EXPORT_PATH="./Build"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
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
        --configuration)
            CONFIGURATION="$2"
            shift 2
            ;;
        --derived-data)
            DERIVED_DATA_PATH="$2"
            shift 2
            ;;
        --archive)
            ARCHIVE=true
            shift
            ;;
        --export-path)
            EXPORT_PATH="$2"
            shift 2
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
if [ -z "$SCHEME" ]; then
    log_error "Scheme is required. Use --scheme YourSchemeName"
    exit 1
fi

# Determine project or workspace
PROJECT_ARGS=()
if [ -n "$WORKSPACE" ]; then
    if [ ! -d "$WORKSPACE" ]; then
        log_error "Workspace not found: $WORKSPACE"
        exit 1
    fi
    PROJECT_ARGS+=("-workspace" "$WORKSPACE")
    log_info "Using workspace: $WORKSPACE"
elif [ -n "$PROJECT" ]; then
    if [ ! -d "$PROJECT" ]; then
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

# Create derived data directory
mkdir -p "$DERIVED_DATA_PATH"

# Check if xcpretty is available
XCPRETTY_AVAILABLE=false
if command -v xcpretty &> /dev/null; then
    XCPRETTY_AVAILABLE=true
    log_info "xcpretty detected - output will be formatted"
fi

# Build for macOS
build_for_macos() {
    log_info "Building for macOS..."
    log_info "Configuration: $CONFIGURATION"
    
    local BUILD_CMD=(
        xcodebuild
        "${PROJECT_ARGS[@]}"
        -scheme "$SCHEME"
        -configuration "$CONFIGURATION"
        -destination "$DESTINATION"
        -derivedDataPath "$DERIVED_DATA_PATH"
        build
    )
    
    if [ "$VERBOSE" = true ]; then
        log_info "Build command: ${BUILD_CMD[*]}"
    fi
    
    if [ "$XCPRETTY_AVAILABLE" = true ] && [ "$VERBOSE" = false ]; then
        "${BUILD_CMD[@]}" | xcpretty --color
    else
        "${BUILD_CMD[@]}"
    fi
    
    local EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        log_success "macOS build completed successfully!"
        return 0
    else
        log_error "macOS build failed with exit code: $EXIT_CODE"
        return $EXIT_CODE
    fi
}

# Archive for distribution
build_archive() {
    log_info "Creating macOS archive..."
    log_info "Configuration: $CONFIGURATION"
    
    local ARCHIVE_PATH="${EXPORT_PATH}/${SCHEME}.xcarchive"
    mkdir -p "$EXPORT_PATH"
    
    local ARCHIVE_CMD=(
        xcodebuild
        "${PROJECT_ARGS[@]}"
        -scheme "$SCHEME"
        -configuration "$CONFIGURATION"
        -derivedDataPath "$DERIVED_DATA_PATH"
        -archivePath "$ARCHIVE_PATH"
        archive
    )
    
    if [ "$VERBOSE" = true ]; then
        log_info "Archive command: ${ARCHIVE_CMD[*]}"
    fi
    
    if [ "$XCPRETTY_AVAILABLE" = true ] && [ "$VERBOSE" = false ]; then
        "${ARCHIVE_CMD[@]}" | xcpretty --color
    else
        "${ARCHIVE_CMD[@]}"
    fi
    
    local EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        log_success "macOS archive created successfully!"
        log_info "Archive location: $ARCHIVE_PATH"
        return 0
    else
        log_error "macOS archive failed with exit code: $EXIT_CODE"
        return $EXIT_CODE
    fi
}

# Main execution
log_section "macOS Build"

if [ "$ARCHIVE" = true ]; then
    build_archive
else
    build_for_macos
fi
