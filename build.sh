#!/bin/bash

# Exit on error
set -e

# Function to install Homebrew
install_homebrew() {
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# Function to install jq
install_jq() {
    echo "🔧 Installing jq using Homebrew..."
    brew install jq
}

# Function to install XcodeGen
install_xcodegen() {
    echo "🔧 Installing XcodeGen using Homebrew..."
    brew install xcodegen
}

# Check for Homebrew installation
if ! command -v brew &> /dev/null; then
    echo "⚠️ Homebrew not found. Installing Homebrew..."
    install_homebrew
fi

# Check for jq and install if needed
if ! command -v jq &> /dev/null; then
    echo "⚠️ jq not found. Installing jq..."
    install_jq
fi

# Check for XcodeGen and install if needed
if ! command -v xcodegen &> /dev/null; then
    echo "⚠️ XcodeGen not found. Installing XcodeGen..."
    install_xcodegen
fi

# Load configuration
CONFIG_FILE="build.config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file $CONFIG_FILE not found"
    exit 1
fi

echo "🚀 Starting AudioProcessorApp build process..."

# Read configuration values
REQUIRED_XCODE_VERSION=$(jq -r '.xcode.minimumVersion' "$CONFIG_FILE")
PROJECT_NAME=$(jq -r '.xcode.project.name' "$CONFIG_FILE")
PROJECT_SCHEME=$(jq -r '.xcode.project.scheme' "$CONFIG_FILE")
XCODEPROJ=$(jq -r '.xcode.project.xcodeproj' "$CONFIG_FILE")
SDK=$(jq -r '.build.sdk' "$CONFIG_FILE")
DEFAULT_SIMULATOR=$(jq -r '.build.simulator.defaultDevice' "$CONFIG_FILE")
CHECK_PACKAGE_MANAGER=$(jq -r '.dependencies.checkPackageManager' "$CONFIG_FILE")
PACKAGE_FILE=$(jq -r '.paths.packageFile' "$CONFIG_FILE")

# Check for Xcode installation
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode command line tools not found. Please install Xcode first."
    exit 1
fi

# Check for required minimum Xcode version
CURRENT_XCODE_VERSION=$(xcodebuild -version | grep "Xcode" | cut -d' ' -f2)
if [ "$(printf '%s\n' "$REQUIRED_XCODE_VERSION" "$CURRENT_XCODE_VERSION" | sort -V | head -n1)" != "$REQUIRED_XCODE_VERSION" ]; then
    echo "❌ Xcode version $REQUIRED_XCODE_VERSION or higher is required. Current version: $CURRENT_XCODE_VERSION"
    exit 1
fi

# Clean and remove existing build artifacts
echo "🧹 Cleaning build directory..."

# Remove DerivedData
DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
if [ -d "$DERIVED_DATA_PATH" ]; then
    echo "Removing DerivedData..."
    rm -rf "$DERIVED_DATA_PATH"/*
fi

# Remove build directory if it exists
BUILD_DIR="build"
if [ -d "$BUILD_DIR" ]; then
    echo "Removing existing build directory..."
    rm -rf "$BUILD_DIR"
fi

# Clean Xcode build
echo "Cleaning Xcode project..."
xcodebuild clean \
    -project "$XCODEPROJ" \
    -scheme "$PROJECT_SCHEME" \
    -quiet

# Install dependencies if using Swift Package Manager
if [ "$CHECK_PACKAGE_MANAGER" = "true" ] && [ -f "$PACKAGE_FILE" ]; then
    echo "📦 Installing Swift Package dependencies..."
    swift package clean
    swift package reset
    swift package resolve
fi

# Get available simulator
echo "🔍 Finding available iOS simulator..."
AVAILABLE_SIMULATOR=$(xcrun simctl list devices available -j | grep -o "\"name\" : \"$DEFAULT_SIMULATOR\"" | head -n 1 | grep -o "$DEFAULT_SIMULATOR")

if [ -z "$AVAILABLE_SIMULATOR" ]; then
    echo "⚠️ Default simulator not found, searching for any available simulator..."
    AVAILABLE_SIMULATOR=$(xcrun simctl list devices available -j | grep -o '"name" : "iPhone [0-9][0-9]*"' | head -n 1 | grep -o 'iPhone [0-9][0-9]*')
    
    if [ -z "$AVAILABLE_SIMULATOR" ]; then
        echo "❌ No available iOS simulator found"
        exit 1
    fi
fi

echo "📱 Using simulator: $AVAILABLE_SIMULATOR"

# Build for iOS with improved settings
echo "🏗️ Building for iOS..."
xcodebuild build \
    -project "$XCODEPROJ" \
    -scheme "$PROJECT_SCHEME" \
    -sdk "$SDK" \
    -destination "platform=iOS Simulator,name=$AVAILABLE_SIMULATOR" \
    -derivedDataPath "$BUILD_DIR" \
    -allowProvisioningUpdates \
    -resolvePackageDependencies \
    COMPILER_INDEX_STORE_ENABLE=NO \
    SWIFT_COMPILATION_MODE=wholemodule \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

echo "✅ Build completed successfully!"

# Generate Xcode project using XcodeGen
echo "🔨 Generating Xcode project with XcodeGen..."
if [ -f "project.yml" ]; then
    xcodegen generate
    echo "✅ XcodeGen completed successfully!"
else
    echo "⚠️ No project.yml found, skipping XcodeGen..."
fi

# Open the project in Xcode
echo "📱 Opening project in Xcode..."
open "$XCODEPROJ"
