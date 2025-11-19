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

### 6. **Performance Monitor** (`performance-monitor.sh`)
Track build performance and generate analytics:
- ⏱️ Real-time CPU/Memory monitoring during builds
- 📊 Build time tracking with historical data
- 🔥 Identify slow compilation units (>100ms)
- 📈 Generate performance reports and trends
- 📁 JSON metrics storage for analysis

**Features:**
- Monitor xcodebuild processes in real-time
- Track average and peak CPU/memory usage
- Analyze build logs for slow files
- Compare build times across projects
- Export performance data as JSON
- Generate human-readable reports

**Usage:**
```bash
# Monitor a build
./performance-monitor.sh build /path/to/Project.xcodeproj MyScheme Debug

# Generate performance report
./performance-monitor.sh report

# Interactive mode
./performance-monitor.sh
```

**Sample Output:**
```
Build Results
═══════════════════════════════════════════════════════════════
✓ Build Status: SUCCESS
⏱ Duration: 127s (02:07)

Performance Metrics:
Metric               Average       Peak
──────────────────── ────────── ──────────
CPU Usage              245.3%     387.1%
Memory Usage            12.4%      18.9%

Slow Compilation Units (>100ms):
  🔥 523.2ms
  🔥 412.8ms
  🔥 307.1ms
```

### 7. **Mac System Monitor** (`mac-system-monitor.sh`)
Comprehensive macOS system health monitoring:
- 💻 CPU usage and core information (Apple Silicon optimized)
- 🧠 Memory statistics with pressure analysis
- 💾 Disk space and I/O activity tracking
- 🌐 Network interfaces and connection monitoring
- 🔋 Battery health and cycle count (for MacBooks)
- 🌡️ System temperature monitoring
- 📊 Generate detailed system reports
- ⏱️ Real-time continuous monitoring

**Features:**
- Apple M-series chip detection and optimization
- Memory pressure analysis (normal/warning/critical)
- Multi-volume disk monitoring
- Network bandwidth and connection stats
- Battery health with cycle count tracking
- Save reports to timestamped files

**Usage:**
```bash
# Quick system check
./mac-system-monitor.sh quick

# Generate detailed report
./mac-system-monitor.sh report

# Continuous monitoring (refresh every 3 seconds)
./mac-system-monitor.sh monitor 3

# Interactive mode
./mac-system-monitor.sh
```

**Sample Output:**
```
💻 CPU Information
Model: Apple M4 Max
Physical Cores: 16, Logical Cores: 16
Current Usage: 241.4%

🧠 Memory Information
Total: 64.0 GB, Used: 31.4 GB
Memory Pressure: 9% (Normal)

💾 Disk Information
Total: 926Gi, Used: 11Gi (2%)
Available: 690Gi
```

### 8. **Apple Intelligence Tester** (`apple-intelligence-tester.sh`)
Test and monitor Apple's built-in AI capabilities:
- 🔍 Spotlight Intelligence - Natural language search testing
- 🤖 Siri & Voice Recognition status
- 🧠 Core ML and Vision framework detection
- ✍️ Text Intelligence (auto-correct, predictive text)
- 📸 Photos Intelligence (face/scene recognition)
- 👁️ Visual Intelligence (Live Text, Visual Look Up)
- 🌐 Translation capabilities
- 📧 Mail Intelligence - Check inbox for new messages
- ✅ Reminders Intelligence - Pending tasks and smart lists
- ⚡ AI Performance benchmarking

**Features:**
- Comprehensive AI capabilities report
- Individual feature testing
- Natural language query examples
- Performance metrics for AI operations
- Mail inbox checking with account breakdown
- Reminders smart lists (Today, Scheduled, Flagged)

**Usage:**
```bash
# Full AI capabilities report
./apple-intelligence-tester.sh report

# Test specific features
./apple-intelligence-tester.sh spotlight
./apple-intelligence-tester.sh mail
./apple-intelligence-tester.sh reminders

# Performance benchmark
./apple-intelligence-tester.sh benchmark

# Interactive mode
./apple-intelligence-tester.sh
```

**Sample Output:**
```
📧 Mail Intelligence
✓ Mail accounts found: 2
Total messages in inbox: 5,439
✨ NEW MESSAGES: You have 109 unread message(s)!

Account Breakdown:
  iCloud: 960 messages, 11 unread
  Google: 4,479 messages, 98 unread

✅ Reminders Intelligence
✓ Reminder lists found: 3
Total reminders: 23
✨ PENDING: You have 6 pending reminder(s)!

Smart Lists:
  📅 Today: No reminders due today
  🗓️  Scheduled: 1 reminder(s) with due dates
  🚩 Flagged: No flagged reminders
```

### 9. **Master Menu** (`devops-menu.sh`)
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
