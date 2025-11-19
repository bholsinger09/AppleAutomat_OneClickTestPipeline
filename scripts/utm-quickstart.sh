#!/bin/bash
# UTM Quick Start Script - Run this on your Mac to help set up UTM

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║        UTM Virtual Machine Quick Start Guide                 ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if UTM is installed
if [ ! -d "/Applications/UTM.app" ]; then
    echo -e "${YELLOW}UTM is not installed. Let's install it!${NC}"
    echo ""
    echo "Choose installation method:"
    echo "  1) Homebrew (free)"
    echo "  2) Download from website (free)"
    echo "  3) Mac App Store (\$9.99 - supports developers)"
    echo ""
    read -p "Enter choice [1-3]: " choice
    
    case $choice in
        1)
            if command -v brew >/dev/null 2>&1; then
                echo -e "${GREEN}Installing UTM via Homebrew...${NC}"
                brew install --cask utm
            else
                echo -e "${YELLOW}Homebrew not found. Install from: https://brew.sh${NC}"
                exit 1
            fi
            ;;
        2)
            echo -e "${GREEN}Opening UTM download page...${NC}"
            open "https://mac.getutm.app/"
            echo "Please download and install UTM, then run this script again."
            exit 0
            ;;
        3)
            echo -e "${GREEN}Opening Mac App Store...${NC}"
            open "https://apps.apple.com/us/app/utm-virtual-machines/id1538878817"
            echo "Please purchase and install UTM, then run this script again."
            exit 0
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
else
    echo -e "${GREEN}✓ UTM is already installed${NC}"
fi

echo ""
echo -e "${GREEN}Step 1: Download Ubuntu ARM64 ISO${NC}"
echo "========================================"
echo ""

ISO_DIR="$HOME/Downloads"
ISO_FILE="$ISO_DIR/ubuntu-22.04-live-server-arm64.iso"

if [ -f "$ISO_FILE" ]; then
    echo -e "${GREEN}✓ Ubuntu ISO already downloaded${NC}"
else
    echo "Downloading Ubuntu 22.04 LTS Server (ARM64)..."
    echo "This may take a few minutes depending on your connection."
    echo ""
    
    curl -L --progress-bar -o "$ISO_FILE" \
        "https://cdimage.ubuntu.com/releases/22.04/release/ubuntu-22.04.3-live-server-arm64.iso"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ ISO downloaded successfully${NC}"
    else
        echo -e "${YELLOW}Download failed. You can manually download from:${NC}"
        echo "https://ubuntu.com/download/server/arm"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}Step 2: Create UTM Virtual Machine${NC}"
echo "========================================"
echo ""
echo "Opening UTM..."
open -a UTM

echo ""
echo -e "${BLUE}Manual steps in UTM:${NC}"
echo ""
echo "  1. Click the '+' button to create a new VM"
echo "  2. Select 'Virtualize' (not Emulate)"
echo "  3. Select 'Linux'"
echo "  4. Browse and select: $ISO_FILE"
echo ""
echo "  5. Configure resources:"
echo "     - Memory: 8 GB (recommended) or 4 GB (minimum)"
echo "     - CPU Cores: 4"
echo "     - Storage: 50 GB"
echo ""
echo "  6. Give it a name: 'Ubuntu DevOps'"
echo "  7. Click 'Save'"
echo "  8. Start the VM and follow Ubuntu installation"
echo ""
echo "  During Ubuntu installation:"
echo "     - Username: devops (or your choice)"
echo "     - Install OpenSSH server (important!)"
echo "     - Select minimal installation"
echo ""

read -p "Press Enter when Ubuntu installation is complete..."

echo ""
echo -e "${GREEN}Step 3: Transfer Setup Script to VM${NC}"
echo "========================================"
echo ""

# Create a one-liner to copy to VM
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup-utm-linux.sh"

echo "Method 1: Copy the setup script"
echo "================================"
echo ""
echo "Run this command in your UTM VM terminal:"
echo ""
echo -e "${YELLOW}curl -L https://raw.githubusercontent.com/bholsinger09/AppleAutomat_OneClickTestPipeline/main/scripts/setup-utm-linux.sh -o setup.sh && chmod +x setup.sh && ./setup.sh${NC}"
echo ""
echo ""

echo "Method 2: Use shared folder (if configured)"
echo "==========================================="
echo ""
echo "1. In UTM, select your VM"
echo "2. Click 'Edit' → 'Sharing'"
echo "3. Enable 'Share Directory'"
echo "4. Select: $(dirname "$SCRIPT_PATH")"
echo ""
echo "Then in VM, run:"
echo -e "${YELLOW}sudo mkdir -p /mnt/shared && sudo mount -t 9p -o trans=virtio share /mnt/shared${NC}"
echo -e "${YELLOW}cp /mnt/shared/setup-utm-linux.sh ~/setup.sh && chmod +x ~/setup.sh && ./setup.sh${NC}"
echo ""
echo ""

echo "Method 3: Use SCP (if SSH is configured)"
echo "========================================"
echo ""
read -p "Enter VM IP address (or press Enter to skip): " VM_IP

if [ -n "$VM_IP" ]; then
    echo ""
    echo "Run this command on your Mac:"
    echo ""
    echo -e "${YELLOW}scp '$SCRIPT_PATH' devops@$VM_IP:~/setup.sh${NC}"
    echo -e "${YELLOW}ssh devops@$VM_IP 'chmod +x ~/setup.sh && ./setup.sh'${NC}"
    echo ""
fi

echo ""
echo -e "${GREEN}✅ UTM Setup Guide Complete!${NC}"
echo ""
echo "📚 For detailed documentation, see:"
echo "   docs/UTM_SETUP.md"
echo ""
echo "🚀 After running setup.sh in your VM, you'll be ready to test scripts!"
echo ""
