#!/bin/bash
################################################################################
# Project Initializer - Quick start new Xcode projects with best practices
################################################################################

set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║              Xcode Project Quick Initializer                  ║${NC}"
echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get project details
read -p "Project Name: " project_name
read -p "Bundle ID (e.g., com.company.app): " bundle_id
read -p "Platform (1=iOS, 2=macOS, 3=Both): " platform_choice

echo ""
echo -e "${BOLD}Select Project Type:${NC}"
echo "  1. SwiftUI App"
echo "  2. UIKit App (Storyboard)"
echo "  3. UIKit App (Programmatic)"
echo "  4. Framework/Library"
echo ""
read -p "Choice: " project_type

# Create project directory
project_dir="$HOME/Documents/$project_name"

if [ -d "$project_dir" ]; then
    echo -e "${RED}Project directory already exists!${NC}"
    exit 1
fi

mkdir -p "$project_dir"
cd "$project_dir"

echo ""
echo -e "${GREEN}Creating project structure...${NC}"

# Initialize git
git init
echo -e "${GREEN}✓ Git initialized${NC}"

# Create .gitignore
cat > .gitignore << 'EOF'
# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/xcshareddata/
*.xcworkspace/*
!*.xcworkspace/contents.xcworkspacedata
!*.xcworkspace/xcshareddata/

# Build
build/
DerivedData/
*.ipa
*.app
*.dSYM.zip

# CocoaPods
Pods/
*.xcworkspace

# Carthage
Carthage/Build/

# SPM
.swiftpm/
.build/

# User-specific
*.xcuserstate
*.xcuserdatad/

# macOS
.DS_Store

# Fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output
EOF

echo -e "${GREEN}✓ .gitignore created${NC}"

# Create README
cat > README.md << EOF
# $project_name

## Description
A $(echo "$project_type" | sed 's/-/ /g') project built with Xcode and integrated with AppleAutomat DevOps automation.

## Requirements
- Xcode 16.0+
- iOS 16.0+ / macOS 15.0+ (depending on target platform)
- Swift 5.0+
- AppleAutomat DevOps Tools (optional, for automation)

## Setup
\`\`\`bash
git clone <repository-url>
cd $project_name
open $project_name.xcodeproj
\`\`\`

## Building
\`\`\`bash
# Debug build
xcodebuild -project $project_name.xcodeproj -scheme $project_name -configuration Debug

# Release build
xcodebuild -project $project_name.xcodeproj -scheme $project_name -configuration Release
\`\`\`

## Testing
\`\`\`bash
# Run all tests
xcodebuild test -project $project_name.xcodeproj -scheme $project_name

# Run specific test
xcodebuild test -project $project_name.xcodeproj -scheme $project_name -only-testing:$project_name/TestClassName
\`\`\`

## CI/CD
This project uses AppleAutomat pipeline for automated builds and testing.

### Quick Start with DevOps Tools
\`\`\`bash
# Use Xcode Quick Actions
./devops-tools/xcode-quick-actions.sh -a all -p $project_name.xcodeproj -s $project_name

# Or run the full pipeline
./one_click_pipeline.sh --platform $([ "$project_type" = "ios-app" ] && echo "ios" || echo "macos") --scheme $project_name
\`\`\`

## License
MIT License

Copyright (c) $(date +%Y) [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

echo -e "${GREEN}✓ README.md created${NC}"

# Create Fastfile
mkdir -p fastlane
cat > fastlane/Fastfile << EOF
default_platform(:ios)

platform :ios do
  desc "Run tests"
  lane :test do
    scan(
      project: "$project_name.xcodeproj",
      scheme: "$project_name",
      clean: true
    )
  end

  desc "Build app"
  lane :build do
    build_app(
      project: "$project_name.xcodeproj",
      scheme: "$project_name",
      clean: true
    )
  end
end
EOF

echo -e "${GREEN}✓ Fastlane configuration created${NC}"

# Create GitHub Actions workflow
mkdir -p .github/workflows
cat > .github/workflows/ci.yml << EOF
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode.app
    
    - name: Build
      run: |
        xcodebuild -project $project_name.xcodeproj \\
          -scheme $project_name \\
          -configuration Debug \\
          -destination 'platform=iOS Simulator,name=iPhone 16' \\
          CODE_SIGNING_REQUIRED=NO
    
    - name: Test
      run: |
        xcodebuild test -project $project_name.xcodeproj \\
          -scheme $project_name \\
          -destination 'platform=iOS Simulator,name=iPhone 16' \\
          CODE_SIGNING_REQUIRED=NO
EOF

echo -e "${GREEN}✓ GitHub Actions workflow created${NC}"

# Initial git commit
git add -A
git commit -m "Initial commit - Project setup with AppleAutomat integration"

echo -e "${GREEN}✓ Initial commit created${NC}"

echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}Project initialized successfully!${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BOLD}Location:${NC} $project_dir"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo "  1. cd $project_dir"
echo "  2. Create Xcode project manually or import existing"
echo "  3. git remote add origin <github-url>"
echo "  4. git push -u origin main"
echo ""
echo -e "${BOLD}AppleAutomat Integration:${NC}"
echo "  Run: $HOME/Documents/AppleDevOpsAutomate/one_click_pipeline.sh"
echo ""
