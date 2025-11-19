#!/bin/bash
################################################################################
# Mac System Monitor
# Comprehensive monitoring for macOS system health and performance
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
WARNING="⚠"
INFO="ℹ"
CHART="📊"
CPU="🖥"
MEM="💾"
DISK="💿"
NET="🌐"
BATTERY="🔋"
TEMP="🌡"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONITOR_DIR="$SCRIPT_DIR/../reports/system-monitor"
mkdir -p "$MONITOR_DIR"

echo -e "${BOLD}${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║              Mac System Monitor & Health Check               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Function to get CPU info
get_cpu_info() {
    echo -e "${BOLD}${MAGENTA}${CPU} CPU Information${NC}"
    
    local cpu_brand=$(sysctl -n machdep.cpu.brand_string)
    local cpu_cores=$(sysctl -n hw.ncpu)
    local cpu_physical=$(sysctl -n hw.physicalcpu)
    local cpu_freq=$(sysctl -n hw.cpufrequency 2>/dev/null | awk '{print $1/1000000000}')
    
    echo -e "${CYAN}Model:${NC} $cpu_brand"
    echo -e "${CYAN}Physical Cores:${NC} $cpu_physical"
    echo -e "${CYAN}Logical Cores:${NC} $cpu_cores"
    
    # CPU Usage
    local cpu_usage=$(ps aux | awk '{sum+=$3} END {print sum}')
    echo -e "${CYAN}Current Usage:${NC} $(printf '%.1f' $cpu_usage)%"
    
    # Top CPU processes
    echo -e "\n${BOLD}Top CPU Consumers:${NC}"
    ps aux | sort -rk 3 | head -6 | tail -5 | awk '{printf "  %-30s %6.1f%%\n", substr($11,1,30), $3}'
}

# Function to get memory info
get_memory_info() {
    echo -e "\n${BOLD}${MAGENTA}${MEM} Memory Information${NC}"
    
    local total_mem=$(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024}')
    
    # Get memory pressure
    local mem_stats=$(vm_stat)
    local pages_free=$(echo "$mem_stats" | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    local pages_active=$(echo "$mem_stats" | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
    local pages_inactive=$(echo "$mem_stats" | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
    local pages_wired=$(echo "$mem_stats" | grep "Pages wired down" | awk '{print $4}' | sed 's/\.//')
    local pages_compressed=$(echo "$mem_stats" | grep "Pages stored in compressor" | awk '{print $5}' | sed 's/\.//')
    
    local page_size=$(pagesize)
    local free_gb=$(echo "$pages_free $page_size" | awk '{print ($1*$2)/1024/1024/1024}')
    local used_gb=$(echo "$pages_active $pages_wired $page_size" | awk '{print (($1+$2)*$3)/1024/1024/1024}')
    local compressed_gb=$(echo "$pages_compressed $page_size" | awk '{print ($1*$2)/1024/1024/1024}')
    
    echo -e "${CYAN}Total:${NC} $(printf '%.1f' $total_mem) GB"
    echo -e "${CYAN}Used:${NC} $(printf '%.1f' $used_gb) GB"
    echo -e "${CYAN}Free:${NC} $(printf '%.1f' $free_gb) GB"
    echo -e "${CYAN}Compressed:${NC} $(printf '%.1f' $compressed_gb) GB"
    
    # Memory pressure
    local pressure=$(memory_pressure 2>/dev/null | grep "System-wide memory free percentage" | awk '{print $5}' | sed 's/%//')
    if [ -n "$pressure" ]; then
        local used_percent=$(echo "100 - $pressure" | bc)
        echo -e "${CYAN}Memory Pressure:${NC} ${used_percent}%"
        
        if (( $(echo "$used_percent > 80" | bc -l) )); then
            echo -e "${RED}${WARNING} High memory pressure detected${NC}"
        fi
    fi
    
    # Top memory processes
    echo -e "\n${BOLD}Top Memory Consumers:${NC}"
    ps aux | sort -rk 4 | head -6 | tail -5 | awk '{printf "  %-30s %6.1f%%\n", substr($11,1,30), $4}'
}

# Function to get disk info
get_disk_info() {
    echo -e "\n${BOLD}${MAGENTA}${DISK} Disk Information${NC}"
    
    # Main disk
    local disk_info=$(df -h / | tail -1)
    local total=$(echo "$disk_info" | awk '{print $2}')
    local used=$(echo "$disk_info" | awk '{print $3}')
    local avail=$(echo "$disk_info" | awk '{print $4}')
    local percent=$(echo "$disk_info" | awk '{print $5}')
    
    echo -e "${CYAN}Total:${NC} $total"
    echo -e "${CYAN}Used:${NC} $used ($percent)"
    echo -e "${CYAN}Available:${NC} $avail"
    
    if (( $(echo "$percent" | sed 's/%//' ) > 90 )); then
        echo -e "${RED}${WARNING} Low disk space!${NC}"
    fi
    
    # Disk I/O
    echo -e "\n${BOLD}Disk Activity:${NC}"
    iostat -d -c 2 disk0 2>/dev/null | tail -1 | awk '{printf "  Read: %s KB/t   Write: %s KB/t\n", $3, $4}'
    
    # All volumes
    echo -e "\n${BOLD}All Volumes:${NC}"
    df -h | grep -E "^/dev/" | awk '{printf "  %-20s %8s %8s %8s %6s\n", $1, $2, $3, $4, $5}'
}

# Function to get network info
get_network_info() {
    echo -e "\n${BOLD}${MAGENTA}${NET} Network Information${NC}"
    
    # Active interfaces
    local active_if=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
    
    if [ -n "$active_if" ]; then
        echo -e "${CYAN}Active Interface:${NC} $active_if"
        
        # IP addresses
        local ip=$(ipconfig getifaddr "$active_if" 2>/dev/null)
        echo -e "${CYAN}IP Address:${NC} ${ip:-N/A}"
        
        # Network speed test (simple)
        local netstat_info=$(netstat -ib | grep "$active_if" | head -1)
        echo -e "${CYAN}Packets In/Out:${NC} $(echo "$netstat_info" | awk '{print $5 "/" $8}')"
    fi
    
    # DNS servers
    echo -e "\n${BOLD}DNS Servers:${NC}"
    scutil --dns | grep "nameserver" | head -3 | awk '{print "  " $3}'
    
    # Open connections
    local connections=$(netstat -an | grep ESTABLISHED | wc -l | tr -d ' ')
    echo -e "\n${CYAN}Active Connections:${NC} $connections"
}

# Function to get battery info
get_battery_info() {
    echo -e "\n${BOLD}${MAGENTA}${BATTERY} Battery Information${NC}"
    
    local battery_info=$(pmset -g batt 2>/dev/null)
    
    if echo "$battery_info" | grep -q "InternalBattery"; then
        local percentage=$(echo "$battery_info" | grep -o "[0-9]*%" | head -1)
        local status=$(echo "$battery_info" | grep -o "charging\|discharging\|charged" | head -1)
        local time=$(echo "$battery_info" | grep -o "[0-9:]*remaining" | head -1)
        
        echo -e "${CYAN}Charge:${NC} $percentage"
        echo -e "${CYAN}Status:${NC} $status"
        [ -n "$time" ] && echo -e "${CYAN}Time:${NC} $time"
        
        # Battery health
        local health=$(system_profiler SPPowerDataType | grep "Condition" | awk '{print $2}')
        echo -e "${CYAN}Health:${NC} ${health:-Unknown}"
        
        # Cycle count
        local cycles=$(system_profiler SPPowerDataType | grep "Cycle Count" | awk '{print $3}')
        echo -e "${CYAN}Cycle Count:${NC} ${cycles:-Unknown}"
    else
        echo -e "${YELLOW}No battery detected (Desktop Mac)${NC}"
    fi
}

# Function to get temperature info
get_temperature_info() {
    echo -e "\n${BOLD}${MAGENTA}${TEMP} System Temperature${NC}"
    
    # Note: This requires sudo or special tools for accurate readings
    # Using powermetrics as alternative
    if command -v osx-cpu-temp >/dev/null 2>&1; then
        local temp=$(osx-cpu-temp)
        echo -e "${CYAN}CPU Temperature:${NC} $temp"
    else
        echo -e "${YELLOW}Install 'osx-cpu-temp' for temperature monitoring:${NC}"
        echo -e "  ${CYAN}brew install osx-cpu-temp${NC}"
    fi
}

# Function to get system uptime
get_uptime_info() {
    echo -e "\n${BOLD}${MAGENTA}⏰ System Uptime${NC}"
    
    local uptime_info=$(uptime | awk '{print $3, $4}' | sed 's/,//')
    echo -e "${CYAN}Uptime:${NC} $uptime_info"
    
    local boot_time=$(sysctl -n kern.boottime | awk '{print $4}' | sed 's/,//')
    local boot_date=$(date -r $boot_time "+%Y-%m-%d %H:%M:%S")
    echo -e "${CYAN}Last Boot:${NC} $boot_date"
}

# Function to get macOS info
get_macos_info() {
    echo -e "\n${BOLD}${MAGENTA}🍎 macOS Information${NC}"
    
    local os_version=$(sw_vers -productVersion)
    local os_build=$(sw_vers -buildVersion)
    local os_name=$(sw_vers -productName)
    
    echo -e "${CYAN}Version:${NC} $os_name $os_version"
    echo -e "${CYAN}Build:${NC} $os_build"
    
    # Kernel
    local kernel=$(uname -r)
    echo -e "${CYAN}Kernel:${NC} $kernel"
    
    # Architecture
    local arch=$(uname -m)
    echo -e "${CYAN}Architecture:${NC} $arch"
}

# Function to generate system report
generate_report() {
    local report_file="$MONITOR_DIR/system_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "╔═══════════════════════════════════════════════════════════════╗"
        echo "║              Mac System Health Report                        ║"
        echo "║              Generated: $(date +'%Y-%m-%d %H:%M:%S')                      ║"
        echo "╚═══════════════════════════════════════════════════════════════╝"
        echo ""
        
        get_macos_info
        get_uptime_info
        get_cpu_info
        get_memory_info
        get_disk_info
        get_network_info
        get_battery_info
        get_temperature_info
        
    } | tee "$report_file"
    
    echo ""
    echo -e "${GREEN}${CHECK} Report saved to: $report_file${NC}"
}

# Function for continuous monitoring
continuous_monitor() {
    local interval=${1:-5}
    
    echo -e "${BOLD}${CYAN}Starting continuous monitoring (${interval}s interval)${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    echo ""
    
    while true; do
        clear
        echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${CYAN}║              Real-Time System Monitor                        ║${NC}"
        echo -e "${BOLD}${CYAN}║              $(date +'%Y-%m-%d %H:%M:%S')                                ║${NC}"
        echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
        
        get_cpu_info
        get_memory_info
        get_disk_info
        get_network_info
        
        sleep "$interval"
    done
}

# Main menu
show_menu() {
    echo -e "${BOLD}Select monitoring option:${NC}"
    echo "  1. Quick System Overview"
    echo "  2. Generate Detailed Report"
    echo "  3. Continuous Monitor (5s)"
    echo "  4. CPU Info"
    echo "  5. Memory Info"
    echo "  6. Disk Info"
    echo "  7. Network Info"
    echo "  8. Battery Info"
    echo "  0. Exit"
    echo ""
}

# Parse arguments
if [ $# -gt 0 ]; then
    case "$1" in
        quick)
            get_macos_info
            get_cpu_info
            get_memory_info
            get_disk_info
            ;;
        report)
            generate_report
            ;;
        monitor)
            continuous_monitor "${2:-5}"
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
                get_macos_info
                get_cpu_info
                get_memory_info
                get_disk_info
                ;;
            2)
                generate_report
                ;;
            3)
                continuous_monitor 5
                ;;
            4)
                get_cpu_info
                ;;
            5)
                get_memory_info
                ;;
            6)
                get_disk_info
                ;;
            7)
                get_network_info
                ;;
            8)
                get_battery_info
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
