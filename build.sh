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

# Build for iOS
echo "🏗️ Building for iOS..."
xcodebuild build -project AudioProcessorApp.xcodeproj -scheme AudioProcessorApp -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 14'

echo "✅ Build completed successfully!"
