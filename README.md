# openaudiostandardiOS

## Build Instructions

The project includes a tested build script that handles the entire build process. To build the project:

1. Clone the repository:
```bash
git clone https://github.com/ebowwa/openaudiostandardiOS.git
cd openaudiostandardiOS
```

2. Run the build script:
```bash
./build.sh
```

The build script will:
- Verify Xcode installation and version
- Clean the build directory
- Install dependencies (if using Swift Package Manager)
- Build the project for iOS simulator

### Requirements
- Xcode 14.0 or higher
- macOS 12.0 or higher
- Command Line Tools for Xcode

## Build Process

The project includes an automated build script (`build.sh`) that handles the entire build process:

### Prerequisites
- macOS
- Xcode 16.0 or later

### Build Script Features
- Automatically installs required tools (Homebrew, jq, XcodeGen)
- Cleans build artifacts and DerivedData
- Handles Swift Package dependencies
- Configures iOS simulator
- Generates Xcode project using XcodeGen
- Opens project in Xcode after build

### Quick Start
1. Make script executable:
```bash
chmod +x build.sh
```

2. Run the build:
```bash
./build.sh
```

Configuration can be modified in `build.config.json`.
