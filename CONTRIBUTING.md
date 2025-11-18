# Contributing to Apple Automat One-Click Test Pipeline

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inspiring community for all. Please be respectful and constructive in your interactions.

### Expected Behavior

- Use welcoming and inclusive language
- Be respectful of differing viewpoints
- Gracefully accept constructive criticism
- Focus on what is best for the community

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- Clear, descriptive title
- Detailed steps to reproduce
- Expected vs actual behavior
- Environment details (macOS version, Xcode version)
- Relevant logs or screenshots

### Suggesting Enhancements

Enhancement suggestions are welcome! Please include:

- Clear description of the enhancement
- Use cases and benefits
- Possible implementation approach
- Any potential drawbacks

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly
5. Commit with clear messages (`git commit -m 'Add amazing feature'`)
6. Push to your fork (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Development Setup

### Prerequisites

- macOS 12.0 or later
- Xcode 14.0 or later
- Bash 4.0 or later
- Git

### Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/AppleAutomat_OneClickTestPipeline.git
cd AppleAutomat_OneClickTestPipeline

# Run setup
./setup.sh

# Create a branch for your work
git checkout -b feature/my-feature
```

### Testing Your Changes

```bash
# Test with a sample project
./one_click_pipeline.sh --platform ios --scheme "TestApp" --verbose

# Run all utility scripts
./scripts/cleanup.sh --all
./scripts/notifications.sh
```

## Coding Standards

### Shell Scripts

- Use `#!/bin/bash` shebang
- Use `set -euo pipefail` for error handling
- Add descriptive headers with purpose
- Use meaningful variable names in UPPER_CASE
- Include comments for complex logic
- Follow consistent indentation (4 spaces)

Example:
```bash
#!/bin/bash

###############################################################################
# Script Purpose
# Brief description of what the script does
###############################################################################

set -euo pipefail

# Constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_VALUE="default"

# Functions
function main() {
    # Function implementation
    echo "Hello, World!"
}

# Main execution
main "$@"
```

### YAML Configuration

- Use 2-space indentation
- Include comments for complex settings
- Group related settings together
- Use descriptive key names

### Documentation

- Update README.md if adding features
- Add entries to relevant docs/ files
- Include inline comments for complex code
- Provide usage examples

## Pull Request Process

### Before Submitting

1. **Test Thoroughly**: Test your changes with multiple scenarios
2. **Update Documentation**: Update relevant documentation
3. **Follow Standards**: Ensure code follows project standards
4. **Clean Commits**: Make atomic commits with clear messages
5. **Rebase if Needed**: Rebase on latest main if necessary

### PR Description

Include in your PR description:

- **Summary**: Brief description of changes
- **Motivation**: Why is this change needed?
- **Changes**: List of specific changes made
- **Testing**: How was this tested?
- **Screenshots**: If applicable, include before/after screenshots

### Review Process

1. Maintainers will review your PR
2. Address any requested changes
3. Once approved, your PR will be merged
4. Thank you for your contribution!

## Commit Message Guidelines

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```
feat(build): add support for custom build destinations

Add --destination flag to allow users to specify custom build destinations
for iOS and macOS builds.

Closes #123
```

```
fix(tests): resolve timeout issues in parallel testing

Increase default test timeout from 20 to 30 minutes to prevent
timeouts on slower CI runners.

Fixes #456
```

## Project Structure

Understanding the project structure:

```
AppleDevOpsAutomate/
├── one_click_pipeline.sh       # Main entry point
├── scripts/                    # All automation scripts
│   ├── build_ios.sh           # iOS build logic
│   ├── build_macos.sh         # macOS build logic
│   ├── run_tests.sh           # Test execution
│   ├── logger.sh              # Logging utilities
│   ├── notifications.sh       # Notification system
│   ├── cleanup.sh             # Cleanup utilities
│   └── code_signing.sh        # Code signing setup
├── config/                     # Configuration files
├── .github/workflows/          # CI/CD workflows
├── docs/                       # Documentation
└── automator/                  # macOS Automator workflows
```

## Areas for Contribution

We especially welcome contributions in:

- **Platform Support**: Android, Windows support
- **CI/CD**: Additional CI/CD platform integrations
- **Testing**: Enhanced test reporting and coverage
- **Documentation**: Improved guides and examples
- **Performance**: Build optimization techniques
- **Integrations**: Third-party tool integrations

## Questions?

Feel free to:
- Open an issue for discussion
- Join our community discussions
- Reach out to maintainers

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Apple Automat One-Click Test Pipeline! 🎉
