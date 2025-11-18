# 🚀 AppleAutomat One-Click Test Pipeline

A comprehensive One-Click iOS/macOS Build & Test Pipeline designed for DevOps automation. This project provides a streamlined, automated workflow for building, testing, and deploying iOS and macOS applications with minimal manual intervention.

## ✨ Features

- **One-Click Execution**: Single command to build, test, and validate your iOS/macOS projects
- **Multi-Platform Support**: Seamlessly handles both iOS and macOS builds
- **Automated Testing**: Integrated XCTest execution with detailed reporting
- **macOS Automator Integration**: Launch pipelines directly from Finder with Automator workflows
- **CI/CD Ready**: GitHub Actions workflows included for continuous integration
- **Flexible Configuration**: YAML-based configuration for easy customization
- **Comprehensive Logging**: Detailed logs with timestamps and color-coded output
- **Notification System**: Slack/Email notifications for build status
- **Code Signing Management**: Automated provisioning profile and certificate handling
- **Clean Build Options**: Automatic cleanup of derived data and build artifacts

## 📋 Prerequisites

- macOS 12.0 or later
- Xcode 14.0 or later
- Command Line Tools installed: `xcode-select --install`
- Optional: [xcpretty](https://github.com/xcpretty/xcpretty) for better build output formatting

## 🔧 Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/bholsinger09/AppleAutomat_OneClickTestPipeline.git
   cd AppleAutomat_OneClickTestPipeline
   ```

2. **Make scripts executable**:
   ```bash
   chmod +x one_click_pipeline.sh
   chmod +x scripts/*.sh
   ```

3. **Configure your project**:
   ```bash
   cp config/pipeline_config.example.yaml config/pipeline_config.yaml
   cp .env.example .env
   ```
   Edit these files with your project-specific settings.

4. **Optional - Install xcpretty** (for better output):
   ```bash
   sudo gem install xcpretty
   ```

## 🚀 Quick Start

### Basic Usage

Run the complete pipeline for iOS:
```bash
./one_click_pipeline.sh --platform ios --scheme "YourAppScheme"
```

Run the complete pipeline for macOS:
```bash
./one_click_pipeline.sh --platform macos --scheme "YourAppScheme"
```

### Advanced Usage

```bash
# Run with specific configuration
./one_click_pipeline.sh --platform ios --scheme "MyApp" --configuration Release

# Run tests only (no build)
./one_click_pipeline.sh --platform ios --scheme "MyApp" --tests-only

# Clean build
./one_click_pipeline.sh --platform ios --scheme "MyApp" --clean

# Skip tests
./one_click_pipeline.sh --platform ios --scheme "MyApp" --skip-tests

# Run with custom workspace
./one_click_pipeline.sh --platform ios --workspace "MyApp.xcworkspace" --scheme "MyApp"
```

## 📁 Project Structure

```
AppleAutomat_OneClickTestPipeline/
├── README.md                          # This file
├── one_click_pipeline.sh              # Main entry point script
├── .env.example                       # Environment variables template
├── .gitignore                         # Git ignore file
│
├── config/                            # Configuration files
│   ├── pipeline_config.yaml           # Pipeline configuration
│   └── pipeline_config.example.yaml   # Configuration template
│
├── scripts/                           # Automation scripts
│   ├── build_ios.sh                   # iOS build automation
│   ├── build_macos.sh                 # macOS build automation
│   ├── run_tests.sh                   # Test execution
│   ├── code_signing.sh                # Code signing setup
│   ├── cleanup.sh                     # Cleanup utilities
│   ├── logger.sh                      # Logging utilities
│   └── notifications.sh               # Notification system
│
├── automator/                         # macOS Automator workflows
│   ├── OneClick_iOS_Build.workflow    # iOS build Automator
│   ├── OneClick_macOS_Build.workflow  # macOS build Automator
│   └── README.md                      # Automator setup guide
│
├── .github/                           # GitHub Actions workflows
│   └── workflows/
│       ├── ios_ci.yml                 # iOS CI pipeline
│       ├── macos_ci.yml               # macOS CI pipeline
│       └── release.yml                # Release automation
│
├── docs/                              # Documentation
│   ├── configuration.md               # Configuration guide
│   ├── troubleshooting.md             # Common issues and solutions
│   └── advanced_usage.md              # Advanced features
│
└── logs/                              # Build and test logs (auto-generated)
```

## ⚙️ Configuration

### Pipeline Configuration (config/pipeline_config.yaml)

```yaml
project:
  workspace: "YourApp.xcworkspace"
  scheme: "YourApp"
  
build:
  configuration: "Debug"
  clean_build: false
  derived_data_path: "./DerivedData"
  
testing:
  run_tests: true
  test_plan: "YourTestPlan"
  code_coverage: true
  parallel_testing: true
  
notifications:
  slack_webhook: "${SLACK_WEBHOOK_URL}"
  email: "${NOTIFICATION_EMAIL}"
```

### Environment Variables (.env)

```bash
# Project Settings
PROJECT_PATH="/path/to/your/project"
SCHEME_NAME="YourAppScheme"

# Code Signing
DEVELOPMENT_TEAM="YOUR_TEAM_ID"
PROVISIONING_PROFILE="YOUR_PROFILE_NAME"

# Notifications
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
NOTIFICATION_EMAIL="your-email@example.com"

# Build Settings
BUILD_CONFIGURATION="Debug"
DERIVED_DATA_PATH="./DerivedData"
```

## 🔄 Using with Automator

The project includes macOS Automator workflows for true one-click execution:

1. Navigate to the `automator/` directory
2. Double-click `OneClick_iOS_Build.workflow` or `OneClick_macOS_Build.workflow`
3. Follow the setup instructions in `automator/README.md`
4. Once configured, you can run builds directly from Finder or add to your toolbar

## 🤖 CI/CD Integration

### GitHub Actions

The project includes ready-to-use GitHub Actions workflows:

- **iOS CI** (`.github/workflows/ios_ci.yml`): Runs on every push/PR
- **macOS CI** (`.github/workflows/macos_ci.yml`): Runs on every push/PR
- **Release** (`.github/workflows/release.yml`): Automated release creation

Configure secrets in your GitHub repository:
- `APPLE_CERTIFICATE_BASE64`
- `APPLE_CERTIFICATE_PASSWORD`
- `PROVISIONING_PROFILE_BASE64`
- `KEYCHAIN_PASSWORD`
- `SLACK_WEBHOOK_URL` (optional)

## 📊 Output and Logs

- Build logs are saved to `logs/build_YYYYMMDD_HHMMSS.log`
- Test results are saved to `logs/test_results_YYYYMMDD_HHMMSS.log`
- XCTest results are available in the DerivedData directory
- Console output includes color-coded status messages

## 🛠️ Troubleshooting

### Common Issues

**Issue**: "xcodebuild: command not found"
- **Solution**: Install Xcode Command Line Tools: `xcode-select --install`

**Issue**: Code signing errors
- **Solution**: Verify your team ID and provisioning profiles in `.env` file

**Issue**: Tests failing in CI but passing locally
- **Solution**: Check that all test dependencies are included in your CI environment

For more troubleshooting tips, see `docs/troubleshooting.md`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**Ben Holsinger**
- GitHub: [@bholsinger09](https://github.com/bholsinger09)

## 🙏 Acknowledgments

- Thanks to the Xcode build automation community
- Inspired by modern DevOps practices
- Built for developers who value automation and efficiency

## 📚 Additional Resources

- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [xcodebuild Man Page](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [GitHub Actions for iOS](https://docs.github.com/en/actions/guides/building-and-testing-swift)

---

Made with ❤️ for iOS/macOS DevOps automation
