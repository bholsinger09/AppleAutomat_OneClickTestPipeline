#!/bin/bash

###############################################################################
# Notification System
# Sends notifications via Slack, email, or other channels
###############################################################################

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables if .env exists
if [ -f "${SCRIPT_DIR}/../.env" ]; then
    export $(grep -v '^#' "${SCRIPT_DIR}/../.env" | xargs)
fi

# Notification configuration
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
NOTIFICATION_EMAIL="${NOTIFICATION_EMAIL:-}"
SLACK_CHANNEL="${SLACK_CHANNEL:-#devops}"

# Send Slack notification
send_slack_notification() {
    local message=$1
    local level=${2:-info}  # info, success, warning, error
    
    if [ -z "$SLACK_WEBHOOK_URL" ]; then
        return 0
    fi
    
    # Determine color based on level
    local color="good"
    local emoji="ℹ️"
    case $level in
        success)
            color="good"
            emoji="✅"
            ;;
        warning)
            color="warning"
            emoji="⚠️"
            ;;
        error)
            color="danger"
            emoji="❌"
            ;;
        info)
            color="#439FE0"
            emoji="ℹ️"
            ;;
    esac
    
    # Build JSON payload
    local payload=$(cat <<EOF
{
    "channel": "${SLACK_CHANNEL}",
    "username": "Build Pipeline",
    "icon_emoji": ":rocket:",
    "attachments": [{
        "color": "${color}",
        "text": "${emoji} ${message}",
        "footer": "Apple Automat Pipeline",
        "ts": $(date +%s)
    }]
}
EOF
)
    
    # Send notification
    curl -X POST "${SLACK_WEBHOOK_URL}" \
        -H 'Content-Type: application/json' \
        -d "${payload}" \
        --silent --show-error > /dev/null 2>&1 || true
}

# Send email notification (requires mail command)
send_email_notification() {
    local subject=$1
    local message=$2
    
    if [ -z "$NOTIFICATION_EMAIL" ]; then
        return 0
    fi
    
    if ! command -v mail &> /dev/null; then
        return 0
    fi
    
    echo "${message}" | mail -s "${subject}" "${NOTIFICATION_EMAIL}" 2>/dev/null || true
}

# Send macOS notification (using osascript)
send_macos_notification() {
    local title=$1
    local message=$2
    local sound=${3:-default}
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e "display notification \"${message}\" with title \"${title}\" sound name \"${sound}\"" 2>/dev/null || true
    fi
}

# Main notification function (sends to all configured channels)
send_notification() {
    local message=$1
    local level=${2:-info}
    
    # Send to Slack
    send_slack_notification "$message" "$level"
    
    # Send email for errors and success
    if [ "$level" = "error" ] || [ "$level" = "success" ]; then
        send_email_notification "Pipeline ${level}: Apple Automat" "$message"
    fi
    
    # Send macOS notification
    local sound="default"
    case $level in
        success)
            sound="Glass"
            ;;
        error)
            sound="Basso"
            ;;
        warning)
            sound="Ping"
            ;;
    esac
    send_macos_notification "Apple Automat Pipeline" "$message" "$sound"
}

# Export functions
export -f send_slack_notification
export -f send_email_notification
export -f send_macos_notification
export -f send_notification
