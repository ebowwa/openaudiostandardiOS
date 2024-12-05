#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting AudioProcessorApp build process..."

# Check for Xcode installation
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode command line tools not found. Please install Xcode first."
    exit 1
fi

# Check for required minimum Xcode version
REQUIRED_XCODE_VERSION="14.0"
CURRENT_XCODE_VERSION=$(xcodebuild -version | grep "Xcode" | cut -d' ' -f2)
if [ "$(printf '%s\n' "$REQUIRED_XCODE_VERSION" "$CURRENT_XCODE_VERSION" | sort -V | head -n1)" != "$REQUIRED_XCODE_VERSION" ]; then
    echo "❌ Xcode version $REQUIRED_XCODE_VERSION or higher is required. Current version: $CURRENT_XCODE_VERSION"
    exit 1
fi

# Clean build directory
echo "🧹 Cleaning build directory..."
xcodebuild clean -project AudioProcessorApp.xcodeproj -scheme AudioProcessorApp

# Install dependencies if using Swift Package Manager
if [ -f "Package.swift" ]; then
    echo "📦 Installing Swift Package dependencies..."
    swift package resolve
fi

# Get available simulator
echo "🔍 Finding available iOS simulator..."
AVAILABLE_SIMULATOR=$(xcrun simctl list devices available -j | grep -o '"name" : "iPhone [0-9][0-9]*"' | head -n 1 | grep -o 'iPhone [0-9][0-9]*')

if [ -z "$AVAILABLE_SIMULATOR" ]; then
    echo "❌ No available iOS simulator found"
    exit 1
fi

echo "📱 Using simulator: $AVAILABLE_SIMULATOR"

# Build for iOS
echo "🏗️ Building for iOS..."
xcodebuild build -project AudioProcessorApp.xcodeproj -scheme AudioProcessorApp -sdk iphonesimulator -destination "platform=iOS Simulator,name=$AVAILABLE_SIMULATOR"

echo "✅ Build completed successfully!"
