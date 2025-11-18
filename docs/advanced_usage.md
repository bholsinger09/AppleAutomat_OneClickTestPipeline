# Advanced Usage Guide

Advanced features and workflows for the Apple Automat One-Click Test Pipeline.

## Table of Contents

- [Custom Build Configurations](#custom-build-configurations)
- [Advanced Testing](#advanced-testing)
- [Code Coverage](#code-coverage)
- [Custom Scripts](#custom-scripts)
- [Integration with Other Tools](#integration-with-other-tools)
- [Performance Optimization](#performance-optimization)

## Custom Build Configurations

### Multiple Schemes

Build different schemes in sequence:

```bash
#!/bin/bash
SCHEMES=("AppScheme" "ExtensionScheme" "TestsScheme")

for scheme in "${SCHEMES[@]}"; do
    ./one_click_pipeline.sh --platform ios --scheme "$scheme"
done
```

### Environment-Specific Builds

```bash
# Development
./one_click_pipeline.sh --platform ios --scheme "MyApp-Dev" --configuration Debug

# Staging
./one_click_pipeline.sh --platform ios --scheme "MyApp-Staging" --configuration Release

# Production
./one_click_pipeline.sh --platform ios --scheme "MyApp-Prod" --configuration Release
```

### Cross-Platform Builds

Build for both iOS and macOS:

```bash
#!/bin/bash

# Build iOS
./one_click_pipeline.sh --platform ios --scheme "MyApp" --configuration Release

# Build macOS
./one_click_pipeline.sh --platform macos --scheme "MyApp" --configuration Release
```

## Advanced Testing

### Selective Test Execution

Run specific test classes:

```bash
xcodebuild test \
  -scheme "MyApp" \
  -destination "platform=iOS Simulator,name=iPhone 15" \
  -only-testing:MyAppTests/LoginTests
```

### Test Plans

Create a test plan (`MyApp.xctestplan`) and reference it:

```yaml
# config/pipeline_config.yaml
testing:
  test_plan: "MyApp"
```

### UI Testing

Configure UI tests with specific settings:

```bash
./scripts/run_tests.sh \
  --platform ios \
  --scheme "MyApp" \
  --destination "platform=iOS Simulator,name=iPhone 15 Pro" \
  --no-parallel  # UI tests often need serial execution
```

### Performance Testing

```bash
# Enable performance metrics
xcodebuild test \
  -scheme "MyApp" \
  -destination "platform=iOS Simulator,name=iPhone 15" \
  -enableCodeCoverage YES \
  -enableThreadSanitizer YES \
  -enableAddressSanitizer YES
```

## Code Coverage

### Generate Coverage Reports

```bash
# Run tests with coverage
./one_click_pipeline.sh --platform ios --scheme "MyApp"

# View coverage report
xcrun xccov view --report --only-targets TestResults/TestResults.xcresult
```

### Export Coverage Data

```bash
# Export to JSON
xcrun xccov view --report --json TestResults/TestResults.xcresult > coverage.json

# Export to lcov format (for tools like Codecov)
xcrun xccov view --report TestResults/TestResults.xcresult --format lcov > coverage.lcov
```

### Coverage Thresholds

Create a script to enforce coverage minimums:

```bash
#!/bin/bash

COVERAGE=$(xcrun xccov view --report --only-targets TestResults/TestResults.xcresult | \
  grep "MyApp.app" | \
  awk '{print $4}' | \
  sed 's/%//')

THRESHOLD=80

if (( $(echo "$COVERAGE < $THRESHOLD" | bc -l) )); then
    echo "Coverage $COVERAGE% is below threshold $THRESHOLD%"
    exit 1
fi

echo "Coverage $COVERAGE% meets threshold"
```

## Custom Scripts

### Pre-Build Hook

Create `scripts/pre_build.sh`:

```bash
#!/bin/bash

echo "Running pre-build tasks..."

# Increment build number
agvtool next-version -all

# Generate build configuration
./scripts/generate_config.sh

# Run linter
swiftlint autocorrect
```

### Post-Build Hook

Create `scripts/post_build.sh`:

```bash
#!/bin/bash

echo "Running post-build tasks..."

# Upload to TestFlight
fastlane pilot upload

# Send notification
./scripts/notifications.sh "Build uploaded to TestFlight" "success"

# Archive logs
tar -czf logs/archive_$(date +%Y%m%d).tar.gz logs/*.log
```

### Integrate Hooks

Modify `one_click_pipeline.sh` to call hooks:

```bash
# Before build
if [ -f "${SCRIPTS_DIR}/pre_build.sh" ]; then
    bash "${SCRIPTS_DIR}/pre_build.sh"
fi

# After build
if [ -f "${SCRIPTS_DIR}/post_build.sh" ]; then
    bash "${SCRIPTS_DIR}/post_build.sh"
fi
```

## Integration with Other Tools

### Fastlane Integration

```ruby
# fastlane/Fastfile
lane :build_and_test do
  sh("../one_click_pipeline.sh --platform ios --scheme MyApp")
end

lane :deploy do
  build_and_test
  pilot
end
```

### SwiftLint Integration

```bash
# Add to pre-build hook
if command -v swiftlint &> /dev/null; then
    swiftlint lint --strict
fi
```

### Danger Integration

```ruby
# Dangerfile
has_app_changes = !git.modified_files.grep(/Sources/).empty?
has_test_changes = !git.modified_files.grep(/Tests/).empty?

if has_app_changes && !has_test_changes
  warn("This PR changes app code but doesn't include tests")
end

# Check code coverage
coverage = sh("xcrun xccov view --report --only-targets TestResults/TestResults.xcresult")
fail("Code coverage is too low") if coverage.to_f < 80.0
```

### SonarQube Integration

```bash
# Generate coverage report in SonarQube format
./scripts/sonar_coverage.sh

# Run SonarQube scanner
sonar-scanner \
  -Dsonar.projectKey=myapp \
  -Dsonar.sources=Sources \
  -Dsonar.swift.coverage.reportPath=coverage.xml
```

## Performance Optimization

### Parallel Builds

```bash
# Enable parallel targets
xcodebuild build \
  -scheme "MyApp" \
  -parallelizeTargets \
  -jobs 4
```

### Build Caching

```bash
# Use ccache for faster compilation
export CC="ccache clang"
export CXX="ccache clang++"

# Build
./one_click_pipeline.sh --platform ios
```

### Incremental Builds

```yaml
# config/pipeline_config.yaml
build:
  clean_build: false  # Don't clean unless necessary
  derived_data_path: "./DerivedData"  # Reuse derived data
```

### Distributed Testing

Run tests on multiple simulators:

```bash
#!/bin/bash

DEVICES=("iPhone 15" "iPhone 15 Pro" "iPad Pro")

for device in "${DEVICES[@]}"; do
    ./scripts/run_tests.sh \
      --platform ios \
      --scheme "MyApp" \
      --destination "platform=iOS Simulator,name=$device" &
done

wait
```

## Advanced CI/CD

### Matrix Builds

```yaml
# .github/workflows/ios_ci.yml
strategy:
  matrix:
    xcode: ['14.3', '15.0']
    ios: ['15.0', '16.0', '17.0']
    include:
      - xcode: '15.0'
        ios: '17.0'
```

### Conditional Workflows

```yaml
# Only run on specific branches
on:
  push:
    branches:
      - main
      - develop
      - release/*
```

### Artifact Management

```yaml
- name: Upload Build Artifacts
  uses: actions/upload-artifact@v3
  with:
    name: app-build
    path: |
      Build/
      TestResults/
    retention-days: 30
```

### Deployment Automation

```bash
#!/bin/bash

# Build for production
./one_click_pipeline.sh --platform ios --scheme "MyApp" --configuration Release

# Export IPA
xcodebuild -exportArchive \
  -archivePath Build/MyApp.xcarchive \
  -exportPath Build/Export \
  -exportOptionsPlist ExportOptions.plist

# Upload to App Store Connect
xcrun altool --upload-app \
  --type ios \
  --file Build/Export/MyApp.ipa \
  --username "$APPLE_ID" \
  --password "$APP_SPECIFIC_PASSWORD"
```

## Monitoring and Observability

### Build Metrics

```bash
#!/bin/bash

START=$(date +%s)

./one_click_pipeline.sh --platform ios --scheme "MyApp"

END=$(date +%s)
DURATION=$((END - START))

# Send metrics to monitoring service
curl -X POST "https://metrics.example.com/api/builds" \
  -H "Content-Type: application/json" \
  -d "{\"duration\": $DURATION, \"status\": \"success\"}"
```

### Log Aggregation

```bash
# Send logs to centralized logging
cat logs/pipeline_*.log | \
  jq -R -s -c 'split("\n") | map(select(length > 0))' | \
  curl -X POST "https://logs.example.com/api/ingest" \
    -H "Content-Type: application/json" \
    -d @-
```

## Best Practices

1. **Version Control**: Keep configuration in version control
2. **Secrets Management**: Use environment variables for sensitive data
3. **Incremental Builds**: Avoid clean builds unless necessary
4. **Parallel Execution**: Use parallel testing when possible
5. **Caching**: Cache dependencies and derived data
6. **Monitoring**: Track build times and success rates
7. **Documentation**: Document custom workflows and configurations

## Further Reading

- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [xcodebuild Man Page](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
- [GitHub Actions for iOS](https://docs.github.com/en/actions/guides/building-and-testing-swift)
- [Fastlane Documentation](https://docs.fastlane.tools/)
