# Contributing to Truvideo iOS SDK

Thank you for your interest in contributing and welcome to the Truvideo iOS SDK community! 🚀

This guide describes the many ways to contribute to Truvideo iOS SDK and outlines the preferred workflow for development.

## Contents

- [Contributing code](#contributing-code)
- [Breaking Changes](#breaking-changes)
- [Development Guide](#development-guide)
  - [Getting started](#getting-started)
  - [Developing](#developing)
  - [Style Guide](#style-guide)
  - [Testing](#testing)
  - [Viewing Code Coverage](#viewing-code-coverage)
  - [Opening a pull request](#opening-a-pull-request)


## Contributing code

Before starting work on a contribution, coordinate with the internal team to ensure alignment on priorities and approach. Review existing issues and planned work to avoid duplication. If your idea or task is not already tracked, document it clearly and discuss with relevant team members as needed. Collaboration and early feedback help ensure efficient and high-quality contributions.

### Breaking Changes

Truvideo's release schedule is designed to reduce the amount of breaking changes that developers have to deal with. Ideally, breaking changes should be avoided when making a contribution.

### Using GitHub pull requests

All submissions, including submissions by project members, require review. We use GitHub pull requests for this purpose. Refer to [GitHub Help](https://help.github.com/articles/about-pull-requests/) for more information on using pull requests. If you're ready to open a pull request, check that you have completed all of the steps outlined in the [Opening a pull request](#opening-a-pull-request) section.

## Development Guide

The majority of the remaining portion of this guide is dedicated to detailing the preferred workflow for Truvideo iOS SDK development.

### Getting started

To develop Truvideo iOS SDK software, install:

- **Xcode 15.0+** (iOS 15.0+ deployment target)
- **XcodeGen** - Install via Homebrew: `brew install xcodegen`
- **SwiftLint** - Install via Homebrew: `brew install swiftlint`
- **swift-format** - Install via Homebrew: `brew install swift-format`
- **Make** - Usually pre-installed on macOS

Next, clone the Truvideo iOS SDK repo:

```bash
git clone git@github.com:Truvideo/truvideo-ios-sdk.git
cd truvideo-ios-sdk
```

Once the necessary tools have been installed and the project has been cloned, continue on to the preferred development workflow.

### Developing

The workflow for library development is different from application development. For Truvideo iOS SDK development, we develop using the same tools we use to distribute the SDK.

#### XcodeGen Workflow

Our preferred development workflow uses XcodeGen to generate the Xcode project:

```bash
# Generate Xcode project, build all frameworks, and open Xcode
make genbuild
```

This will:
1. Generate the Xcode project using XcodeGen
2. Build all frameworks in dependency order
3. Open Xcode automatically

For individual framework development:

```bash
# Build specific framework
make framework SCHEME=Core
make framework SCHEME=Networking
# Available schemes: Core, CoreDataUtilities, DI, Networking, Telemetry, Utilities
```

### Style Guide

This code in this repo is styled in accordance with [swift-format](https://github.com/apple/swift-format) conventions and our comprehensive [Swift Style Guide](docs/swift-style-guide.md).

#### Styling your code

All code is automatically formatted on build using swift-format, but you can also run it manually:

```bash
# Format all Swift files in the project
swift-format format -r Libraries/Internal -i

# Format specific files or directories
swift-format format -i Libraries/Internal/Core/Sources/
swift-format format -i Libraries/Internal/Networking/Sources/Request/Request.swift
```

If your PR is failing CI due to style issues, please run the formatting command above. If the formatting tool is not working, ensure you have installed swift-format as outlined in the [Getting Started](#getting-started) section.

#### Apple development style guides and resources

Refer to the following resources when writing Swift code:

- [Our Swift Style Guide](docs/swift-style-guide.md)
- [Swift's API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

### Testing

Tests are an essential part of building Truvideo iOS SDK. Many of the tests run as part of our continuous integration (CI) setup with GitHub Actions.

**Important Testing Requirements:**
- **All files must have tests with at least 90% code coverage**
- Fixing a bug? Add a test to catch potential regressions in the future
- Adding a new feature? Add tests to test the new or modified APIs
- Tests serve as documentation for how APIs should be used

#### Running Tests

```bash
# Run all unit tests
make test

# Run tests in Xcode
# Select a scheme and press Cmd+U to build a component and run its unit tests
```

#### Viewing Code Coverage

When creating tests, it's helpful to verify that certain codepaths are indeed getting tested. Xcode has a built-in code coverage tool that makes it easy to know what codepaths are run.

To enable code coverage:
1. Navigate from Product → Scheme ➞ Edit Scheme or use the ⌥⌘U keyboard shortcut
2. Select the Options tab and check the Code Coverage box
3. Run your tests to see coverage reports

**Remember: All contributions must maintain at least 90% code coverage.**

### Opening a pull request

Before opening a pull request (PR), ensure that your contribution meets the following criteria:

#### Commit Message Standards

We follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code (white-space, formatting, etc)
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools

**Scopes are required** when opening a PR. Scopes indicate the affected area (e.g., `core`, `networking`, `telemetry`) and help the changelog generator and reviewers quickly identify what was changed.

**Examples:**
```
feat(networking): add support for custom request interceptors
fix(core): resolve memory leak in dependency injection
docs: update API documentation for Core framework
test(telemetry): add unit tests for upload processor
```

#### PR Requirements

1. **A descriptive PR description** has been written that explains the purpose of this contribution
2. **The committed code has been styled** in accordance with this repo's style guidelines using swift-format
3. **All files have tests with at least 90% code coverage**
4. **Unit and/or integration tests have been added or updated** to test and validate the contribution's changes
5. **Commit messages follow Conventional Commits** format
6. **Code passes SwiftLint**: `make lint`
7. **All tests pass**: `make test`
