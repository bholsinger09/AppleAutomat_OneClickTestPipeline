# Troubleshooting Guide

Common issues and solutions for the Apple Automat One-Click Test Pipeline.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Build Errors](#build-errors)
- [Code Signing Issues](#code-signing-issues)
- [Test Failures](#test-failures)
- [CI/CD Issues](#cicd-issues)
- [Performance Issues](#performance-issues)

## Installation Issues

### Command not found: xcodebuild

**Problem:** `xcodebuild: command not found`

**Solution:**
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify installation
xcodebuild -version
```

### Permission denied when running scripts

**Problem:** `Permission denied: ./one_click_pipeline.sh`

**Solution:**
```bash
# Make scripts executable
chmod +x one_click_pipeline.sh
chmod +x scripts/*.sh
```

### xcpretty not found

**Problem:** xcpretty command not available

**Solution:**
```bash
# Install xcpretty
sudo gem install xcpretty

# Or without sudo if you have rbenv/rvm
gem install xcpretty
```

## Build Errors

### No scheme found

**Problem:** `Error: Could not find scheme 'MyApp'`

**Solution:**
```bash
# List all available schemes
xcodebuild -list

# Use the exact scheme name (case-sensitive)
./one_click_pipeline.sh --platform ios --scheme "MyAppScheme"
```

### Workspace/Project not found

**Problem:** `Error: Workspace not found: MyApp.xcworkspace`

**Solution:**
```bash
# Check if workspace exists
ls *.xcworkspace

# Or specify the full path
./one_click_pipeline.sh --platform ios --workspace "/full/path/to/MyApp.xcworkspace"

# If using a project instead
./one_click_pipeline.sh --platform ios --project "MyApp.xcodeproj"
```

### Build failed with exit code 65

**Problem:** Build fails with generic error code 65

**Common Causes:**
1. Code syntax errors
2. Missing dependencies
3. Code signing issues
4. Invalid build settings

**Solution:**
```bash
# Run with verbose output
./one_click_pipeline.sh --platform ios --verbose

# Check the build log
tail -f logs/build_*.log

# Clean and rebuild
./one_click_pipeline.sh --platform ios --clean
```

### Swift Package Manager issues

**Problem:** SPM dependencies not resolving

**Solution:**
```bash
# Reset package cache
rm -rf .build
rm -rf ~/Library/Caches/org.swift.swiftpm

# Resolve packages
xcodebuild -resolvePackageDependencies

# Then rebuild
./one_click_pipeline.sh --platform ios
```

### CocoaPods issues

**Problem:** Pod dependencies not found

**Solution:**
```bash
# Update CocoaPods
sudo gem install cocoapods

# Install dependencies
cd /path/to/your/project
pod install

# Clean and rebuild
./one_click_pipeline.sh --platform ios --clean
```

## Code Signing Issues

### No signing identity found

**Problem:** `No signing identity found`

**Solution:**
```bash
# List available identities
security find-identity -v -p codesigning

# If none found, install certificate
# Double-click your .p12 certificate file

# Or use the code signing script
./scripts/code_signing.sh --setup --certificate path/to/cert.p12
```

### Provisioning profile issues

**Problem:** `No provisioning profile found`

**Solution:**
```bash
# List installed profiles
ls ~/Library/MobileDevice/Provisioning\ Profiles/

# Install profile (copy to directory)
cp YourProfile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/

# Or use Xcode to download profiles
# Xcode > Preferences > Accounts > Download Manual Profiles
```

### Code signing for simulator builds

**Problem:** Code signing errors when building for simulator

**Solution:**
```bash
# Simulator builds don't require signing
# The build scripts disable signing for simulator builds automatically
# If you encounter issues, verify you're using the correct destination
```

## Test Failures

### Tests fail in CI but pass locally

**Common Causes:**
1. Different Xcode versions
2. Missing test data
3. Environment differences
4. Timing issues

**Solution:**
```bash
# Match Xcode version in CI
sudo xcode-select -s /Applications/Xcode_15.0.app

# Run tests with same configuration as CI
./one_click_pipeline.sh --platform ios --configuration Release

# Disable parallel testing if timing issues
# Edit config/pipeline_config.yaml:
testing:
  parallel_testing: false
```

### Simulator not found

**Problem:** `Unable to find a destination matching the provided destination specifier`

**Solution:**
```bash
# List available simulators
xcrun simctl list devices available

# Use an available simulator
./one_click_pipeline.sh --platform ios --destination "platform=iOS Simulator,name=iPhone 14,OS=latest"
```

### Test timeout

**Problem:** Tests hang or timeout

**Solution:**
```bash
# Increase timeout in config/pipeline_config.yaml
advanced:
  test_timeout: 60  # Increase from default 20

# Or disable parallel testing
testing:
  parallel_testing: false
```

## CI/CD Issues

### GitHub Actions: Certificate decoding fails

**Problem:** Certificate base64 decode error

**Solution:**
```bash
# Encode certificate correctly
base64 -i certificate.p12 -o certificate.txt

# Copy the entire output (including any line breaks)
# Add as GitHub secret: APPLE_CERTIFICATE_BASE64
```

### GitHub Actions: Keychain permission issues

**Problem:** Security unlock-keychain errors

**Solution:**
- Ensure `KEYCHAIN_PASSWORD` secret is set
- Check keychain creation step completes successfully
- Verify certificate import step doesn't fail

### GitHub Actions: Out of disk space

**Problem:** No space left on device

**Solution:**
```yaml
# Add cleanup step before build
- name: Free Disk Space
  run: |
    sudo rm -rf /usr/local/lib/android
    sudo rm -rf /usr/share/dotnet
    df -h
```

### Slack notifications not working

**Problem:** Notifications not received

**Solution:**
```bash
# Test webhook URL
curl -X POST "$SLACK_WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d '{"text": "Test notification"}'

# Verify URL is correct in .env
echo $SLACK_WEBHOOK_URL

# Check notification script
./scripts/notifications.sh
```

## Performance Issues

### Slow builds

**Solutions:**
```bash
# Use derived data caching
# Keep DerivedData between builds (don't clean unless necessary)

# Enable parallel building
# Add to xcodebuild flags: -parallelizeTargets

# Use ccache (for large projects)
brew install ccache
```

### Large log files

**Solution:**
```bash
# Clean old logs
./scripts/cleanup.sh --logs

# Set retention period (in days)
./scripts/cleanup.sh --logs --log-retention 7
```

### High memory usage

**Solution:**
```bash
# Disable parallel testing
testing:
  parallel_testing: false

# Reduce parallel targets
# Add to build command: -maximum-concurrent-test-simulator-destinations 2
```

## Getting More Help

### Enable verbose logging

```bash
./one_click_pipeline.sh --platform ios --verbose
```

### Check logs

```bash
# View latest log
tail -f logs/pipeline_*.log

# Search logs for errors
grep -i error logs/pipeline_*.log
```

### Verify environment

```bash
# Check Xcode version
xcodebuild -version

# Check Swift version
swift --version

# Check available simulators
xcrun simctl list devices

# Check code signing setup
./scripts/code_signing.sh --verify
```

### Still stuck?

1. Check the [Configuration Guide](configuration.md)
2. Review [Advanced Usage](advanced_usage.md)
3. Search existing [GitHub Issues](https://github.com/bholsinger09/AppleAutomat_OneClickTestPipeline/issues)
4. Open a new issue with:
   - Your configuration
   - Full error output
   - Steps to reproduce
   - Environment details (macOS version, Xcode version)
