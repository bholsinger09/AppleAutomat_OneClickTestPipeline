#!/bin/bash

###############################################################################
# Monitor Build Script
# Watch the latest pipeline log in real-time
###############################################################################

# Find the latest log file
LOGS_DIR="/Users/benh/Documents/AppleDevOpsAutomate/logs"
LATEST_LOG=$(ls -t ${LOGS_DIR}/pipeline_*.log 2>/dev/null | head -1)

if [ -z "$LATEST_LOG" ]; then
    echo "No pipeline logs found in ${LOGS_DIR}"
    exit 1
fi

echo "Monitoring: $LATEST_LOG"
echo "Press Ctrl+C to exit"
echo ""

# Tail the log file
tail -f "$LATEST_LOG"
