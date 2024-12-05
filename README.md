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
