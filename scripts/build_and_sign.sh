#!/bin/bash

# AutoQuill AI - Build and Sign Script for Distribution
# This script builds, signs, and notarizes the app for distribution outside Mac App Store

set -e  # Exit on any error

# Configuration
APP_NAME="AutoQuill"
BUNDLE_ID="com.divyansh-lalwani.autoquill-ai"
DEVELOPER_ID="Developer ID Application: Divyansh Lalwani (562STT95YC)"
NOTARIZATION_PROFILE="autoquill-notary"  # You'll create this

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    log_error "Please run this script from the root of your Flutter project"
    exit 1
fi

log_info "Starting AutoQuill AI build and signing process..."

# Step 1: Clean and build the app
log_info "Step 1: Building the Flutter app..."
flutter clean
flutter pub get
flutter build macos --release

BUILD_DIR="build/macos/Build/Products/Release"
APP_PATH="$BUILD_DIR/$APP_NAME.app"

if [ ! -d "$APP_PATH" ]; then
    log_error "Build failed - app not found at $APP_PATH"
    exit 1
fi

log_success "Flutter build completed"

# Step 2: Sign the app
log_info "Step 2: Code signing the application..."

# Sign all frameworks and binaries inside the app with hardened runtime
find "$APP_PATH" -type f \( -name "*.dylib" -o -name "*.framework" -o -perm +111 \) -exec codesign --force --options runtime --verify --verbose --sign "$DEVELOPER_ID" {} \;

# Specifically sign Sparkle components with hardened runtime (these often cause notarization issues)
log_info "Signing Sparkle framework components..."
if [ -d "$APP_PATH/Contents/Frameworks/Sparkle.framework" ]; then
    # Sign all Sparkle executables with hardened runtime
    find "$APP_PATH/Contents/Frameworks/Sparkle.framework" -type f -perm +111 -exec codesign --force --options runtime --sign "$DEVELOPER_ID" {} \;
    
    # Sign Sparkle framework itself
    codesign --force --options runtime --sign "$DEVELOPER_ID" "$APP_PATH/Contents/Frameworks/Sparkle.framework"
fi

# Sign the main app bundle with hardened runtime
codesign --force --options runtime --sign "$DEVELOPER_ID" --entitlements "macos/Runner/Release.entitlements" "$APP_PATH"

# Verify the signature
log_info "Verifying code signature..."
codesign --verify --deep --strict --verbose=2 "$APP_PATH"
spctl --assess --type exec --verbose "$APP_PATH"

log_success "Code signing completed successfully"

# Step 3: Create distribution packages
log_info "Step 3: Creating distribution packages..."

# Create timestamped directory
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DIST_DIR="dist/signed/$TIMESTAMP"
mkdir -p "$DIST_DIR"

# Copy signed app to distribution directory
cp -R "$APP_PATH" "$DIST_DIR/"

# Create ZIP for distribution and notarization
log_info "Creating ZIP package..."
cd "$DIST_DIR"
ditto -c -k --keepParent "$APP_NAME.app" "$APP_NAME-signed.zip"
cd - > /dev/null

log_success "ZIP package created: $DIST_DIR/$APP_NAME-signed.zip"

# Step 4: Notarize the app (requires notarization profile)
log_info "Step 4: Submitting for notarization..."

if xcrun notarytool submit "$DIST_DIR/$APP_NAME-signed.zip" \
    --keychain-profile "$NOTARIZATION_PROFILE" \
    --wait; then
    
    log_success "Notarization completed successfully!"
    
    # Staple the notarization to the app
    log_info "Stapling notarization ticket..."
    xcrun stapler staple "$DIST_DIR/$APP_NAME.app"
    
    # Verify notarization
    xcrun stapler validate "$DIST_DIR/$APP_NAME.app"
    
    log_success "Notarization stapled successfully"
    
    # Create final notarized ZIP
    cd "$DIST_DIR"
    rm "$APP_NAME-signed.zip"  # Remove old ZIP
    ditto -c -k --keepParent "$APP_NAME.app" "$APP_NAME-notarized.zip"
    cd - > /dev/null
    
    log_success "Final notarized package: $DIST_DIR/$APP_NAME-notarized.zip"
    
else
    log_error "Notarization failed. Check your notarization profile and credentials."
    log_warning "You can still distribute the signed app, but users may see security warnings."
fi

# Step 5: Create DMG (optional, for professional distribution)
log_info "Step 5: Creating DMG installer..."

# Use fastforge to create DMG
export PATH="$PATH":"$HOME/.pub-cache/bin"
if command -v fastforge &> /dev/null; then
    # Copy notarized app back to build directory for DMG creation
    cp -R "$DIST_DIR/$APP_NAME.app" "$BUILD_DIR/"
    
    fastforge release --name prod --jobs macos-dmg
    
    # Move DMG to signed distribution directory
    if [ -f "dist/1.0.0+1/autoquill_ai-1.0.0+1-macos.dmg" ]; then
        cp "dist/1.0.0+1/autoquill_ai-1.0.0+1-macos.dmg" "$DIST_DIR/$APP_NAME-installer.dmg"
        log_success "DMG installer created: $DIST_DIR/$APP_NAME-installer.dmg"
    fi
else
    log_warning "Fastforge not found, skipping DMG creation"
fi

# Step 6: Final verification
log_info "Step 6: Final verification..."

# Test the notarized app
spctl --assess --type exec --verbose "$DIST_DIR/$APP_NAME.app"

# Summary
log_success "=== BUILD AND SIGNING COMPLETE ==="
echo ""
log_info "Distribution files created in: $DIST_DIR"
echo "  - $APP_NAME.app (Signed and notarized app)"
echo "  - $APP_NAME-notarized.zip (ZIP for direct download)"
echo "  - $APP_NAME-installer.dmg (DMG installer)"
echo ""
log_info "Files are ready for distribution!"
echo ""
log_warning "IMPORTANT: Test the app on a different Mac before public release"
echo ""

# Instructions for distribution
cat << EOF
=== DISTRIBUTION INSTRUCTIONS ===

1. Upload files to your hosting:
   - Upload DMG to your website for user downloads
   - Upload ZIP to your update server for auto-updates

2. Update your landing page:
   - Link to the DMG file for downloads
   - Update auto-updater feed URL to point to ZIP

3. Test on a clean Mac:
   - Download and install from your website
   - Verify no security warnings appear
   - Test auto-update functionality

4. For auto-updates:
   - Sign the ZIP: dart run auto_updater:sign_update $DIST_DIR/$APP_NAME-notarized.zip
   - Update appcast.xml with new signature
   - Upload both ZIP and appcast.xml to your server

EOF 