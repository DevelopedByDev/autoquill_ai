#!/bin/bash

# Reset Permissions Script for AutoQuill AI
# This script clears all macOS permissions for the app to test permission prompting

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

# App bundle identifier - adjust if needed
BUNDLE_ID="com.example.autoquillAi"
APP_NAME="AutoQuill AI"

print_status "Resetting permissions for ${APP_NAME}..."

# Kill the app if it's running
print_status "Stopping ${APP_NAME} if running..."
pkill -f "AutoQuill AI" || true
pkill -f "autoquill_ai" || true

# Reset microphone permissions
print_status "Resetting microphone permissions..."
tccutil reset Microphone "${BUNDLE_ID}" 2>/dev/null || true

# Reset screen recording permissions
print_status "Resetting screen recording permissions..."
tccutil reset ScreenCapture "${BUNDLE_ID}" 2>/dev/null || true

# Reset accessibility permissions
print_status "Resetting accessibility permissions..."
tccutil reset Accessibility "${BUNDLE_ID}" 2>/dev/null || true

# Reset camera permissions (if used)
print_status "Resetting camera permissions..."
tccutil reset Camera "${BUNDLE_ID}" 2>/dev/null || true

# Reset input monitoring permissions
print_status "Resetting input monitoring permissions..."
tccutil reset ListenEvent "${BUNDLE_ID}" 2>/dev/null || true

# Reset automation permissions
print_status "Resetting automation permissions..."
tccutil reset AppleEvents "${BUNDLE_ID}" 2>/dev/null || true

# Reset all permissions for the bundle ID
print_status "Resetting all permissions for bundle ID..."
tccutil reset All "${BUNDLE_ID}" 2>/dev/null || true

print_success "Permissions reset completed!"

print_warning "Note: Some permissions might require manual reset in System Preferences > Security & Privacy"
print_warning "You may need to manually remove the app from:"
print_warning "- System Preferences > Security & Privacy > Privacy > Microphone"
print_warning "- System Preferences > Security & Privacy > Privacy > Screen Recording"
print_warning "- System Preferences > Security & Privacy > Privacy > Accessibility"
print_warning "- System Preferences > Security & Privacy > Privacy > Input Monitoring"

echo ""
print_status "Would you like to run the app now to test permissions? (y/n)" 