# macOS Automator Workflows

This directory contains macOS Automator workflows for one-click execution of the build and test pipeline directly from Finder.

## 🎯 Overview

Automator workflows allow you to execute complex build and test processes with a single click, making them perfect for DevOps automation on macOS.

## 📦 Available Workflows

### 1. OneClick iOS Build & Test
**File:** `OneClick_iOS_Build.workflow`

Executes the complete iOS build and test pipeline with default settings.

### 2. OneClick macOS Build & Test
**File:** `OneClick_macOS_Build.workflow`

Executes the complete macOS build and test pipeline with default settings.

### 3. Quick iOS Test
**File:** `Quick_iOS_Test.workflow`

Runs iOS tests only (skips the build step for faster execution).

### 4. Quick macOS Test
**File:** `Quick_macOS_Test.workflow`

Runs macOS tests only (skips the build step for faster execution).

## 🔧 Setup Instructions

### Option 1: Double-Click to Run

1. Navigate to the `automator/` directory in Finder
2. Double-click any `.workflow` file
3. Click "Run" in the Automator window that opens

### Option 2: Install as Quick Action

1. Double-click a `.workflow` file
2. In Automator, go to **File > Export...**
3. Choose a location (recommended: Desktop or Applications)
4. The workflow will now appear in Finder's Services menu

### Option 3: Add to Finder Toolbar

1. Open a `.workflow` file in Automator
2. Save it as an Application (File > Export > File Format: Application)
3. Drag the application to your Finder toolbar for quick access

### Option 4: Create Keyboard Shortcut

1. Open **System Preferences > Keyboard > Shortcuts > Services**
2. Find your workflow in the list
3. Click "Add Shortcut" and assign a keyboard combination

## 📝 Creating Custom Workflows

To create your own workflow:

1. Open **Automator** (`/Applications/Automator.app`)
2. Create a new **Workflow** or **Quick Action**
3. Add a **Run Shell Script** action
4. Set the shell to `/bin/bash`
5. Set "Pass input" to "as arguments"
6. Add your script:

```bash
#!/bin/bash

# Change to project directory
cd /path/to/AppleDevOpsAutomate

# Run the pipeline
./one_click_pipeline.sh --platform ios --scheme "YourApp"
```

7. Save the workflow

## 🎨 Workflow Templates

### Template: iOS Build with Notifications

```bash
#!/bin/bash

PROJECT_DIR="/path/to/AppleDevOpsAutomate"
cd "$PROJECT_DIR"

# Send start notification
osascript -e 'display notification "Starting iOS build..." with title "Build Pipeline"'

# Run pipeline
if ./one_click_pipeline.sh --platform ios --scheme "MyApp" --configuration Release; then
    osascript -e 'display notification "Build completed successfully!" with title "Build Pipeline" sound name "Glass"'
else
    osascript -e 'display notification "Build failed!" with title "Build Pipeline" sound name "Basso"'
fi
```

### Template: Clean Build

```bash
#!/bin/bash

PROJECT_DIR="/path/to/AppleDevOpsAutomate"
cd "$PROJECT_DIR"

# Clean before building
./one_click_pipeline.sh --platform ios --scheme "MyApp" --clean --configuration Release
```

### Template: Tests Only

```bash
#!/bin/bash

PROJECT_DIR="/path/to/AppleDevOpsAutomate"
cd "$PROJECT_DIR"

# Run tests only
./one_click_pipeline.sh --platform ios --scheme "MyApp" --tests-only
```

## 🚀 Advanced Usage

### Running with Environment Variables

```bash
#!/bin/bash

# Set environment variables
export SCHEME_NAME="MyApp"
export BUILD_CONFIGURATION="Release"
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK"

cd /path/to/AppleDevOpsAutomate

# Run pipeline
./one_click_pipeline.sh --platform ios --scheme "$SCHEME_NAME"
```

### Interactive Workflow (Prompt for Options)

```bash
#!/bin/bash

# Ask user for platform
PLATFORM=$(osascript -e 'display dialog "Select Platform:" buttons {"iOS", "macOS"} default button "iOS"' -e 'button returned of result')

# Convert to lowercase
PLATFORM=$(echo "$PLATFORM" | tr '[:upper:]' '[:lower:]')

cd /path/to/AppleDevOpsAutomate

# Run pipeline
./one_click_pipeline.sh --platform "$PLATFORM" --scheme "MyApp"
```

### Workflow with Progress Display

```bash
#!/bin/bash

cd /path/to/AppleDevOpsAutomate

# Show progress in Terminal
osascript -e 'tell application "Terminal" to do script "cd /path/to/AppleDevOpsAutomate && ./one_click_pipeline.sh --platform ios --scheme MyApp"'
```

## 📋 Troubleshooting

### Issue: "Permission Denied"

**Solution:** Make sure the main script is executable:
```bash
chmod +x /path/to/AppleDevOpsAutomate/one_click_pipeline.sh
chmod +x /path/to/AppleDevOpsAutomate/scripts/*.sh
```

### Issue: Workflow doesn't find the project

**Solution:** Use absolute paths in your workflow scripts instead of relative paths.

### Issue: Environment variables not loaded

**Solution:** Explicitly source the `.env` file in your workflow:
```bash
source /path/to/AppleDevOpsAutomate/.env
```

### Issue: Xcode command line tools not found

**Solution:** Add the Xcode path to your workflow:
```bash
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
```

## 🎯 Best Practices

1. **Use Absolute Paths**: Always use full paths to avoid directory issues
2. **Add Notifications**: Use `osascript` to show progress and results
3. **Error Handling**: Always check exit codes and handle failures
4. **Log Output**: Redirect output to log files for debugging
5. **Test First**: Test workflows manually before automating

## 📚 Additional Resources

- [Automator User Guide](https://support.apple.com/guide/automator/welcome/mac)
- [Shell Script Actions in Automator](https://support.apple.com/guide/automator/use-a-shell-script-action-autbbd4cc11c/mac)
- [AppleScript Basics](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/introduction/ASLR_intro.html)

## 💡 Tips

- **Keyboard Shortcuts**: Assign shortcuts to frequently used workflows
- **Finder Integration**: Add workflows to Finder's toolbar for easy access
- **Batch Processing**: Create workflows that run multiple pipelines in sequence
- **Scheduled Runs**: Use cron or launchd to schedule workflow execution

---

Need help? Check the main [README.md](../README.md) or open an issue on GitHub.
