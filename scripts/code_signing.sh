#!/bin/bash

###############################################################################
# Code Signing Setup Script
# Handles code signing certificate and provisioning profile setup
###############################################################################

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/logger.sh"

# Load environment variables if .env exists
if [ -f "${SCRIPT_DIR}/../.env" ]; then
    export $(grep -v '^#' "${SCRIPT_DIR}/../.env" | xargs)
fi

# Configuration
KEYCHAIN_NAME="${KEYCHAIN_NAME:-build.keychain}"
KEYCHAIN_PASSWORD="${KEYCHAIN_PASSWORD:-}"
CERTIFICATE_PATH="${CERTIFICATE_PATH:-}"
CERTIFICATE_PASSWORD="${CERTIFICATE_PASSWORD:-}"
PROVISIONING_PROFILE_PATH="${PROVISIONING_PROFILE_PATH:-}"

# Actions
ACTION="setup"  # setup, cleanup, verify

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --setup)
            ACTION="setup"
            shift
            ;;
        --cleanup)
            ACTION="cleanup"
            shift
            ;;
        --verify)
            ACTION="verify"
            shift
            ;;
        --certificate)
            CERTIFICATE_PATH="$2"
            shift 2
            ;;
        --certificate-password)
            CERTIFICATE_PASSWORD="$2"
            shift 2
            ;;
        --provisioning-profile)
            PROVISIONING_PROFILE_PATH="$2"
            shift 2
            ;;
        --keychain-password)
            KEYCHAIN_PASSWORD="$2"
            shift 2
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Setup code signing
setup_code_signing() {
    log_section "Setting up Code Signing"
    
    # Generate keychain password if not provided
    if [ -z "$KEYCHAIN_PASSWORD" ]; then
        KEYCHAIN_PASSWORD=$(openssl rand -base64 32)
    fi
    
    # Create keychain
    log_progress "Creating keychain: ${KEYCHAIN_NAME}"
    security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME" || true
    
    # Set keychain settings
    security set-keychain-settings -lut 21600 "$KEYCHAIN_NAME"
    security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
    
    # Add keychain to search list
    security list-keychains -d user -s "$KEYCHAIN_NAME" $(security list-keychains -d user | sed s/\"//g)
    log_complete "Keychain created"
    
    # Import certificate if provided
    if [ -n "$CERTIFICATE_PATH" ] && [ -f "$CERTIFICATE_PATH" ]; then
        log_progress "Importing certificate"
        security import "$CERTIFICATE_PATH" \
            -P "$CERTIFICATE_PASSWORD" \
            -A \
            -t cert \
            -f pkcs12 \
            -k "$KEYCHAIN_NAME"
        
        # Set partition list to avoid permission dialogs
        security set-key-partition-list \
            -S apple-tool:,apple:,codesign: \
            -s \
            -k "$KEYCHAIN_PASSWORD" \
            "$KEYCHAIN_NAME" > /dev/null 2>&1 || true
        
        log_complete "Certificate imported"
    fi
    
    # Install provisioning profile if provided
    if [ -n "$PROVISIONING_PROFILE_PATH" ] && [ -f "$PROVISIONING_PROFILE_PATH" ]; then
        log_progress "Installing provisioning profile"
        
        PROFILE_DIR="$HOME/Library/MobileDevice/Provisioning Profiles"
        mkdir -p "$PROFILE_DIR"
        
        # Get UUID from provisioning profile
        PROFILE_UUID=$(/usr/libexec/PlistBuddy -c "Print UUID" /dev/stdin <<< $(security cms -D -i "$PROVISIONING_PROFILE_PATH"))
        
        cp "$PROVISIONING_PROFILE_PATH" "$PROFILE_DIR/${PROFILE_UUID}.mobileprovision"
        log_complete "Provisioning profile installed: $PROFILE_UUID"
    fi
    
    log_success "Code signing setup completed!"
}

# Cleanup code signing
cleanup_code_signing() {
    log_section "Cleaning up Code Signing"
    
    # Delete keychain
    if security list-keychains | grep -q "$KEYCHAIN_NAME"; then
        log_progress "Deleting keychain: ${KEYCHAIN_NAME}"
        security delete-keychain "$KEYCHAIN_NAME" || true
        log_complete "Keychain deleted"
    else
        log_info "Keychain not found: ${KEYCHAIN_NAME}"
    fi
    
    log_success "Code signing cleanup completed!"
}

# Verify code signing setup
verify_code_signing() {
    log_section "Verifying Code Signing"
    
    # List available identities
    log_info "Available signing identities:"
    security find-identity -v -p codesigning
    
    # List installed provisioning profiles
    log_info "Installed provisioning profiles:"
    PROFILE_DIR="$HOME/Library/MobileDevice/Provisioning Profiles"
    if [ -d "$PROFILE_DIR" ]; then
        ls -1 "$PROFILE_DIR" | while read -r profile; do
            UUID=$(/usr/libexec/PlistBuddy -c "Print UUID" /dev/stdin <<< $(security cms -D -i "$PROFILE_DIR/$profile"))
            NAME=$(/usr/libexec/PlistBuddy -c "Print Name" /dev/stdin <<< $(security cms -D -i "$PROFILE_DIR/$profile"))
            echo "  - $NAME ($UUID)"
        done
    else
        log_warning "No provisioning profiles found"
    fi
    
    log_success "Verification completed!"
}

# Main execution
case $ACTION in
    setup)
        setup_code_signing
        ;;
    cleanup)
        cleanup_code_signing
        ;;
    verify)
        verify_code_signing
        ;;
    *)
        log_error "Invalid action: $ACTION"
        exit 1
        ;;
esac
