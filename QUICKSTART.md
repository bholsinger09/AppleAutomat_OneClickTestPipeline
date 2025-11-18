# 🚀 Quick Start Guide

Welcome to the Apple Automat One-Click Test Pipeline! This guide will get you up and running in 5 minutes.

## ⚡ 5-Minute Setup

### Step 1: Run Setup (30 seconds)

```bash
cd /Users/benh/Documents/AppleDevOpsAutomate
./setup.sh
```

This will:
- ✅ Check prerequisites (Xcode, etc.)
- ✅ Make scripts executable
- ✅ Create necessary directories
- ✅ Copy configuration templates

### Step 2: Configure Your Project (2 minutes)

Edit `.env` with your project details:

```bash
# Open in your favorite editor
nano .env

# OR
code .env
```

**Minimum required settings:**
```bash
PROJECT_PATH="/path/to/your/xcode/project"
SCHEME_NAME="YourAppSchemeName"
DEVELOPMENT_TEAM="YOUR_TEAM_ID"
```

**Find your values:**
```bash
# Find available schemes
xcodebuild -list -workspace YourApp.xcworkspace
# OR
xcodebuild -list -project YourApp.xcodeproj

# Find your Team ID in Xcode:
# Xcode > Project > Signing & Capabilities > Team
```

### Step 3: Run Your First Build (2 minutes)

```bash
# For iOS
./one_click_pipeline.sh --platform ios --scheme "YourApp"

# For macOS
./one_click_pipeline.sh --platform macos --scheme "YourApp"
```

## 🎯 Common Commands

### Build Commands
```bash
# Basic build and test
./one_click_pipeline.sh --platform ios --scheme "MyApp"

# Release build
./one_click_pipeline.sh --platform ios --scheme "MyApp" --configuration Release

# Clean build
./one_click_pipeline.sh --platform ios --scheme "MyApp" --clean
```

### Test Commands
```bash
# Run tests only (no build)
./one_click_pipeline.sh --platform ios --scheme "MyApp" --tests-only

# Skip tests (build only)
./one_click_pipeline.sh --platform ios --scheme "MyApp" --skip-tests
```

### Debug Commands
```bash
# Verbose output for debugging
./one_click_pipeline.sh --platform ios --scheme "MyApp" --verbose

# View logs
tail -f logs/pipeline_*.log
```

## 🔍 What Gets Created

When you run the pipeline, it creates:

```
AppleDevOpsAutomate/
├── Build/              # Build artifacts and archives
├── DerivedData/        # Xcode build data (cached for speed)
├── logs/               # Detailed build and test logs
│   └── pipeline_YYYYMMDD_HHMMSS.log
└── TestResults/        # XCTest result bundles
    └── TestResults_YYYYMMDD_HHMMSS.xcresult
```

## 📊 Understanding Output

### Console Output

The pipeline uses color-coded output:
- 🔵 **Blue** = Informational messages
- 🟢 **Green** = Success messages
- 🟡 **Yellow** = Warnings
- 🔴 **Red** = Errors

### Exit Codes

- `0` = Success (build and tests passed)
- `1` = Failure (build failed or tests failed)

### Logs

Check logs for detailed information:
```bash
# View latest log
ls -lt logs/ | head -2

# Search for errors
grep -i error logs/pipeline_*.log
```

## 🎨 Customization Quick Tips

### Change Build Configuration
```bash
# Edit config file
nano config/pipeline_config.yaml

# Or use command line
./one_click_pipeline.sh --platform ios --scheme "MyApp" --configuration Debug
```

### Enable Notifications
```bash
# Edit .env
nano .env

# Add your Slack webhook
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# Test notification
./scripts/notifications.sh
```

### Custom Destinations
```bash
# iOS - specific simulator
./scripts/build_ios.sh --scheme "MyApp" --destination "platform=iOS Simulator,name=iPhone 14,OS=latest"

# macOS
./scripts/build_macos.sh --scheme "MyApp"
```

## 🐛 Quick Troubleshooting

### Problem: "Scheme not found"
**Solution:** 
```bash
# List available schemes
xcodebuild -list

# Use exact name
./one_click_pipeline.sh --platform ios --scheme "ExactSchemeName"
```

### Problem: "Permission denied"
**Solution:**
```bash
chmod +x one_click_pipeline.sh scripts/*.sh
```

### Problem: "Workspace not found"
**Solution:**
```bash
# Specify full path
./one_click_pipeline.sh --platform ios --workspace "/full/path/to/App.xcworkspace" --scheme "MyApp"
```

### Problem: "Code signing error"
**Solution:**
```bash
# For simulator builds, signing is disabled automatically
# For device builds, set up code signing:
./scripts/code_signing.sh --setup
```

## 📚 Next Steps

### 1. Explore Documentation
- [Configuration Guide](docs/configuration.md) - Detailed configuration options
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions
- [Advanced Usage](docs/advanced_usage.md) - Advanced features

### 2. Set Up CI/CD
```bash
# GitHub Actions workflows are already included in .github/workflows/
# Just add these secrets to your GitHub repository:
# - APPLE_CERTIFICATE_BASE64
# - APPLE_CERTIFICATE_PASSWORD
# - PROVISIONING_PROFILE_BASE64
# - KEYCHAIN_PASSWORD
```

### 3. Create Automator Workflows
See [automator/README.md](automator/README.md) for creating one-click macOS workflows

### 4. Customize for Your Team
- Add custom scripts in `scripts/`
- Modify configuration in `config/pipeline_config.yaml`
- Set up team-specific notifications

## 💡 Pro Tips

1. **Cache Derived Data**: Don't use `--clean` unless necessary - it's much faster!
2. **Parallel Testing**: Enable in config for faster test execution
3. **Use xcpretty**: Install for prettier output: `gem install xcpretty`
4. **Verbose Mode**: Use `--verbose` when debugging issues
5. **Watch Logs**: Use `tail -f logs/pipeline_*.log` to monitor progress

## 🎓 Examples

### Example 1: Daily Development Build
```bash
./one_click_pipeline.sh --platform ios --scheme "MyApp"
```

### Example 2: Pre-Commit Check
```bash
./one_click_pipeline.sh --platform ios --scheme "MyApp" --tests-only
```

### Example 3: Release Build
```bash
./one_click_pipeline.sh --platform ios --scheme "MyApp" --configuration Release --clean
```

### Example 4: Quick Test Run
```bash
./scripts/run_tests.sh --platform ios --scheme "MyApp"
```

### Example 5: Full Clean Build
```bash
./scripts/cleanup.sh --all
./one_click_pipeline.sh --platform ios --scheme "MyApp" --clean
```

## 🆘 Getting Help

- 📖 Read the [README.md](README.md)
- 🔍 Check [troubleshooting.md](docs/troubleshooting.md)
- 🐛 [Open an issue](https://github.com/bholsinger09/AppleAutomat_OneClickTestPipeline/issues)
- 💬 Ask in discussions

## ✅ Checklist

Before your first build, make sure:
- [ ] Xcode is installed and command line tools are set up
- [ ] `.env` file is configured with your project settings
- [ ] Scheme name is correct
- [ ] Scripts are executable (`chmod +x`)
- [ ] Your project builds successfully in Xcode

## 🎉 Ready to Go!

You're all set! Run your first build:

```bash
./one_click_pipeline.sh --platform ios --scheme "YourApp"
```

Happy building! 🚀

---

**Need more help?** Check out the full [README.md](README.md) or [documentation](docs/).
