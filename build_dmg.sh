#!/bin/bash

# AutoQuill AI - Build and Package DMG Script
# This script builds the Flutter app for macOS and creates a DMG for distribution

set -e  # Exit on any error

# Configuration
APP_NAME="AutoQuill AI"
BUNDLE_NAME="autoquill_ai"
VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
BUILD_NUMBER=$(grep "version:" pubspec.yaml | sed 's/.*+//')
DMG_NAME="AutoQuill_AI_v${VERSION}"
BACKGROUND_IMAGE="assets/icons/with_bg/autoquill_centered_1024_rounded.png"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
print_status "Checking prerequisites..."

if ! command_exists flutter; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

if ! command_exists create-dmg; then
    print_warning "create-dmg is not installed. Installing via Homebrew..."
    if command_exists brew; then
        brew install create-dmg
    else
        print_error "Homebrew is not installed. Please install create-dmg manually:"
        print_error "npm install -g create-dmg"
        exit 1
    fi
fi

print_success "Prerequisites check completed"

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean
rm -rf build/macos/Build/Products/Release/
rm -rf dist/
mkdir -p dist

# Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get

# Generate launcher icons
print_status "Generating launcher icons..."
flutter pub run flutter_launcher_icons

# Build the app for release
print_status "Building Flutter app for macOS release..."
flutter build macos --release

# Check if build was successful
if [ ! -d "build/macos/Build/Products/Release/${APP_NAME}.app" ]; then
    print_error "Build failed - app bundle not found"
    exit 1
fi

print_success "Flutter build completed successfully"

# Copy the app to dist directory
print_status "Preparing app bundle for packaging..."
cp -R "build/macos/Build/Products/Release/${APP_NAME}.app" "dist/${APP_NAME}.app"

# Code signing (optional - uncomment and modify if you have a developer certificate)
# print_status "Code signing the app..."
# DEVELOPER_ID="Developer ID Application: Your Name (TEAM_ID)"
# codesign --force --deep --sign "$DEVELOPER_ID" "dist/${APP_NAME}.app"
# print_success "Code signing completed"

# Create DMG
print_status "Creating DMG installer..."

# DMG creation with create-dmg
create-dmg \
  --volname "${APP_NAME}" \
  --volicon "${BACKGROUND_IMAGE}" \
  --window-pos 200 120 \
  --window-size 800 600 \
  --icon-size 100 \
  --icon "${APP_NAME}.app" 200 190 \
  --hide-extension "${APP_NAME}.app" \
  --app-drop-link 600 185 \
  --hdiutil-quiet \
  "dist/${DMG_NAME}.dmg" \
  "dist/"

# Check if DMG was created successfully
if [ -f "dist/${DMG_NAME}.dmg" ]; then
    print_success "DMG created successfully: dist/${DMG_NAME}.dmg"
    
    # Get file size
    DMG_SIZE=$(du -h "dist/${DMG_NAME}.dmg" | cut -f1)
    print_status "DMG size: ${DMG_SIZE}"
    
    # Optional: Open the dist folder
    print_status "Opening dist folder..."
    open dist/
    
else
    print_error "Failed to create DMG"
    exit 1
fi

# Cleanup temporary files
print_status "Cleaning up temporary files..."
rm -rf "dist/${APP_NAME}.app"

print_success "Build and packaging completed successfully!"
print_status "Your distributable DMG is ready at: dist/${DMG_NAME}.dmg"

# Optional: Notarization reminder (for distribution outside App Store)
print_warning "Note: For distribution outside the App Store, you may need to:"
print_warning "1. Code sign the app with a Developer ID certificate"
print_warning "2. Notarize the DMG with Apple"
print_warning "3. Staple the notarization ticket to the DMG"

echo ""
print_success "🎉 AutoQuill AI DMG packaging complete!" 