#!/bin/bash
################################################################################
# Performance Monitoring & Profiling Tool
# Tracks CPU/Memory usage, build times, and generates performance reports
################################################################################

set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Icons
CHECK="✓"
CROSS="✗"
ARROW="→"
CHART="📊"
CLOCK="⏱"
FIRE="🔥"

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORTS_DIR="$SCRIPT_DIR/../reports"
METRICS_DIR="$REPORTS_DIR/metrics"
LOGS_DIR="$REPORTS_DIR/logs"

# Create directories
mkdir -p "$METRICS_DIR" "$LOGS_DIR"

# Current timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
METRIC_FILE="$METRICS_DIR/build_${TIMESTAMP}.json"
MONITOR_LOG="$LOGS_DIR/monitor_${TIMESTAMP}.log"

echo -e "${BOLD}${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║         Performance Monitoring & Profiling Tool              ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Function to get current CPU usage
get_cpu_usage() {
    ps aux | awk '{sum+=$3} END {print sum}'
}

# Function to get current memory usage
get_memory_usage() {
    local mem_pressure=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print 100-$5}' | sed 's/%//')
    if [ -z "$mem_pressure" ]; then
        # Fallback method
        vm_stat | awk '/Pages active/ {active=$3} /Pages inactive/ {inactive=$3} /Pages wired/ {wired=$4} /Pages free/ {free=$3} END {gsub(/\./,"",active); gsub(/\./,"",inactive); gsub(/\./,"",wired); gsub(/\./,"",free); total=active+inactive+wired+free; used=active+inactive+wired; print (used/total)*100}'
    else
        echo "$mem_pressure"
    fi
}

# Function to monitor process
monitor_process() {
    local pid=$1
    local interval=${2:-2}
    local cpu_samples=()
    local mem_samples=()
    
    echo "Monitoring PID: $pid (sampling every ${interval}s)" | tee -a "$MONITOR_LOG"
    
    while kill -0 $pid 2>/dev/null; do
        local cpu=$(ps -p $pid -o %cpu= 2>/dev/null | awk '{print $1}')
        local mem=$(ps -p $pid -o %mem= 2>/dev/null | awk '{print $1}')
        local rss=$(ps -p $pid -o rss= 2>/dev/null | awk '{print $1}')
        
        if [ -n "$cpu" ]; then
            cpu_samples+=("$cpu")
            mem_samples+=("$mem")
            echo "$(date +%H:%M:%S) - CPU: ${cpu}% MEM: ${mem}% RSS: ${rss}KB" >> "$MONITOR_LOG"
        fi
        
        sleep "$interval"
    done
    
    # Calculate averages
    local avg_cpu=$(printf '%s\n' "${cpu_samples[@]}" | awk '{sum+=$1} END {print sum/NR}')
    local avg_mem=$(printf '%s\n' "${mem_samples[@]}" | awk '{sum+=$1} END {print sum/NR}')
    local max_cpu=$(printf '%s\n' "${cpu_samples[@]}" | sort -rn | head -1)
    local max_mem=$(printf '%s\n' "${mem_samples[@]}" | sort -rn | head -1)
    
    echo "$avg_cpu|$max_cpu|$avg_mem|$max_mem"
}

# Function to analyze build log
analyze_build_log() {
    local log_file=$1
    
    if [ ! -f "$log_file" ]; then
        echo -e "${RED}Log file not found: $log_file${NC}"
        return 1
    fi
    
    echo -e "${BOLD}${MAGENTA}Analyzing build log...${NC}"
    
    # Find slow compilation units (> 100ms)
    echo -e "\n${BOLD}Slow Compilation Units (>100ms):${NC}"
    grep -E "CompileSwift.*\([0-9]+\.[0-9]+ ms\)" "$log_file" 2>/dev/null | \
        sed 's/.*CompileSwift[^(]*(\([0-9.]*\) ms).*/\1/' | \
        awk '{if ($1 > 100) print}' | \
        sort -rn | head -10 | \
        while read time; do
            echo -e "${YELLOW}  ${FIRE} ${time}ms${NC}"
        done
    
    # Count warnings and errors
    local warnings=$(grep -c "warning:" "$log_file" 2>/dev/null || echo 0)
    local errors=$(grep -c "error:" "$log_file" 2>/dev/null || echo 0)
    
    echo -e "\n${BOLD}Build Issues:${NC}"
    echo -e "  ${YELLOW}Warnings: $warnings${NC}"
    echo -e "  ${RED}Errors: $errors${NC}"
    
    # Find most compiled files
    echo -e "\n${BOLD}Most Compiled Files:${NC}"
    grep "CompileSwift" "$log_file" 2>/dev/null | \
        grep -oE "[A-Za-z0-9_]+\.swift" | \
        sort | uniq -c | sort -rn | head -5 | \
        while read count file; do
            echo -e "  ${CYAN}$file${NC} - ${count} times"
        done
}

# Function to build and monitor
build_and_monitor() {
    local project_path=$1
    local scheme=$2
    local config=${3:-Debug}
    
    echo -e "${BOLD}${CYAN}Building: $scheme${NC}"
    echo -e "Project: $project_path"
    echo -e "Configuration: $config"
    echo ""
    
    local build_log="$LOGS_DIR/build_${TIMESTAMP}.log"
    local start_time=$(date +%s)
    
    # Start build in background
    local build_cmd="xcodebuild -project \"$project_path\" -scheme \"$scheme\" -configuration \"$config\" clean build"
    
    echo "Starting build..." | tee -a "$MONITOR_LOG"
    eval "$build_cmd" > "$build_log" 2>&1 &
    local build_pid=$!
    
    echo -e "${CYAN}${CLOCK} Monitoring build process...${NC}"
    
    # Monitor the build
    local metrics=$(monitor_process $build_pid 2)
    
    # Wait for build to complete
    wait $build_pid
    local build_status=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Parse metrics
    IFS='|' read -r avg_cpu max_cpu avg_mem max_mem <<< "$metrics"
    
    # Save metrics to JSON
    cat > "$METRIC_FILE" << EOF
{
  "timestamp": "$(date -r $start_time +"%Y-%m-%d %H:%M:%S")",
  "project": "$(basename "$project_path" .xcodeproj)",
  "scheme": "$scheme",
  "configuration": "$config",
  "duration_seconds": $duration,
  "build_status": $([ $build_status -eq 0 ] && echo "\"success\"" || echo "\"failed\""),
  "cpu_average": ${avg_cpu:-0},
  "cpu_peak": ${max_cpu:-0},
  "memory_average": ${avg_mem:-0},
  "memory_peak": ${max_mem:-0},
  "log_file": "$build_log",
  "monitor_log": "$MONITOR_LOG"
}
EOF
    
    # Display results
    echo ""
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Build Results${NC}"
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    
    if [ $build_status -eq 0 ]; then
        echo -e "${GREEN}${CHECK} Build Status: SUCCESS${NC}"
    else
        echo -e "${RED}${CROSS} Build Status: FAILED${NC}"
    fi
    
    echo -e "${CYAN}${CLOCK} Duration: ${duration}s ($(printf '%02d:%02d' $((duration/60)) $((duration%60))))${NC}"
    echo ""
    
    echo -e "${BOLD}Performance Metrics:${NC}"
    printf "%-20s %10s %10s\n" "Metric" "Average" "Peak"
    printf "%-20s %10s %10s\n" "────────────────────" "──────────" "──────────"
    printf "%-20s %9.1f%% %9.1f%%\n" "CPU Usage" "${avg_cpu:-0}" "${max_cpu:-0}"
    printf "%-20s %9.1f%% %9.1f%%\n" "Memory Usage" "${avg_mem:-0}" "${max_mem:-0}"
    
    # Analyze build log
    analyze_build_log "$build_log"
    
    echo ""
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Metrics saved to: $METRIC_FILE${NC}"
    echo -e "${GREEN}Build log saved to: $build_log${NC}"
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
}

# Function to generate performance report
generate_report() {
    echo -e "${BOLD}${MAGENTA}Generating Performance Report${NC}"
    echo ""
    
    if [ ! -d "$METRICS_DIR" ] || [ -z "$(ls -A $METRICS_DIR 2>/dev/null)" ]; then
        echo -e "${YELLOW}No metrics found. Run a monitored build first.${NC}"
        return 1
    fi
    
    local report_file="$REPORTS_DIR/performance_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "╔═══════════════════════════════════════════════════════════════╗"
        echo "║           Performance Analysis Report                        ║"
        echo "║           Generated: $(date +'%Y-%m-%d %H:%M:%S')                      ║"
        echo "╔═══════════════════════════════════════════════════════════════╗"
        echo ""
        
        echo "Build History (Last 10 Builds)"
        echo "════════════════════════════════════════════════════════════════"
        printf "%-20s %-15s %-10s %-10s %-10s\n" "Project" "Duration" "CPU Avg" "Mem Avg" "Status"
        printf "%-20s %-15s %-10s %-10s %-10s\n" "────────────────────" "─────────────" "────────" "────────" "──────────"
        
        for metric in $(ls -t "$METRICS_DIR"/*.json 2>/dev/null | head -10); do
            local project=$(jq -r '.project' "$metric" 2>/dev/null)
            local duration=$(jq -r '.duration_seconds' "$metric" 2>/dev/null)
            local cpu=$(jq -r '.cpu_average' "$metric" 2>/dev/null)
            local mem=$(jq -r '.memory_average' "$metric" 2>/dev/null)
            local status=$(jq -r '.build_status' "$metric" 2>/dev/null)
            
            printf "%-20s %-15s %-10s %-10s %-10s\n" \
                "${project:0:20}" \
                "${duration}s" \
                "$(printf '%.1f' $cpu)%" \
                "$(printf '%.1f' $mem)%" \
                "$status"
        done
        
        echo ""
        echo "Performance Trends"
        echo "════════════════════════════════════════════════════════════════"
        
        # Calculate averages
        local total_builds=$(ls "$METRICS_DIR"/*.json 2>/dev/null | wc -l | tr -d ' ')
        local avg_duration=$(jq -s 'map(.duration_seconds) | add / length' "$METRICS_DIR"/*.json 2>/dev/null)
        local avg_cpu=$(jq -s 'map(.cpu_average) | add / length' "$METRICS_DIR"/*.json 2>/dev/null)
        local avg_mem=$(jq -s 'map(.memory_average) | add / length' "$METRICS_DIR"/*.json 2>/dev/null)
        local success_rate=$(jq -s 'map(select(.build_status == "success")) | length' "$METRICS_DIR"/*.json 2>/dev/null)
        
        echo "Total Builds: $total_builds"
        echo "Average Build Time: $(printf '%.1f' $avg_duration)s"
        echo "Average CPU Usage: $(printf '%.1f' $avg_cpu)%"
        echo "Average Memory Usage: $(printf '%.1f' $avg_mem)%"
        echo "Success Rate: $success_rate/$total_builds ($(awk "BEGIN {print ($success_rate/$total_builds)*100}")%)"
        
        echo ""
        echo "Slowest Builds"
        echo "════════════════════════════════════════════════════════════════"
        
        for metric in $(jq -s 'sort_by(.duration_seconds) | reverse | .[0:5] | .[] | @json' "$METRICS_DIR"/*.json 2>/dev/null | head -5); do
            local project=$(echo "$metric" | jq -r '.project')
            local duration=$(echo "$metric" | jq -r '.duration_seconds')
            local timestamp=$(echo "$metric" | jq -r '.timestamp')
            echo "  • $project - ${duration}s ($timestamp)"
        done
        
    } | tee "$report_file"
    
    echo ""
    echo -e "${GREEN}${CHECK} Report saved to: $report_file${NC}"
}

# Main menu
show_menu() {
    echo -e "${BOLD}Select an option:${NC}"
    echo "  1. Monitor a build"
    echo "  2. Generate performance report"
    echo "  3. View recent metrics"
    echo "  4. Clean old metrics"
    echo "  0. Exit"
    echo ""
}

# Parse command line arguments
if [ $# -gt 0 ]; then
    case "$1" in
        build)
            if [ $# -lt 3 ]; then
                echo -e "${RED}Usage: $0 build <project_path> <scheme> [configuration]${NC}"
                exit 1
            fi
            build_and_monitor "$2" "$3" "${4:-Debug}"
            ;;
        report)
            generate_report
            ;;
        *)
            echo -e "${RED}Unknown command: $1${NC}"
            exit 1
            ;;
    esac
else
    # Interactive mode
    while true; do
        show_menu
        read -p "Enter choice: " choice
        
        case $choice in
            1)
                read -p "Project path (.xcodeproj): " project_path
                read -p "Scheme name: " scheme
                read -p "Configuration (Debug/Release) [Debug]: " config
                config=${config:-Debug}
                build_and_monitor "$project_path" "$scheme" "$config"
                ;;
            2)
                generate_report
                ;;
            3)
                echo -e "${BOLD}Recent Metrics:${NC}"
                ls -lht "$METRICS_DIR"/*.json 2>/dev/null | head -10 || echo "No metrics found"
                ;;
            4)
                read -p "Delete metrics older than how many days? " days
                find "$METRICS_DIR" -name "*.json" -mtime +${days} -delete
                echo -e "${GREEN}Old metrics cleaned${NC}"
                ;;
            0)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice${NC}"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
fi
