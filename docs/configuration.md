# Configuration Guide

This guide explains how to configure the Apple Automat One-Click Test Pipeline for your specific project.

## Quick Start Configuration

1. **Copy Example Files**
   ```bash
   cp .env.example .env
   cp config/pipeline_config.example.yaml config/pipeline_config.yaml
   ```

2. **Edit `.env` file** with your project-specific values

3. **Edit `config/pipeline_config.yaml`** for advanced settings

## Environment Variables (.env)

### Required Variables

```bash
# Your Xcode project path
PROJECT_PATH="/path/to/your/project"

# Your app scheme name
SCHEME_NAME="YourAppScheme"

# Your Apple Developer Team ID
DEVELOPMENT_TEAM="ABC123DEF4"
```

### Optional Variables

```bash
# Build configuration
BUILD_CONFIGURATION="Debug"

# Code signing
CODE_SIGN_IDENTITY="Apple Development"
PROVISIONING_PROFILE="YourApp Development Profile"

# Notifications
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
NOTIFICATION_EMAIL="your-email@example.com"
```

## Pipeline Configuration (pipeline_config.yaml)

### Project Settings

```yaml
project:
  workspace: "${PROJECT_PATH}/YourApp.xcworkspace"
  scheme: "${SCHEME_NAME}"
  team_id: "${DEVELOPMENT_TEAM}"
```

**Note:** Use `workspace` for projects with CocoaPods or SPM, or `project` for standalone projects.

### Build Settings

```yaml
build:
  configuration: "Debug"      # Debug or Release
  clean_build: false          # Clean before building
  derived_data_path: "./DerivedData"
  archive: false              # Create archive
  export_path: "./Build"
```

### iOS Specific Settings

```yaml
ios:
  deployment_target: "15.0"
  simulator_destination: "platform=iOS Simulator,name=iPhone 15,OS=latest"
  provisioning_profile: "${PROVISIONING_PROFILE}"
```

### macOS Specific Settings

```yaml
macos:
  deployment_target: "12.0"
  destination: "platform=macOS"
```

### Testing Configuration

```yaml
testing:
  run_tests: true             # Enable/disable tests
  test_plan: ""               # Optional test plan name
  code_coverage: true         # Enable code coverage
  parallel_testing: true      # Run tests in parallel
  result_bundle_path: "./TestResults"
```

### Notifications

```yaml
notifications:
  enabled: true
  slack_webhook: "${SLACK_WEBHOOK_URL}"
  email: "${NOTIFICATION_EMAIL}"
  events:
    - "success"
    - "failure"
```

## Finding Your Configuration Values

### Team ID

1. Open Xcode
2. Select your project
3. Go to "Signing & Capabilities"
4. Your Team ID is shown under "Team"

Or via command line:
```bash
security find-certificate -a | grep "Developer ID"
```

### Scheme Name

List all schemes:
```bash
xcodebuild -list
```

### Provisioning Profile

List installed profiles:
```bash
ls ~/Library/MobileDevice/Provisioning\ Profiles/
```

Or view profile details:
```bash
security cms -D -i ~/Library/MobileDevice/Provisioning\ Profiles/PROFILE.mobileprovision
```

### Bundle Identifier

Found in your project's Info.plist or in Xcode under "General" > "Identity"

## Common Configuration Patterns

### Development Build

```yaml
build:
  configuration: "Debug"
  clean_build: false
  
testing:
  run_tests: true
  parallel_testing: true
```

### Release Build

```yaml
build:
  configuration: "Release"
  clean_build: true
  archive: true
  
testing:
  run_tests: true
  code_coverage: false
```

### Quick Test Run

```yaml
build:
  clean_build: false
  
testing:
  run_tests: true
  parallel_testing: true
  code_coverage: false
```

### CI/CD Build

```yaml
build:
  configuration: "Release"
  clean_build: true
  archive: true
  
testing:
  run_tests: true
  code_coverage: true
  parallel_testing: true
  
notifications:
  enabled: true
  events:
    - "success"
    - "failure"
```

## Environment-Specific Configurations

You can create multiple configuration files:

```bash
config/
  ├── pipeline_config.yaml          # Default
  ├── pipeline_config.dev.yaml      # Development
  ├── pipeline_config.staging.yaml  # Staging
  └── pipeline_config.prod.yaml     # Production
```

Then specify which to use:
```bash
./one_click_pipeline.sh --config config/pipeline_config.prod.yaml
```

## Validation

Test your configuration:

```bash
# Dry run (check configuration without building)
./one_click_pipeline.sh --platform ios --scheme "MyApp" --verbose

# Quick test
./one_click_pipeline.sh --platform ios --scheme "MyApp" --tests-only
```

## Security Best Practices

1. **Never commit `.env`** - It's in `.gitignore` by default
2. **Use environment variables** for sensitive data
3. **Encrypt certificates** when storing in CI/CD
4. **Rotate credentials regularly**
5. **Use different credentials** for different environments

## Troubleshooting

### Configuration not loading

- Verify file paths are correct
- Check YAML syntax (indentation matters)
- Ensure environment variables are exported

### Code signing issues

- Verify Team ID is correct
- Check provisioning profile is installed
- Ensure certificate is in keychain

### Build fails

- Verify scheme name is correct
- Check workspace/project path
- Ensure Xcode is properly installed

## Getting Help

If you encounter issues:
1. Check [troubleshooting.md](troubleshooting.md)
2. Run with `--verbose` flag for detailed output
3. Review logs in `logs/` directory
4. Open an issue on GitHub
