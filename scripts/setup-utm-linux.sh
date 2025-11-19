#!/bin/bash
################################################################################
# UTM Linux VM Setup Script
# Automated setup for testing AppleDevOpsAutomate scripts in Linux environment
################################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${BOLD}${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║     UTM Linux Development Environment Setup                  ║
║     AppleDevOpsAutomate Testing Environment                  ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Detect OS
if [[ ! "$OSTYPE" == "linux-gnu"* ]]; then
    echo -e "${RED}Error: This script must be run in a Linux environment${NC}"
    exit 1
fi

# Check if running in VM
echo -e "${BLUE}📋 System Information${NC}"
echo -e "${CYAN}OS: $(lsb_release -d | cut -f2)${NC}"
echo -e "${CYAN}Kernel: $(uname -r)${NC}"
echo -e "${CYAN}Architecture: $(uname -m)${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install packages
install_packages() {
    local packages=("$@")
    echo -e "${YELLOW}📦 Installing: ${packages[*]}${NC}"
    
    if command_exists apt-get; then
        sudo apt-get install -y "${packages[@]}"
    elif command_exists yum; then
        sudo yum install -y "${packages[@]}"
    elif command_exists dnf; then
        sudo dnf install -y "${packages[@]}"
    else
        echo -e "${RED}Error: No supported package manager found${NC}"
        return 1
    fi
}

# Update system
echo -e "${BOLD}${MAGENTA}1. System Update${NC}"
if command_exists apt-get; then
    sudo apt-get update
    sudo apt-get upgrade -y
elif command_exists yum; then
    sudo yum update -y
elif command_exists dnf; then
    sudo dnf update -y
fi
echo -e "${GREEN}✓ System updated${NC}"
echo ""

# Install essential tools
echo -e "${BOLD}${MAGENTA}2. Essential Development Tools${NC}"
ESSENTIAL_TOOLS=(
    "git"
    "curl"
    "wget"
    "vim"
    "nano"
    "build-essential"
    "htop"
    "net-tools"
    "tree"
    "jq"
    "unzip"
    "zip"
    "rsync"
)

# Adjust package names for different distros
if command_exists yum || command_exists dnf; then
    ESSENTIAL_TOOLS=("${ESSENTIAL_TOOLS[@]/build-essential/gcc gcc-c++ make}")
fi

install_packages "${ESSENTIAL_TOOLS[@]}"
echo -e "${GREEN}✓ Essential tools installed${NC}"
echo ""

# Install programming languages
echo -e "${BOLD}${MAGENTA}3. Programming Languages & Runtimes${NC}"

# Python
echo -e "${CYAN}Installing Python...${NC}"
if command_exists apt-get; then
    install_packages python3 python3-pip python3-venv python3-dev
else
    install_packages python3 python3-pip
fi

# Node.js
echo -e "${CYAN}Installing Node.js...${NC}"
if ! command_exists node; then
    if command_exists apt-get; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        install_packages nodejs
    else
        install_packages nodejs npm
    fi
fi

# Ruby
echo -e "${CYAN}Installing Ruby...${NC}"
if command_exists apt-get; then
    install_packages ruby ruby-dev
else
    install_packages ruby
fi

# Go
echo -e "${CYAN}Installing Go...${NC}"
if command_exists apt-get; then
    install_packages golang-go
else
    install_packages golang
fi

echo -e "${GREEN}✓ Programming languages installed${NC}"
echo ""

# Install Docker
echo -e "${BOLD}${MAGENTA}4. Docker Installation${NC}"
if ! command_exists docker; then
    echo -e "${CYAN}Installing Docker...${NC}"
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sudo sh /tmp/get-docker.sh
    sudo usermod -aG docker "$USER"
    rm /tmp/get-docker.sh
    
    # Install Docker Compose
    if command_exists apt-get; then
        sudo apt-get install -y docker-compose-plugin || true
    fi
    
    echo -e "${GREEN}✓ Docker installed${NC}"
    echo -e "${YELLOW}⚠️  Log out and back in for Docker group to take effect${NC}"
else
    echo -e "${GREEN}✓ Docker already installed${NC}"
fi
echo ""

# Install additional CLI tools
echo -e "${BOLD}${MAGENTA}5. Additional CLI Tools${NC}"
OPTIONAL_TOOLS=(
    "zsh"
    "tmux"
    "screen"
)

for tool in "${OPTIONAL_TOOLS[@]}"; do
    if ! command_exists "$tool"; then
        install_packages "$tool" || echo -e "${YELLOW}⚠️  Could not install $tool${NC}"
    fi
done

# Install modern CLI tools if available
if command_exists apt-get; then
    install_packages fzf ripgrep fd-find bat || true
fi

echo -e "${GREEN}✓ CLI tools installed${NC}"
echo ""

# Setup SSH server
echo -e "${BOLD}${MAGENTA}6. SSH Server Setup${NC}"
if ! command_exists sshd; then
    if command_exists apt-get; then
        install_packages openssh-server
    else
        install_packages openssh-server
    fi
    sudo systemctl enable ssh || true
    sudo systemctl start ssh || true
    echo -e "${GREEN}✓ SSH server installed and started${NC}"
else
    echo -e "${GREEN}✓ SSH server already installed${NC}"
fi
echo ""

# Clone AppleDevOpsAutomate repository
echo -e "${BOLD}${MAGENTA}7. AppleDevOpsAutomate Repository${NC}"
if [ ! -d ~/AppleDevOpsAutomate ]; then
    echo -e "${CYAN}Cloning repository...${NC}"
    git clone https://github.com/bholsinger09/AppleAutomat_OneClickTestPipeline.git ~/AppleDevOpsAutomate
    echo -e "${GREEN}✓ Repository cloned to ~/AppleDevOpsAutomate${NC}"
else
    echo -e "${GREEN}✓ Repository already exists${NC}"
    echo -e "${CYAN}Updating repository...${NC}"
    cd ~/AppleDevOpsAutomate && git pull
fi
echo ""

# Create workspace directories
echo -e "${BOLD}${MAGENTA}8. Workspace Setup${NC}"
mkdir -p ~/projects
mkdir -p ~/workspace
mkdir -p ~/bin
echo -e "${GREEN}✓ Workspace directories created${NC}"
echo ""

# Setup Git configuration
echo -e "${BOLD}${MAGENTA}9. Git Configuration${NC}"
if [ -z "$(git config --global user.name)" ]; then
    read -p "Enter your name for Git: " git_name
    git config --global user.name "$git_name"
fi

if [ -z "$(git config --global user.email)" ]; then
    read -p "Enter your email for Git: " git_email
    git config --global user.email "$git_email"
fi

git config --global init.defaultBranch main
git config --global pull.rebase false
echo -e "${GREEN}✓ Git configured${NC}"
echo ""

# Create useful aliases
echo -e "${BOLD}${MAGENTA}10. Shell Aliases${NC}"
cat >> ~/.bashrc << 'ALIASES'

# AppleDevOpsAutomate aliases
alias devops='cd ~/AppleDevOpsAutomate/devops-tools'
alias projects='cd ~/projects'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias update='sudo apt update && sudo apt upgrade -y'
alias ports='netstat -tulanp'
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -10'
alias gd='git diff'

ALIASES

echo -e "${GREEN}✓ Shell aliases added${NC}"
echo ""

# Install spice-vdagent for better VM integration
echo -e "${BOLD}${MAGENTA}11. VM Integration Tools${NC}"
if command_exists apt-get; then
    install_packages spice-vdagent qemu-guest-agent || true
    sudo systemctl enable qemu-guest-agent || true
    sudo systemctl start qemu-guest-agent || true
    echo -e "${GREEN}✓ VM integration tools installed${NC}"
else
    echo -e "${YELLOW}⚠️  Skipping VM tools (not available for this distro)${NC}"
fi
echo ""

# Get system information
echo -e "${BOLD}${MAGENTA}12. System Information${NC}"
IP_ADDRESS=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -1)
echo -e "${CYAN}IP Address: ${GREEN}$IP_ADDRESS${NC}"
echo -e "${CYAN}SSH Access: ${GREEN}ssh $USER@$IP_ADDRESS${NC}"
echo ""

# Summary
echo -e "${BOLD}${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                    Setup Complete! ✅                          ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BOLD}📋 Next Steps:${NC}"
echo -e "  ${CYAN}1.${NC} Log out and back in for group changes to take effect:"
echo -e "     ${YELLOW}exit${NC} then reconnect to this VM"
echo -e ""
echo -e "  ${CYAN}2.${NC} Navigate to the repository:"
echo -e "     ${YELLOW}cd ~/AppleDevOpsAutomate/devops-tools${NC}"
echo -e ""
echo -e "  ${CYAN}3.${NC} Test Linux-compatible scripts:"
echo -e "     ${YELLOW}./git-batch.sh ~/projects${NC}"
echo -e "     ${YELLOW}./check-devtools.sh${NC}"
echo -e ""
echo -e "  ${CYAN}4.${NC} From your Mac, you can SSH in:"
echo -e "     ${YELLOW}ssh $USER@$IP_ADDRESS${NC}"
echo -e ""

echo -e "${BOLD}🎓 Useful Commands:${NC}"
echo -e "  ${CYAN}devops${NC}    - Navigate to devops-tools directory"
echo -e "  ${CYAN}projects${NC}  - Navigate to projects directory"
echo -e "  ${CYAN}update${NC}    - Update all system packages"
echo -e "  ${CYAN}gs${NC}        - Git status"
echo -e ""

echo -e "${BOLD}📚 Documentation:${NC}"
echo -e "  ${CYAN}~/AppleDevOpsAutomate/docs/UTM_SETUP.md${NC}"
echo -e "  ${CYAN}~/AppleDevOpsAutomate/CROSS_PLATFORM.md${NC}"
echo -e ""

echo -e "${GREEN}Happy coding! 🚀${NC}"
