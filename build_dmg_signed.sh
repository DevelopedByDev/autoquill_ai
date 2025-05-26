#!/bin/bash

# AutoQuill - Build and Package DMG Script with Code Signing
# This script builds, signs, and packages the AutoQuill app for distribution

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="AutoQuill"
VERSION="1.0.0"
BUNDLE_ID="com.divyansh-lalwani.autoquill-ai"
BUILD_DIR="build/macos/Build/Products/Release"
DMG_NAME="AutoQuill_v${VERSION}"

# Code signing identities (update these with your actual certificate names)
DEVELOPER_ID_APP="Developer ID Application: Divyansh Lalwani (562STT95YC)"
DEVELOPER_ID_INSTALLER="Developer ID Installer: Divyansh Lalwani (562STT95YC)"

# Entitlements file path
ENTITLEMENTS_FILE="macos/Runner/Release.entitlements"

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

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check if Flutter is installed
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    print_success "Flutter found: $(flutter --version | head -n1)"
    
    # Check if create-dmg is installed
    if ! command -v create-dmg &> /dev/null; then
        print_warning "create-dmg not found. Installing via Homebrew..."
        if command -v brew &> /dev/null; then
            brew install create-dmg
            print_success "create-dmg installed successfully"
        else
            print_error "Homebrew not found. Please install create-dmg manually:"
            print_error "brew install create-dmg"
            exit 1
        fi
    else
        print_success "create-dmg found"
    fi
    
    # Check code signing certificates
    print_status "Checking code signing certificates..."
    if security find-identity -v -p codesigning | grep -q "$DEVELOPER_ID_APP"; then
        print_success "Developer ID Application certificate found"
    else
        print_error "Developer ID Application certificate not found: $DEVELOPER_ID_APP"
        print_error "Please install your Developer ID certificates from Apple Developer portal"
        exit 1
    fi
    
    # Check if entitlements file exists
    if [ ! -f "$ENTITLEMENTS_FILE" ]; then
        print_warning "Entitlements file not found. Creating default entitlements..."
        create_entitlements_file
    else
        print_success "Entitlements file found: $ENTITLEMENTS_FILE"
    fi
}

# Function to create entitlements file
create_entitlements_file() {
    mkdir -p "$(dirname "$ENTITLEMENTS_FILE")"
    cat > "$ENTITLEMENTS_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <false/>
    <key>com.apple.security.cs.allow-jit</key>
    <true/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <true/>
    <key>com.apple.security.device.microphone</key>
    <true/>
    <key>com.apple.security.automation.apple-events</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <key>com.apple.security.files.downloads.read-write</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.network.server</key>
    <true/>
</dict>
</plist>
EOF
    print_success "Created entitlements file: $ENTITLEMENTS_FILE"
}

# Function to clean previous builds
clean_build() {
    print_header "Cleaning Previous Builds"
    
    if [ -d "build" ]; then
        print_status "Removing build directory..."
        rm -rf build
        print_success "Build directory cleaned"
    fi
    
    if [ -f "${DMG_NAME}.dmg" ]; then
        print_status "Removing existing DMG..."
        rm -f "${DMG_NAME}.dmg"
        print_success "Existing DMG removed"
    fi
}

# Function to prepare Flutter project
prepare_flutter() {
    print_header "Preparing Flutter Project"
    
    print_status "Running flutter pub get..."
    flutter pub get
    print_success "Dependencies updated"
    
    print_status "Generating launcher icons..."
    if flutter packages pub run flutter_launcher_icons; then
        print_success "Launcher icons generated"
    else
        print_warning "Failed to generate launcher icons (continuing anyway)"
    fi
}

# Function to build the Flutter app
build_app() {
    print_header "Building Flutter App"
    
    print_status "Building macOS release version..."
    flutter build macos --release
    
    if [ -d "$BUILD_DIR/$APP_NAME.app" ]; then
        print_success "App built successfully: $BUILD_DIR/$APP_NAME.app"
        
        # Show app bundle size
        APP_SIZE=$(du -sh "$BUILD_DIR/$APP_NAME.app" | cut -f1)
        print_status "App bundle size: $APP_SIZE"
    else
        print_error "App build failed - app bundle not found"
        exit 1
    fi
}

# Function to sign the app bundle
sign_app() {
    print_header "Code Signing App Bundle"
    
    APP_PATH="$BUILD_DIR/$APP_NAME.app"
    
    print_status "Signing app bundle with Developer ID..."
    print_status "Certificate: $DEVELOPER_ID_APP"
    print_status "Entitlements: $ENTITLEMENTS_FILE"
    
    # Sign the app bundle
    codesign --force \
             --options runtime \
             --entitlements "$ENTITLEMENTS_FILE" \
             --sign "$DEVELOPER_ID_APP" \
             --deep \
             --timestamp \
             "$APP_PATH"
    
    if [ $? -eq 0 ]; then
        print_success "App bundle signed successfully"
    else
        print_error "Code signing failed"
        exit 1
    fi
    
    # Verify the signature
    print_status "Verifying code signature..."
    codesign --verify --deep --strict --verbose=2 "$APP_PATH"
    
    if [ $? -eq 0 ]; then
        print_success "Code signature verification passed"
    else
        print_error "Code signature verification failed"
        exit 1
    fi
    
    # Show signature details
    print_status "Signature details:"
    codesign -dv --verbose=4 "$APP_PATH" 2>&1 | head -10
}

# Function to create DMG
create_dmg() {
    print_header "Creating DMG Package"
    
    APP_PATH="$BUILD_DIR/$APP_NAME.app"
    
    print_status "Creating DMG with create-dmg..."
    
    create-dmg \
        --volname "$APP_NAME" \
        --volicon "$APP_PATH/Contents/Resources/AppIcon.icns" \
        --window-pos 200 120 \
        --window-size 800 400 \
        --icon-size 100 \
        --icon "$APP_NAME.app" 200 190 \
        --hide-extension "$APP_NAME.app" \
        --app-drop-link 600 185 \
        --background-color "#f0f0f0" \
        "${DMG_NAME}.dmg" \
        "$APP_PATH"
    
    if [ -f "${DMG_NAME}.dmg" ]; then
        DMG_SIZE=$(du -sh "${DMG_NAME}.dmg" | cut -f1)
        print_success "DMG created successfully: ${DMG_NAME}.dmg ($DMG_SIZE)"
    else
        print_error "DMG creation failed"
        exit 1
    fi
}

# Function to sign the DMG
sign_dmg() {
    print_header "Signing DMG Package"
    
    print_status "Signing DMG with Developer ID..."
    codesign --force \
             --sign "$DEVELOPER_ID_APP" \
             --timestamp \
             "${DMG_NAME}.dmg"
    
    if [ $? -eq 0 ]; then
        print_success "DMG signed successfully"
    else
        print_error "DMG signing failed"
        exit 1
    fi
    
    # Verify DMG signature
    print_status "Verifying DMG signature..."
    codesign --verify --deep --strict --verbose=2 "${DMG_NAME}.dmg"
    
    if [ $? -eq 0 ]; then
        print_success "DMG signature verification passed"
    else
        print_error "DMG signature verification failed"
        exit 1
    fi
}

# Function to prepare for notarization
prepare_notarization() {
    print_header "Preparing for Notarization"
    
    print_status "Creating ZIP archive for notarization..."
    ditto -c -k --keepParent "${DMG_NAME}.dmg" "${DMG_NAME}.zip"
    
    if [ -f "${DMG_NAME}.zip" ]; then
        ZIP_SIZE=$(du -sh "${DMG_NAME}.zip" | cut -f1)
        print_success "ZIP archive created: ${DMG_NAME}.zip ($ZIP_SIZE)"
        
        print_status "Next steps for notarization:"
        echo -e "${CYAN}1. Submit for notarization:${NC}"
        echo -e "   xcrun notarytool submit ${DMG_NAME}.zip --keychain-profile \"notarytool-profile\" --wait"
        echo -e "${CYAN}2. If successful, staple the ticket:${NC}"
        echo -e "   xcrun stapler staple ${DMG_NAME}.dmg"
        echo -e "${CYAN}3. Verify notarization:${NC}"
        echo -e "   xcrun stapler validate ${DMG_NAME}.dmg"
    else
        print_error "ZIP archive creation failed"
        exit 1
    fi
}

# Function to show final summary
show_summary() {
    print_header "Build Summary"
    
    if [ -f "${DMG_NAME}.dmg" ]; then
        DMG_SIZE=$(du -sh "${DMG_NAME}.dmg" | cut -f1)
        print_success "✅ Signed DMG: ${DMG_NAME}.dmg ($DMG_SIZE)"
    fi
    
    if [ -f "${DMG_NAME}.zip" ]; then
        ZIP_SIZE=$(du -sh "${DMG_NAME}.zip" | cut -f1)
        print_success "✅ Notarization ZIP: ${DMG_NAME}.zip ($ZIP_SIZE)"
    fi
    
    print_status "Files ready for distribution!"
    print_warning "Remember to notarize the DMG before distributing to end users."
}

# Main execution
main() {
    print_header "AutoQuill - Signed Build Process"
    
    check_prerequisites
    clean_build
    prepare_flutter
    build_app
    sign_app
    create_dmg
    sign_dmg
    prepare_notarization
    show_summary
    
    print_success "Build process completed successfully! 🎉"
}

# Run the main function
main "$@" 