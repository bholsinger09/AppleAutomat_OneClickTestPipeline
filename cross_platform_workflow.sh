#!/bin/bash

###############################################################################
# Practical Cross-Platform Development Workflow
# Real-world examples of developing on macOS and testing on Linux
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${BOLD}${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║  Cross-Platform Development Workflow                 ║${NC}"
echo -e "${BOLD}${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""

###############################################################################
# Demo 1: Write Code on macOS, Test on Linux
###############################################################################

echo -e "${BOLD}${CYAN}═══ Demo 1: Python Development Workflow ═══${NC}"
echo ""

# Create a web scraper / API client example
cat > /tmp/api_client.py << 'EOF'
#!/usr/bin/env python3
"""
Cross-Platform API Client Example
Works on macOS, Linux, Windows
"""
import sys
import json
import platform
from urllib.request import urlopen
from datetime import datetime

def get_system_info():
    """Get system information"""
    return {
        "platform": platform.system(),
        "release": platform.release(),
        "machine": platform.machine(),
        "python_version": platform.python_version(),
        "timestamp": datetime.now().isoformat()
    }

def fetch_random_user():
    """Fetch a random user from API"""
    try:
        with urlopen("https://randomuser.me/api/", timeout=5) as response:
            data = json.loads(response.read())
            user = data['results'][0]
            return {
                "name": f"{user['name']['first']} {user['name']['last']}",
                "email": user['email'],
                "country": user['location']['country']
            }
    except Exception as e:
        return {"error": str(e)}

def main():
    print("=" * 60)
    print("Cross-Platform API Client Demo")
    print("=" * 60)
    
    # Show system info
    print("\nSystem Information:")
    sys_info = get_system_info()
    for key, value in sys_info.items():
        print(f"  {key}: {value}")
    
    # Fetch data from API
    print("\nFetching random user data from API...")
    user = fetch_random_user()
    print("\nAPI Response:")
    for key, value in user.items():
        print(f"  {key}: {value}")
    
    print("\n✓ Application executed successfully!")

if __name__ == "__main__":
    main()
EOF

chmod +x /tmp/api_client.py

echo -e "${YELLOW}[macOS] Testing API client locally:${NC}"
python3 /tmp/api_client.py
echo ""

echo -e "${YELLOW}[Linux] Testing same code on Ubuntu VM:${NC}"
multipass transfer /tmp/api_client.py ubuntu-dev:/tmp/api_client.py
multipass exec ubuntu-dev -- python3 /tmp/api_client.py
echo ""

###############################################################################
# Demo 2: Shell Script Portability Testing
###############################################################################

echo -e "${BOLD}${CYAN}═══ Demo 2: Bash Script Portability ═══${NC}"
echo ""

cat > /tmp/system_report.sh << 'EOF'
#!/bin/bash
# Cross-platform system report script

echo "=== System Report ==="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "OS: $(uname -s)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo ""

echo "=== Disk Usage ==="
df -h / | tail -1
echo ""

echo "=== Memory Info ==="
if [ "$(uname -s)" = "Darwin" ]; then
    # macOS
    echo "Total Memory: $(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 " GB"}')"
else
    # Linux
    free -h | grep "Mem:" | awk '{print "Total Memory: " $2}'
fi
echo ""

echo "=== CPU Info ==="
if [ "$(uname -s)" = "Darwin" ]; then
    # macOS
    sysctl -n machdep.cpu.brand_string
    echo "Cores: $(sysctl -n hw.ncpu)"
else
    # Linux
    grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2
    echo "Cores: $(nproc)"
fi
echo ""

echo "=== Network Interfaces ==="
if [ "$(uname -s)" = "Darwin" ]; then
    ifconfig | grep "inet " | grep -v 127.0.0.1
else
    ip addr | grep "inet " | grep -v 127.0.0.1
fi
EOF

chmod +x /tmp/system_report.sh

echo -e "${YELLOW}[macOS] Running system report:${NC}"
bash /tmp/system_report.sh
echo ""

echo -e "${YELLOW}[Linux] Running same script on Ubuntu VM:${NC}"
multipass transfer /tmp/system_report.sh ubuntu-dev:/tmp/system_report.sh
multipass exec ubuntu-dev -- bash /tmp/system_report.sh
echo ""

###############################################################################
# Demo 3: File Processing Pipeline
###############################################################################

echo -e "${BOLD}${CYAN}═══ Demo 3: Data Processing Pipeline ═══${NC}"
echo ""

# Create sample data
cat > /tmp/sample_data.csv << 'EOF'
name,age,city,country
Alice,30,New York,USA
Bob,25,London,UK
Charlie,35,Tokyo,Japan
Diana,28,Paris,France
Eve,32,Sydney,Australia
EOF

cat > /tmp/process_data.py << 'EOF'
#!/usr/bin/env python3
import csv
import sys
from collections import Counter

def process_csv(filename):
    with open(filename, 'r') as f:
        reader = csv.DictReader(f)
        data = list(reader)
    
    print(f"Total records: {len(data)}")
    print(f"Average age: {sum(int(row['age']) for row in data) / len(data):.1f}")
    
    countries = Counter(row['country'] for row in data)
    print("\nCountries distribution:")
    for country, count in countries.items():
        print(f"  {country}: {count}")

if __name__ == "__main__":
    process_csv("/tmp/sample_data.csv")
EOF

chmod +x /tmp/process_data.py

echo -e "${YELLOW}[macOS] Processing data locally:${NC}"
python3 /tmp/process_data.py
echo ""

echo -e "${YELLOW}[Linux] Processing same data on Ubuntu VM:${NC}"
multipass transfer /tmp/sample_data.csv ubuntu-dev:/tmp/sample_data.csv
multipass transfer /tmp/process_data.py ubuntu-dev:/tmp/process_data.py
multipass exec ubuntu-dev -- python3 /tmp/process_data.py
echo ""

###############################################################################
# Demo 4: Version Control Workflow
###############################################################################

echo -e "${BOLD}${CYAN}═══ Demo 4: Git Cross-Platform Workflow ═══${NC}"
echo ""

echo -e "${YELLOW}[macOS] Repository Information:${NC}"
cd "$SCRIPT_DIR"
echo "  Branch: $(git branch --show-current 2>/dev/null || echo 'N/A')"
echo "  Commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
echo "  Remote: $(git remote get-url origin 2>/dev/null || echo 'N/A')"
echo ""

echo -e "${YELLOW}[Linux] Same repository on Ubuntu VM:${NC}"
multipass exec ubuntu-dev -- bash -c "
cd /home/ubuntu/AppleDevOpsAutomate
echo '  Branch: '\$(git branch --show-current 2>/dev/null || echo 'N/A')
echo '  Commit: '\$(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')
echo '  Remote: '\$(git remote get-url origin 2>/dev/null || echo 'N/A')
"
echo ""

###############################################################################
# Demo 5: Build & Test Workflow
###############################################################################

echo -e "${BOLD}${CYAN}═══ Demo 5: Build & Test Simulation ═══${NC}"
echo ""

cat > /tmp/test_suite.py << 'EOF'
#!/usr/bin/env python3
import platform

def test_addition():
    assert 2 + 2 == 4, "Addition failed"
    return True

def test_string_operations():
    assert "hello".upper() == "HELLO", "String operation failed"
    return True

def test_list_operations():
    assert len([1, 2, 3]) == 3, "List operation failed"
    return True

def test_platform_detection():
    system = platform.system()
    assert system in ["Darwin", "Linux", "Windows"], "Unknown platform"
    return True

def run_tests():
    tests = [
        ("Addition Test", test_addition),
        ("String Test", test_string_operations),
        ("List Test", test_list_operations),
        ("Platform Test", test_platform_detection)
    ]
    
    passed = 0
    failed = 0
    
    print(f"Running tests on {platform.system()}...")
    print("-" * 40)
    
    for name, test_func in tests:
        try:
            if test_func():
                print(f"✓ {name} PASSED")
                passed += 1
        except Exception as e:
            print(f"✗ {name} FAILED: {e}")
            failed += 1
    
    print("-" * 40)
    print(f"Results: {passed} passed, {failed} failed")
    return failed == 0

if __name__ == "__main__":
    import sys
    sys.exit(0 if run_tests() else 1)
EOF

chmod +x /tmp/test_suite.py

echo -e "${YELLOW}[macOS] Running test suite:${NC}"
python3 /tmp/test_suite.py
echo ""

echo -e "${YELLOW}[Linux] Running same tests on Ubuntu VM:${NC}"
multipass transfer /tmp/test_suite.py ubuntu-dev:/tmp/test_suite.py
multipass exec ubuntu-dev -- python3 /tmp/test_suite.py
echo ""

###############################################################################
# Summary
###############################################################################

echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║  ✓ Cross-Platform Development Complete!              ║${NC}"
echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BOLD}${CYAN}What We Demonstrated:${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} Python Development"
echo "    • API client working on both platforms"
echo "    • Identical code execution on macOS and Linux"
echo ""
echo -e "  ${GREEN}✓${NC} Shell Script Portability"
echo "    • Platform-aware system reporting"
echo "    • Conditional logic for OS differences"
echo ""
echo -e "  ${GREEN}✓${NC} Data Processing Pipeline"
echo "    • CSV processing on both platforms"
echo "    • File transfer between systems"
echo ""
echo -e "  ${GREEN}✓${NC} Version Control Integration"
echo "    • Git repository access from both systems"
echo "    • Synchronized codebase"
echo ""
echo -e "  ${GREEN}✓${NC} Automated Testing"
echo "    • Test suite running on both platforms"
echo "    • Platform detection and validation"
echo ""

echo -e "${BOLD}${YELLOW}Practical Use Cases:${NC}"
echo ""
echo "  🚀 Develop on macOS, deploy to Linux servers"
echo "  🧪 Test scripts on both platforms before production"
echo "  🐳 Use Linux VM for Docker-based development"
echo "  ⚙️  CI/CD pipelines with GitHub Actions (free!)"
echo "  📦 Package applications for multiple platforms"
echo ""

echo -e "${BOLD}${MAGENTA}Next Steps:${NC}"
echo ""
echo "  1. Set up GitHub Actions for automated testing"
echo "  2. Create Docker containers for consistent environments"
echo "  3. Use Linux VM for backend/server development"
echo "  4. Keep macOS for native app development"
echo "  5. Automate deployment pipelines"
echo ""
