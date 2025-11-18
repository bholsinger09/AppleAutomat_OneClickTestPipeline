# DevOps Enhancement Tools

A collection of powerful automation scripts for iOS/macOS development workflows.

## 🚀 Quick Start

### Launch the Menu
```bash
cd /Users/benh/Documents/AppleDevOpsAutomate/devops-tools
./devops-menu.sh
```

Or run individual tools directly from iTerm/Terminal.

## 📦 Available Tools

### 1. **Health Check** (`check-devtools.sh`)
Comprehensive system scan for all development tools:
- ✅ Checks installation status
- 📊 Shows current versions
- 🏃 Verifies running status
- 📦 Suggests installation commands

**Categories checked:**
- Development Tools (Xcode, Swift, Git, GitHub CLI)
- Package Managers (Homebrew, CocoaPods, npm, pip, gem)
- Programming Languages (Node.js, Python, Ruby, Go, Rust, Java)
- Applications (VS Code, Docker, Postman, iTerm, Raycast, Stats)
- DevOps Tools (kubectl, Terraform, Ansible)

**Usage:**
```bash
./check-devtools.sh
```

### 2. **Auto Update** (`auto-update.sh`)
One-click update for all development tools:
- 🔄 Updates Homebrew & all packages
- 📦 Updates npm, pip, gems, CocoaPods
- ⚡ Updates Fastlane, GitHub CLI
- 🧹 Cleans up after updates

**Usage:**
```bash
./auto-update.sh
```

### 3. **System Cleanup** (`system-cleanup.sh`)
Free up gigabytes of disk space:
- 🗑️ Xcode DerivedData, Archives, Device Support
- 📦 CocoaPods cache
- 🍺 Homebrew downloads
- 📦 npm cache
- 🐳 Docker images & containers
- 🗂️ System logs & caches
- 🗑️ Trash

**Shows before/after sizes and total space freed!**

**Usage:**
```bash
./system-cleanup.sh
```

### 4. **Xcode Quick Actions** (`xcode-quick-actions.sh`)
Batch operations on Xcode projects:
- 🧹 Clean build artifacts
- 🔨 Build projects
- 🧪 Run tests
- 📦 Create archives
- 🔄 All-in-one (clean + build + test)

**Interactive mode** or command-line:

```bash
# Interactive
./xcode-quick-actions.sh

# Command-line
./xcode-quick-actions.sh -a build -p MyApp.xcodeproj -s MyApp
./xcode-quick-actions.sh -a test -p MyApp.xcworkspace -s MyApp --clean
./xcode-quick-actions.sh -a all -p MyApp.xcodeproj -s MyApp -c Release
```

### 5. **Git Batch Operations** (`git-batch.sh`)
Perform git operations across multiple repositories:
- 📊 Check status of all repos
- ⬇️ Pull latest changes
- 🔄 Fetch from all remotes
- 🌿 Show current branches
- ⚠️ List uncommitted changes
- 📈 Find repos behind remote

**Usage:**
```bash
# Scan default Documents folder
./git-batch.sh

# Scan custom path
./git-batch.sh ~/Projects
```

### 6. **Master Menu** (`devops-menu.sh`)
Central hub with ASCII art menu:
- 🎨 Beautiful terminal UI
- 📋 Quick access to all tools
- 🔁 Loop back to menu after each operation

## 🔧 Integration with Automator

### Create Quick Launchers

**1. Create iTerm Profile:**
```bash
# In iTerm2 > Preferences > Profiles
# Set command to:
/Users/benh/Documents/AppleDevOpsAutomate/devops-tools/devops-menu.sh
```

**2. Create Automator Quick Action:**
1. Open Automator
2. New Document → Quick Action
3. Add "Run Shell Script"
4. Paste:
```bash
osascript -e 'tell application "iTerm"
    create window with default profile
    tell current session of current window
        write text "cd /Users/benh/Documents/AppleDevOpsAutomate/devops-tools && ./devops-menu.sh"
    end tell
end tell'
```
5. Save as "DevOps Tools"
6. Access via Services menu or assign keyboard shortcut

**3. Create Alfred/Raycast Command:**
```bash
# Name: DevOps Menu
# Script:
cd /Users/benh/Documents/AppleDevOpsAutomate/devops-tools && ./devops-menu.sh
```

## 📝 Examples

### Daily Routine
```bash
# Morning check
./check-devtools.sh

# Update everything
./auto-update.sh

# Check all repos
./git-batch.sh ~/Documents
```

### Weekly Maintenance
```bash
# Free up space
./system-cleanup.sh

# Run full pipeline on project
./xcode-quick-actions.sh -a all -p MyApp.xcodeproj -s MyApp
```

### CI/CD Integration
```bash
# Pre-commit hook
./check-devtools.sh
./git-batch.sh | grep "uncommitted"

# Build automation
./xcode-quick-actions.sh -a build -p MyApp.xcodeproj -s MyApp --clean
```

## 🎯 Features

- ✅ **Zero dependencies** - Pure Bash scripts
- 🎨 **Beautiful output** - Colored, formatted terminal UI
- 🔧 **Interactive & CLI** - Works both ways
- 📊 **Progress tracking** - See what's happening
- ⚡ **Fast execution** - Optimized for speed
- 🛡️ **Error handling** - Safe to run anytime
- 📝 **Comprehensive logging** - Know what changed

## 🚨 Safety Notes

- Scripts use `set -euo pipefail` for safety
- System cleanup asks for confirmation
- All operations are logged
- Non-destructive by default
- Can be safely interrupted with Ctrl+C

## 🔗 Integration with AppleAutomat Pipeline

All tools work seamlessly with the main `one_click_pipeline.sh`:
```bash
# From devops-tools menu, option 6 launches the pipeline
# Or run directly:
cd /Users/benh/Documents/AppleDevOpsAutomate
./one_click_pipeline.sh --platform ios --scheme MyApp
```

## 📚 Advanced Usage

### Scheduled Automation (launchd)
Create `~/Library/LaunchAgents/com.devops.cleanup.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.devops.cleanup</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/benh/Documents/AppleDevOpsAutomate/devops-tools/system-cleanup.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
        <key>Weekday</key>
        <integer>0</integer>
    </dict>
</dict>
</plist>
```

Load with: `launchctl load ~/Library/LaunchAgents/com.devops.cleanup.plist`

## 🎉 Try It Now!

```bash
cd /Users/benh/Documents/AppleDevOpsAutomate/devops-tools
./devops-menu.sh
```

Enjoy your enhanced DevOps workflow! 🚀
