#!/bin/bash

###############################################################################
# Logger Utility Script
# Provides colored logging functions for better output readability
###############################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Formatting
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'

# Log levels
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARNING=2
LOG_LEVEL_ERROR=3

# Current log level (can be overridden by environment variable)
CURRENT_LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

# Timestamp format
timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

# Log with timestamp and color
log_with_color() {
    local color=$1
    local level=$2
    local message=$3
    echo -e "${color}[$(timestamp)] [${level}]${NC} ${message}"
}

# Debug log (lowest priority)
log_debug() {
    if [ $CURRENT_LOG_LEVEL -le $LOG_LEVEL_DEBUG ]; then
        log_with_color "$DIM$WHITE" "DEBUG" "$1"
    fi
}

# Info log (normal priority)
log_info() {
    if [ $CURRENT_LOG_LEVEL -le $LOG_LEVEL_INFO ]; then
        log_with_color "$BLUE" "INFO" "$1"
    fi
}

# Warning log (medium priority)
log_warning() {
    if [ $CURRENT_LOG_LEVEL -le $LOG_LEVEL_WARNING ]; then
        log_with_color "$YELLOW" "WARN" "$1"
    fi
}

# Error log (highest priority)
log_error() {
    if [ $CURRENT_LOG_LEVEL -le $LOG_LEVEL_ERROR ]; then
        log_with_color "$RED" "ERROR" "$1" >&2
    fi
}

# Success log (special case)
log_success() {
    log_with_color "$GREEN" "SUCCESS" "$1"
}

# Section header
log_section() {
    local message=$1
    local length=${#message}
    local separator=$(printf '=%.0s' $(seq 1 $((length + 4))))
    echo ""
    echo -e "${CYAN}${separator}${NC}"
    echo -e "${CYAN}  ${message}${NC}"
    echo -e "${CYAN}${separator}${NC}"
    echo ""
}

# Main header (larger)
log_header() {
    local message=$1
    local length=${#message}
    local separator=$(printf '=%.0s' $(seq 1 $((length + 4))))
    echo ""
    echo -e "${BOLD}${MAGENTA}${separator}${NC}"
    echo -e "${BOLD}${MAGENTA}  ${message}${NC}"
    echo -e "${BOLD}${MAGENTA}${separator}${NC}"
    echo ""
}

# Progress indicator
log_progress() {
    local message=$1
    echo -e "${CYAN}⏳${NC} ${message}..."
}

# Completion indicator
log_complete() {
    local message=$1
    echo -e "${GREEN}✓${NC} ${message}"
}

# Failure indicator
log_fail() {
    local message=$1
    echo -e "${RED}✗${NC} ${message}" >&2
}

# Step indicator (for multi-step processes)
log_step() {
    local step=$1
    local message=$2
    echo -e "${BOLD}${WHITE}[Step ${step}]${NC} ${message}"
}

# Command output (dimmed)
log_command() {
    local command=$1
    echo -e "${DIM}$ ${command}${NC}"
}

# Divider
log_divider() {
    echo -e "${DIM}$(printf -- '-%.0s' {1..80})${NC}"
}

# Export functions so they can be used by other scripts
export -f timestamp
export -f log_with_color
export -f log_debug
export -f log_info
export -f log_warning
export -f log_error
export -f log_success
export -f log_section
export -f log_header
export -f log_progress
export -f log_complete
export -f log_fail
export -f log_step
export -f log_command
export -f log_divider
