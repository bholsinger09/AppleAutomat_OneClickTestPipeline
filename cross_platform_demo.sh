#!/bin/bash

###############################################################################
# Simple Cross-Platform Test - Practical Development Examples
# Demonstrates working with code on both macOS and Linux
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Cross-Platform Development Demo                     ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""

###############################################################################
# Demo 1: Create a Simple Python Script and Test on Both Platforms
###############################################################################

echo -e "${CYAN}═══ Demo 1: Python Script Cross-Platform Test ═══${NC}"
echo ""

# Create a sample Python script
cat > /tmp/test_app.py << 'EOF'
#!/usr/bin/env python3
import platform
import sys

def main():
    print(f"Platform: {platform.system()}")
    print(f"Release: {platform.release()}")
    print(f"Machine: {platform.machine()}")
    print(f"Python Version: {sys.version}")
    print("✓ Cross-platform Python script working!")

if __name__ == "__main__":
    main()
EOF

chmod +x /tmp/test_app.py

echo -e "${YELLOW}[macOS] Running Python script locally:${NC}"
python3 /tmp/test_app.py
echo ""

echo -e "${YELLOW}[Linux] Running same script on Ubuntu VM:${NC}"
# Copy to VM and run
multipass transfer /tmp/test_app.py ubuntu-dev:/tmp/test_app.py
multipass exec ubuntu-dev -- python3 /tmp/test_app.py
echo ""

###############################################################################
# Demo 2: Docker Container Development - Build on macOS, Test on Linux
###############################################################################

echo -e "${CYAN}═══ Demo 2: Docker Cross-Platform Development ═══${NC}"
echo ""

# Create a simple Node.js app
mkdir -p /tmp/cross-platform-app
cat > /tmp/cross-platform-app/app.js << 'EOF'
const os = require('os');
console.log('=== Cross-Platform Node.js App ===');
console.log(`Platform: ${process.platform}`);
console.log(`Architecture: ${process.arch}`);
console.log(`Hostname: ${os.hostname()}`);
console.log(`CPUs: ${os.cpus().length}`);
console.log('✓ Application running successfully!');
EOF

cat > /tmp/cross-platform-app/Dockerfile << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY app.js .
CMD ["node", "app.js"]
EOF

echo -e "${YELLOW}[macOS] Building Docker image:${NC}"
docker build -t cross-platform-demo /tmp/cross-platform-app
echo ""

echo -e "${YELLOW}[macOS] Running container locally:${NC}"
docker run --rm cross-platform-demo
echo ""

echo -e "${YELLOW}[Linux] Transferring and running on Ubuntu VM:${NC}"
# Save image, transfer, load on VM
docker save cross-platform-demo | gzip > /tmp/cross-platform-demo.tar.gz
multipass transfer /tmp/cross-platform-demo.tar.gz ubuntu-dev:/tmp/cross-platform-demo.tar.gz
multipass exec ubuntu-dev -- bash -c "gunzip -c /tmp/cross-platform-demo.tar.gz | docker load"
multipass exec ubuntu-dev -- docker run --rm cross-platform-demo
echo ""

###############################################################################
# Demo 3: Git Workflow - Sync Between Platforms
###############################################################################

echo -e "${CYAN}═══ Demo 3: Git Cross-Platform Workflow ═══${NC}"
echo ""

echo -e "${YELLOW}[macOS] Git repository status:${NC}"
cd "$SCRIPT_DIR" && git status --short || echo "Not a git repo or no changes"
echo ""

echo -e "${YELLOW}[Linux] Same repository on Ubuntu VM:${NC}"
multipass exec ubuntu-dev -- bash -c "cd /home/ubuntu/AppleDevOpsAutomate && git status --short" || echo "Not a git repo or no changes"
echo ""

###############################################################################
# Demo 4: File System Operations - Create, Transfer, Edit
###############################################################################

echo -e "${CYAN}═══ Demo 4: File System Cross-Platform Sync ═══${NC}"
echo ""

# Create a test file on macOS
cat > /tmp/shared_config.json << 'EOF'
{
  "project": "AppleDevOpsAutomate",
  "platforms": ["macOS", "Linux", "Docker"],
  "tools": {
    "containerization": "Docker",
    "virtualization": "Multipass",
    "ci_cd": "GitHub Actions"
  },
  "created_on": "macOS"
}
EOF

echo -e "${YELLOW}[macOS] Created config file:${NC}"
cat /tmp/shared_config.json
echo ""

echo -e "${YELLOW}[Linux] Transferring to Ubuntu VM:${NC}"
multipass transfer /tmp/shared_config.json ubuntu-dev:/tmp/shared_config.json
echo ""

echo -e "${YELLOW}[Linux] Modifying file on Ubuntu VM:${NC}"
multipass exec ubuntu-dev -- bash -c "
cat /tmp/shared_config.json | \
  python3 -c \"import sys, json; d=json.load(sys.stdin); d['modified_on']='Linux'; print(json.dumps(d, indent=2))\" \
  > /tmp/shared_config_modified.json
cat /tmp/shared_config_modified.json
"
echo ""

###############################################################################
# Demo 5: Development Environment Comparison
###############################################################################

echo -e "${CYAN}═══ Demo 5: Environment Comparison ═══${NC}"
echo ""

echo -e "${YELLOW}[macOS] Development Environment:${NC}"
echo "  Shell: $SHELL"
echo "  User: $USER"
echo "  Home: $HOME"
echo "  PWD: $PWD"
command -v git >/dev/null && echo "  Git: $(git --version)"
command -v docker >/dev/null && echo "  Docker: $(docker --version)"
command -v python3 >/dev/null && echo "  Python: $(python3 --version)"
echo ""

echo -e "${YELLOW}[Linux] Development Environment:${NC}"
multipass exec ubuntu-dev -- bash -c "
echo '  Shell: \$SHELL'
echo '  User: \$USER'
echo '  Home: \$HOME'
echo '  PWD: \$PWD'
git --version 2>/dev/null && echo '  Git: '
docker --version 2>/dev/null
python3 --version 2>/dev/null && echo '  Python: '
"
echo ""

###############################################################################
# Summary
###############################################################################

echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ Cross-Platform Development Demo Complete!         ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}What we demonstrated:${NC}"
echo "  ✓ Python scripts running on both platforms"
echo "  ✓ Docker containers built on macOS, tested on Linux"
echo "  ✓ Git repository access from both systems"
echo "  ✓ File transfer and synchronization"
echo "  ✓ Environment comparison and compatibility"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  • Use GitHub Actions for automated cross-platform CI/CD"
echo "  • Deploy containers to cloud platforms"
echo "  • Set up continuous integration pipelines"
echo "  • Test scripts on both platforms before deployment"
echo ""
