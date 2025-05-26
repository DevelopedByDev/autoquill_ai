# AutoQuill - Build Instructions

This document provides instructions for building and packaging AutoQuill for macOS distribution.

## Prerequisites

Before running the build script, ensure you have the following installed:

1. **Flutter SDK** - Make sure Flutter is installed and in your PATH
2. **Xcode** - Required for macOS app building
3. **Homebrew** (recommended) - For installing additional tools
4. **create-dmg** - Will be automatically installed by the script if missing

## Quick Start

To build and package the app into a DMG:

```bash
./build_dmg.sh
```

## What the Script Does

The `build_dmg.sh` script performs the following steps:

1. **Prerequisites Check** - Verifies Flutter and required tools are installed
2. **Clean Build** - Removes previous build artifacts
3. **Dependencies** - Runs `flutter pub get` to fetch dependencies
4. **Icon Generation** - Generates app icons using `flutter_launcher_icons`
5. **Build App** - Compiles the Flutter app for macOS release
6. **Package DMG** - Creates a distributable DMG file with proper layout

## Output

The script creates:
- `dist/AutoQuill_v{version}.dmg` - The distributable DMG file
- Automatically opens the `dist/` folder when complete

## Code Signing (Optional)

For distribution outside the App Store, you'll need to:

1. **Get a Developer ID Certificate** from Apple Developer Program
2. **Uncomment the code signing section** in `build_dmg.sh`
3. **Replace the placeholder** with your actual Developer ID
4. **Notarize the DMG** with Apple (for Gatekeeper compatibility)

Example code signing setup:
```bash
# Uncomment and modify this section in build_dmg.sh
DEVELOPER_ID="Developer ID Application: Your Name (TEAM_ID)"
codesign --force --deep --sign "$DEVELOPER_ID" "dist/${APP_NAME}.app"
```

## Notarization (For Public Distribution)

If you plan to distribute outside the App Store:

1. **Code sign** the app with a Developer ID certificate
2. **Notarize** the DMG with Apple:
   ```bash
   xcrun notarytool submit dist/AutoQuill_v{version}.dmg --keychain-profile "AC_PASSWORD" --wait
   ```
3. **Staple** the notarization ticket:
   ```bash
   xcrun stapler staple dist/AutoQuill_v{version}.dmg
   ```

## Troubleshooting

### Common Issues

1. **Flutter not found**: Ensure Flutter is installed and in your PATH
2. **Xcode errors**: Make sure Xcode is installed and command line tools are set up
3. **Permission denied**: Run `chmod +x build_dmg.sh` to make the script executable
4. **create-dmg not found**: The script will try to install it automatically via Homebrew

### Manual create-dmg Installation

If automatic installation fails:
```bash
# Via Homebrew
brew install create-dmg

# Via npm
npm install -g create-dmg
```

## Build Configuration

The script automatically extracts version information from `pubspec.yaml`. To change the app name or other settings, modify the configuration section at the top of `build_dmg.sh`:

```bash
APP_NAME="AutoQuill"
BUNDLE_NAME="autoquill_ai"
DMG_NAME="AutoQuill_v${VERSION}"
```

## File Structure After Build

```
dist/
└── AutoQuill_v1.0.0.dmg    # Distributable DMG file
```

The DMG contains:
- AutoQuill.app (the application)
- Applications folder shortcut (for easy installation)
- Custom background and layout

## Support

If you encounter issues with the build process, check:
1. Flutter doctor: `flutter doctor`
2. Xcode installation: `xcode-select --install`
3. Build logs in the terminal output 