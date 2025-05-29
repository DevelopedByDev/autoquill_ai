#!/bin/bash

# AutoQuill AI - Notarization Setup Script
# This script helps you set up Apple notarization credentials

set -e

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

echo ""
log_info "=== AutoQuill AI Notarization Setup ==="
echo ""

# Check if user has Apple Developer account
log_info "This setup requires an Apple Developer account (\$99/year)"
echo ""
echo "Prerequisites:"
echo "1. Apple Developer account"
echo "2. App-specific password (we'll help you create this)"
echo ""

read -p "Do you have an Apple Developer account? (y/n): " has_account
if [ "$has_account" != "y" ]; then
    log_warning "You need an Apple Developer account to notarize apps."
    echo "Sign up at: https://developer.apple.com"
    echo "After signing up, run this script again."
    exit 1
fi

# Get Apple ID
echo ""
log_info "Please enter your Apple ID (email address):"
read -p "Apple ID: " apple_id

if [ -z "$apple_id" ]; then
    log_error "Apple ID cannot be empty"
    exit 1
fi

# Check if they have an app-specific password
echo ""
log_info "You need an app-specific password for notarization."
echo ""
echo "To create one:"
echo "1. Go to https://appleid.apple.com"
echo "2. Sign in with your Apple ID"
echo "3. Go to 'App-Specific Passwords'"
echo "4. Generate a new password with label 'AutoQuill Notarization'"
echo "5. Copy the generated password (format: xxxx-xxxx-xxxx-xxxx)"
echo ""

read -p "Do you have an app-specific password ready? (y/n): " has_password
if [ "$has_password" != "y" ]; then
    log_warning "Please create an app-specific password first, then run this script again."
    echo "Instructions: https://support.apple.com/en-us/HT204397"
    exit 1
fi

# Get app-specific password
echo ""
log_info "Please enter your app-specific password:"
read -s -p "App-specific password: " app_password
echo ""

if [ -z "$app_password" ]; then
    log_error "App-specific password cannot be empty"
    exit 1
fi

# Create notarization profile
echo ""
log_info "Creating notarization profile..."

PROFILE_NAME="autoquill-notary"

# Store credentials in keychain
if xcrun notarytool store-credentials "$PROFILE_NAME" \
    --apple-id "$apple_id" \
    --password "$app_password" \
    --team-id "562STT95YC"; then
    
    log_success "Notarization profile '$PROFILE_NAME' created successfully!"
    
    # Test the profile
    log_info "Testing notarization profile..."
    if xcrun notarytool history --keychain-profile "$PROFILE_NAME" > /dev/null 2>&1; then
        log_success "Profile test successful!"
    else
        log_warning "Profile test failed, but profile was created. You may need to check your credentials."
    fi
    
else
    log_error "Failed to create notarization profile."
    echo "Please check your credentials and try again."
    exit 1
fi

echo ""
log_success "=== SETUP COMPLETE ==="
echo ""
log_info "Your notarization profile is ready!"
echo "Profile name: $PROFILE_NAME"
echo ""
log_info "Next steps:"
echo "1. Run: ./scripts/build_and_sign.sh"
echo "2. This will build, sign, and notarize your app automatically"
echo ""
log_warning "Keep your Apple ID and app-specific password secure!"
echo ""

# Create a reminder file
cat > scripts/.notarization_info << EOF
# AutoQuill AI Notarization Info
Profile Name: $PROFILE_NAME
Apple ID: $apple_id
Team ID: 562STT95YC
Created: $(date)

# To rebuild the profile if needed:
# xcrun notarytool store-credentials $PROFILE_NAME --apple-id $apple_id --password [APP_PASSWORD] --team-id 562STT95YC

# To test the profile:
# xcrun notarytool history --keychain-profile $PROFILE_NAME

# To delete the profile:
# xcrun notarytool delete-credentials $PROFILE_NAME
EOF

log_info "Notarization info saved to scripts/.notarization_info" 