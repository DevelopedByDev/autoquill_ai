#!/bin/bash

# Thorough Reset Permissions Script for AutoQuill AI
# This script performs a comprehensive reset of all macOS permissions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Multiple potential bundle IDs that might be used
BUNDLE_IDS=(
    "com.divyansh-lalwani.autoquill-ai"
    "com.example.autoquill_ai" 
    "autoquill_ai"
    "AutoQuill AI"
    "com.flutter.autoquill_ai"
    "dev.flutter.autoquill_ai"
)

APP_NAME="AutoQuill AI"

print_status "🧹 Performing thorough permission reset for ${APP_NAME}..."

# Kill all related processes
print_status "Stopping all related processes..."
pkill -f "AutoQuill" || true
pkill -f "autoquill" || true
pkill -f "flutter run" || true
sleep 2

# Reset permissions for all potential bundle IDs
for BUNDLE_ID in "${BUNDLE_IDS[@]}"; do
    print_status "Resetting permissions for bundle ID: ${BUNDLE_ID}"
    
    # Reset all permission types
    tccutil reset Microphone "${BUNDLE_ID}" 2>/dev/null || true
    tccutil reset ScreenCapture "${BUNDLE_ID}" 2>/dev/null || true
    tccutil reset Accessibility "${BUNDLE_ID}" 2>/dev/null || true
    tccutil reset Camera "${BUNDLE_ID}" 2>/dev/null || true
    tccutil reset ListenEvent "${BUNDLE_ID}" 2>/dev/null || true
    tccutil reset AppleEvents "${BUNDLE_ID}" 2>/dev/null || true
    tccutil reset All "${BUNDLE_ID}" 2>/dev/null || true
done

# Also reset for Flutter/Dart development tools that might inherit permissions
print_status "Resetting permissions for development tools..."
tccutil reset All "com.apple.dt.Xcode" 2>/dev/null || true
tccutil reset All "dart" 2>/dev/null || true
tccutil reset All "flutter" 2>/dev/null || true

# Reset the entire TCC database (more aggressive)
print_status "Performing system-wide TCC reset (requires sudo)..."
echo "You may be asked for your password to reset the TCC database..."
sudo tccutil reset All 2>/dev/null || print_warning "Could not reset system TCC database"

print_success "Thorough permission reset completed!"

echo ""
print_status "🔧 MANUAL STEPS REQUIRED:"
print_warning "To ensure permissions are fully reset, please do the following:"
echo ""
print_warning "1. Open System Preferences/Settings > Security & Privacy > Privacy"
print_warning "2. Check and manually remove 'AutoQuill AI' from these sections:"
print_warning "   - 🎤 Microphone"
print_warning "   - 📺 Screen Recording" 
print_warning "   - ♿ Accessibility"
print_warning "   - ⌨️  Input Monitoring"
print_warning "   - 🤖 Automation"
echo ""
print_warning "3. Restart your Mac (recommended for complete reset)"
echo ""
print_status "Alternative: Build and test with the release DMG instead of Flutter run"
print_warning "The DMG app may behave differently regarding permissions than the development version"

echo ""
print_status "Would you like to:"
print_status "1. Build a fresh DMG and test with that? (recommended)"
print_status "2. Try running with flutter again?"
print_status "3. Exit and manually reset permissions?"
echo ""
read -p "Enter choice (1/2/3): " choice

case $choice in
    1)
        print_status "Building fresh DMG for testing..."
        ./build_dmg.sh
        print_status "Opening the DMG to test with the release version..."
        open dist/AutoQuill_AI_v*.dmg
        ;;
    2)
        print_status "Running with Flutter..."
        flutter run -d macos
        ;;
    3)
        print_status "Please manually reset permissions in System Preferences"
        print_status "Then run: flutter run -d macos"
        ;;
    *)
        print_status "Invalid choice. Exiting."
        ;;
esac 