# TruvideoSDK

A modular iOS SDK built with Swift, featuring multiple internal frameworks for different functionalities.

## Project Structure

```
truvideo-ios-sdk/
├── Libraries/
│   └── Internal/
│       ├── Core/                 # Core functionality and utilities
│       ├── CoreDataUtilities/    # Core Data helper utilities
│       ├── DI/                   # Dependency injection system
│       ├── Networking/           # Network layer and HTTP client
│       ├── Telemetry/            # Analytics and telemetry system
│       └── Utilities/            # Common utilities and extensions
├── project.yml                   # XcodeGen configuration
├── Makefile                      # Build automation
└── README.md                     # This file
```

## Prerequisites

- **Xcode 15.0+** (iOS 15.0+ deployment target)
- **XcodeGen** - Install via Homebrew: `brew install xcodegen`
- **SwiftLint** - Install via Homebrew: `brew install swiftlint`
- **Make** - Usually pre-installed on macOS

## Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd truvideo-ios-sdk
```

### 2. Generate and Build
```bash
# Generate Xcode project, build all frameworks, and open Xcode
make genbuild
```

That's it! The project will be generated, all frameworks built, and Xcode will open automatically.

## Available Commands

### Project Generation
```bash
make generate          # Generate Xcode project using XcodeGen
make genbuild          # Generate, build, and open Xcode project
```

### Building
```bash
make build             # Build all frameworks in dependency order
make framework SCHEME=Core          # Build specific framework
make framework SCHEME=Utilities     # Build specific framework
make framework SCHEME=Networking    # Build specific framework
# Available schemes: Core, CoreDataUtilities, DI, Networking, Telemetry, Utilities
```

### Testing
```bash
make test              # Run all unit tests
```

### Development Workflows
```bash
make dev               # Clean, generate, and build
make all               # Generate, build, and test (CI workflow)
```

### Utilities
```bash
make clean             # Clean generated files
make lint              # Run SwiftLint
make open              # Open Xcode project
make help              # Show all available commands
```

## Framework Dependencies

The frameworks have the following dependency order:

1. **Utilities** - No dependencies
2. **Core** - Depends on Utilities
3. **CoreDataUtilities** - Depends on Utilities
4. **DI** - No dependencies
5. **Networking** - Depends on Utilities
6. **Telemetry** - Depends on Utilities

## Building Individual Frameworks

### Build a Single Framework
```bash
# Build Core framework
make framework SCHEME=Core

# Build Utilities framework
make framework SCHEME=Utilities

# Build Networking framework
make framework SCHEME=Networking
```

### Build Dependencies First
```bash
# Build Utilities first (dependency)
make framework SCHEME=Utilities

# Then build frameworks that depend on it
make framework SCHEME=Core
make framework SCHEME=Networking
```

## XCFramework Creation

The `make framework SCHEME=<name>` command creates XCFrameworks that work on both device and simulator:

```bash
make framework SCHEME=Core
```

This will:
1. Build the framework for device (iphoneos)
2. Build the framework for simulator (iphonesimulator)
3. Create an XCFramework in `DerivedData/XCFrameworks/`

## Development Workflow

### Daily Development
```bash
# Start your day
make dev

# Work on a specific framework
make framework SCHEME=Core

# Run tests
make test

# Lint code
make lint
```

### CI/CD Pipeline
```bash
# Full CI workflow
make all
```

## Project Configuration

### XcodeGen (project.yml)
- Defines all frameworks, their sources, and dependencies
- Configures SwiftLint build phases
- Sets up schemes for each framework
- Includes AWS SDK Swift dependency for Telemetry

### SwiftLint
- Runs automatically on build for all frameworks
- Uses configuration from `.swiftlint.yml` in project root
- Custom rules for code quality enforcement

## Troubleshooting

### Build Issues
```bash
# Clean everything and start fresh
make clean
make dev
```

### XCFramework Issues
```bash
# Ensure frameworks are built with proper module settings
make framework SCHEME=Core
```

### Missing Dependencies
```bash
# Install required tools
brew install xcodegen swiftlint
```

## Contributing

1. Use the provided Makefile commands for all build operations
2. Ensure your code passes SwiftLint: `make lint`
3. Run tests before committing: `make test`
4. Follow the dependency order when building frameworks

## License
