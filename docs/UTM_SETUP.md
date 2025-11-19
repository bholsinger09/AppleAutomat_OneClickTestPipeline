# UTM Virtual Machine Setup Guide

Complete guide for setting up UTM on Apple Silicon Macs to test scripts in Linux environments.

## 🎯 What is UTM?

UTM is a free, open-source virtual machine host for macOS that uses Apple's Virtualization framework on Apple Silicon Macs. It's perfect for:
- Testing scripts on Linux
- Running Ubuntu, Debian, Fedora, etc.
- No license costs (completely free)
- Native Apple Silicon performance
- Easy to use GUI

## 📦 Installation

### Method 1: Direct Download (Free)
```bash
# Download from GitHub releases (free)
open https://github.com/utmapp/UTM/releases/latest

# Or download from their website
open https://mac.getutm.app/
```

### Method 2: Mac App Store (Paid - supports developers)
```bash
# $9.99 one-time purchase to support development
open https://apps.apple.com/us/app/utm-virtual-machines/id1538878817
```

### Method 3: Homebrew
```bash
brew install --cask utm
```

## 🐧 Setting Up Ubuntu Linux VM

### Quick Setup (Recommended)

1. **Download Ubuntu ARM64 Image**
   ```bash
   # Ubuntu Server 22.04 LTS (ARM64)
   curl -L -o ~/Downloads/ubuntu-22.04-live-server-arm64.iso \
     https://cdimage.ubuntu.com/releases/22.04/release/ubuntu-22.04.3-live-server-arm64.iso
   ```

2. **Open UTM and Create New VM**
   - Click "+" → "Virtualize"
   - Select "Linux"
   - Browse and select the downloaded ISO
   
3. **Configure VM Resources**
   - Memory: 4 GB (minimum) to 8 GB (recommended)
   - CPU Cores: 4 (recommended)
   - Storage: 40 GB (minimum) to 64 GB (comfortable)

4. **Complete Installation**
   - Start the VM
   - Follow Ubuntu installation wizard
   - Username: `devops` (or your preference)
   - Install OpenSSH server when prompted

### Post-Installation Setup

Once Ubuntu is installed and running:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y \
  git \
  curl \
  wget \
  build-essential \
  vim \
  htop \
  net-tools

# Install development tools
sudo apt install -y \
  python3 \
  python3-pip \
  nodejs \
  npm \
  ruby \
  golang-go

# Install Docker (optional)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

## 🔧 Transferring Scripts to VM

### Method 1: Shared Folder (Easiest)

1. In UTM, select your VM
2. Click "Edit" → "Sharing"
3. Enable "Share Directory"
4. Select your AppleDevOpsAutomate folder

In the VM:
```bash
# Mount shared folder (path may vary)
sudo mkdir -p /mnt/shared
sudo mount -t 9p -o trans=virtio share /mnt/shared

# Copy scripts
cp -r /mnt/shared/devops-tools ~/devops-tools
cd ~/devops-tools
```

### Method 2: Git Clone (Recommended)

```bash
# In the VM
git clone https://github.com/bholsinger09/AppleAutomat_OneClickTestPipeline.git
cd AppleAutomat_OneClickTestPipeline/devops-tools
```

### Method 3: SCP from Host Mac

```bash
# On your Mac (find VM IP first)
# In VM, run: ip addr show

# From Mac terminal
scp -r devops-tools/ devops@VM_IP_ADDRESS:~/

# Or use rsync for better performance
rsync -avz devops-tools/ devops@VM_IP_ADDRESS:~/devops-tools/
```

### Method 4: Simple Copy-Paste

UTM supports copy-paste between host and guest:
1. Enable in UTM: Edit VM → Display → Enable clipboard sharing
2. Install spice-vdagent in VM:
   ```bash
   sudo apt install spice-vdagent
   ```

## 🧪 Testing Scripts in Linux VM

### Test Linux-Compatible Scripts

```bash
cd ~/devops-tools

# Test Git operations (fully compatible)
./git-batch.sh ~/projects

# Test system checks (needs adaptation)
./check-devtools.sh

# Test project initialization
./project-init.sh
```

### Create Linux Alternatives

```bash
# Create linux-specific tools directory
mkdir -p ~/devops-tools/linux

# Copy and adapt scripts
cp check-devtools.sh linux/linux-devtools-check.sh
cp system-cleanup.sh linux/linux-cleanup.sh
```

## 🚀 Automation Script for UTM Setup

Save this as `setup-utm-linux.sh` in your repo:

```bash
#!/bin/bash
# Automated UTM Linux VM Setup Script

set -euo pipefail

echo "🚀 UTM Linux Development Environment Setup"
echo "=========================================="
echo ""

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential development tools
echo "🔧 Installing development tools..."
sudo apt install -y \
  git curl wget vim nano \
  build-essential \
  htop btop \
  net-tools \
  tree \
  jq \
  unzip \
  zip

# Install programming languages
echo "💻 Installing programming languages..."
sudo apt install -y \
  python3 python3-pip python3-venv \
  nodejs npm \
  ruby ruby-dev \
  golang-go \
  openjdk-17-jdk

# Install version control tools
echo "🌿 Installing version control..."
sudo apt install -y \
  git \
  git-lfs \
  subversion

# Install Docker
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sudo sh /tmp/get-docker.sh
  sudo usermod -aG docker $USER
  rm /tmp/get-docker.sh
fi

# Install Docker Compose
echo "📦 Installing Docker Compose..."
sudo apt install -y docker-compose

# Install useful CLI tools
echo "🛠️  Installing CLI utilities..."
sudo apt install -y \
  zsh \
  tmux \
  screen \
  fzf \
  ripgrep \
  fd-find \
  bat

# Setup Oh My Zsh (optional)
read -p "Install Oh My Zsh? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Clone AppleDevOpsAutomate repository
echo "📁 Cloning AppleDevOpsAutomate repository..."
if [ ! -d ~/AppleDevOpsAutomate ]; then
  git clone https://github.com/bholsinger09/AppleAutomat_OneClickTestPipeline.git ~/AppleDevOpsAutomate
fi

# Create workspace directory
mkdir -p ~/projects

# Setup complete
echo ""
echo "✅ Setup Complete!"
echo ""
echo "Next steps:"
echo "  1. Log out and log back in for Docker group to take effect"
echo "  2. cd ~/AppleDevOpsAutomate/devops-tools"
echo "  3. Test scripts: ./git-batch.sh ~/projects"
echo ""
```

## 📊 VM Performance Optimization

### Recommended UTM Settings for Development

1. **CPU**
   - Cores: 4-6 (don't allocate all cores, leave some for macOS)
   - Enable: "Force Multicore"

2. **Memory**
   - 8 GB for comfortable development
   - 4 GB minimum for basic testing
   - Don't exceed 50% of your Mac's RAM

3. **Display**
   - Resolution: 1920x1080 or higher
   - Enable: "Retina Mode" for HiDPI
   - Enable: "Clipboard Sharing"

4. **Network**
   - Mode: "Shared Network" (easiest)
   - Or "Bridged" for direct network access

5. **Storage**
   - Use "Apple Virtualization" (fastest)
   - Enable "Resize disk supported"

### Performance Tips

```bash
# In VM - Install QEMU guest agent
sudo apt install qemu-guest-agent
sudo systemctl enable qemu-guest-agent
sudo systemctl start qemu-guest-agent

# Enable trim/discard for better SSD performance
sudo systemctl enable fstrim.timer

# Install performance monitoring
sudo apt install sysstat
```

## 🔄 Snapshots & Backups

### Creating Snapshots (Highly Recommended)

1. Right-click VM → "Manage" → "Snapshots"
2. Create snapshot before major changes
3. Name it descriptively: "Clean Ubuntu + Dev Tools"

### Quick Snapshot Script

```bash
# In UTM, use AppleScript to create snapshot
osascript <<EOF
tell application "UTM"
  tell virtual machine "Ubuntu Dev"
    create snapshot "Before Testing $(date +%Y%m%d)"
  end tell
end tell
EOF
```

## 🌐 Network Configuration

### Access VM from Mac (SSH)

```bash
# In VM, install and start SSH
sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh

# Get VM IP
ip addr show | grep inet

# From Mac, connect
ssh devops@VM_IP_ADDRESS

# Optional: Add to ~/.ssh/config on Mac
cat >> ~/.ssh/config <<EOF

Host utm-dev
  HostName VM_IP_ADDRESS
  User devops
  ForwardAgent yes
EOF

# Now connect with: ssh utm-dev
```

### Port Forwarding

In UTM:
1. Edit VM → Network
2. Port Forward:
   - Guest: 22 → Host: 2222 (SSH)
   - Guest: 80 → Host: 8080 (Web)
   - Guest: 3000 → Host: 3000 (Dev server)

```bash
# Connect via port forwarding
ssh -p 2222 devops@localhost
```

## 💡 Common Use Cases

### 1. Testing Bash Scripts
```bash
# Copy script to VM
scp devops-tools/git-batch.sh utm-dev:~/

# Run in VM
ssh utm-dev 'bash ~/git-batch.sh ~/projects'
```

### 2. Running Docker Containers
```bash
# In VM
docker run -it --rm ubuntu:22.04 bash
```

### 3. Web Development Testing
```bash
# Start dev server in VM on port 3000
# Access from Mac: http://localhost:3000 (if port forwarded)
```

### 4. CI/CD Pipeline Testing
```bash
# Test GitHub Actions locally
sudo apt install act
cd ~/AppleDevOpsAutomate
act -l
```

## 🆚 UTM vs Other Options

| Feature | UTM (ARM) | VirtualBox | Parallels | VMware |
|---------|-----------|------------|-----------|--------|
| Apple Silicon | ✅ Native | ❌ No | ✅ Yes | ⚠️ Beta |
| Cost | 🆓 Free | 🆓 Free | 💰 $99/yr | 💰 $199 |
| Performance | ⚡ Excellent | ❌ N/A | ⚡ Excellent | ⚡ Good |
| Linux Support | ✅ Great | ❌ N/A | ✅ Good | ✅ Good |
| Ease of Use | ✅ Easy | ✅ Easy | ✅ Easy | ✅ Easy |

## 🎓 Learning Resources

- UTM Documentation: https://docs.getutm.app/
- Ubuntu Server Guide: https://ubuntu.com/server/docs
- Docker Documentation: https://docs.docker.com/
- Linux Command Line: https://linuxcommand.org/

## 🐛 Troubleshooting

### VM Won't Boot
- Verify ISO is ARM64 version
- Increase memory to at least 4GB
- Check virtualization is enabled in BIOS (should be default on M-series)

### Slow Performance
- Reduce allocated CPU cores (try 4 instead of 6)
- Increase allocated RAM
- Enable "Force Multicore" option
- Use "Apple Virtualization" storage driver

### Network Not Working
- Switch from "Bridged" to "Shared Network"
- Restart VM
- Check macOS firewall settings

### Can't Share Clipboard
- Install spice-vdagent: `sudo apt install spice-vdagent`
- Enable clipboard sharing in UTM settings
- Restart VM

### Shared Folder Not Mounting
```bash
# Manual mount
sudo mkdir -p /mnt/shared
sudo mount -t 9p -o trans=virtio share /mnt/shared

# Auto-mount on boot
echo "share /mnt/shared 9p trans=virtio,version=9p2000.L,rw 0 0" | sudo tee -a /etc/fstab
```

## 🎉 Quick Start Summary

```bash
# 1. Install UTM
brew install --cask utm

# 2. Download Ubuntu ARM64
curl -L -o ~/Downloads/ubuntu-22.04-server-arm64.iso \
  https://cdimage.ubuntu.com/releases/22.04/release/ubuntu-22.04.3-live-server-arm64.iso

# 3. Create VM in UTM (GUI)
# - 8GB RAM, 4 CPUs, 50GB disk

# 4. In VM after installation
sudo apt update && sudo apt upgrade -y
sudo apt install git curl build-essential
git clone https://github.com/bholsinger09/AppleAutomat_OneClickTestPipeline.git
cd AppleAutomat_OneClickTestPipeline/devops-tools
./git-batch.sh ~/projects

# 5. Done! 🎉
```

---

**Pro Tip:** Create a snapshot after initial setup so you can quickly restore to a clean state for testing!
