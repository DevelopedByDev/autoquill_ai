# AutoQuill AI Auto-Update Setup Guide

This guide explains how to set up and use the auto-updating functionality for AutoQuill AI using the `auto_updater` package and Fastforge for distribution.

## Overview

AutoQuill AI now supports automatic updates using Sparkle framework on macOS. The app will automatically check for updates every 24 hours and notify users when new versions are available.

**Distribution Options:**
- **DMG Files**: For initial distribution outside the Mac App Store
- **ZIP Files**: For automatic updates via the built-in updater

## Key Components

### 1. Auto-Update Service
- **Location**: `lib/core/services/auto_update_service.dart`
- **Purpose**: Manages auto-update functionality
- **Features**:
  - Initialize auto-updater with feed URL
  - Manual update checks
  - Configurable update intervals

### 2. Settings Integration
- **Location**: `lib/features/settings/presentation/pages/general_settings_page.dart`
- **Features**:
  - Manual "Check for Updates" button
  - Current version display
  - User-friendly update status messages

### 3. Cryptographic Signing
- **Keys Generated**: EdDSA key pair for macOS
- **Public Key**: Added to `macos/Runner/Info.plist`
- **Private Key**: Stored securely in macOS Keychain

### 4. Distribution Setup
- **Fastforge**: Modern Flutter app packaging and distribution tool
- **DMG Configuration**: `macos/packaging/dmg/make_config.yaml`
- **Distribution Config**: `distribute_options.yaml`

## Setup Process

### 1. Dependencies Added
```yaml
# pubspec.yaml
dependencies:
  auto_updater: ^1.0.0
```

### 2. macOS Configuration
- **Sparkle Framework**: Added to `macos/Podfile`
- **Entitlements**: Updated `macos/Runner/Release.entitlements`
  - Disabled sandbox (`com.apple.security.app-sandbox`: false)
  - Added network permissions
- **Info.plist**: Added public signing key

### 3. Distribution Setup
- **Fastforge**: Installed globally via `dart pub global activate fastforge`
- **appdmg**: Installed via `npm install -g appdmg` for DMG creation
- **Configuration**: `distribute_options.yaml` updated for Fastforge format
- **DMG Config**: `macos/packaging/dmg/make_config.yaml` created

## Usage Instructions

### For Developers

#### 1. Install Required Tools
```bash
# Install Fastforge (modern Flutter distributor)
dart pub global activate fastforge

# Install appdmg for DMG creation (macOS only)
npm install -g appdmg
```

#### 2. Build Release Packages
```bash
# Build DMG for initial distribution
fastforge release --name prod --jobs macos-dmg

# Build ZIP package for auto-updates
fastforge release --name prod --jobs macos-zip

# Build both DMG and ZIP
fastforge release --name prod
```

#### 3. Sign the Update Package (ZIP only)
```bash
# Generate signature for the ZIP file
dart run auto_updater:sign_update dist/1.0.0+1/autoquill_ai-1.0.0+1-macos.zip
```

#### 4. Update Appcast.xml (for auto-updates)
1. Copy `dist/appcast.xml.template` to `appcast.xml`
2. Replace placeholder values:
   - Update URLs to your download server
   - Add the generated signature from step 3
   - Update version numbers and release dates
   - Set correct file size (`length` attribute)

#### 5. Deploy to Server
- **DMG**: Upload to your website/distribution platform for initial installs
- **ZIP + appcast.xml**: Upload to web server for auto-updates

### For Users

#### Initial Installation
1. Download the DMG file from your distribution website
2. Open the DMG and drag AutoQuill AI to Applications folder
3. Launch the app - it will automatically check for updates going forward

#### Manual Update Check
1. Open AutoQuill AI
2. Go to Settings (gear icon)
3. Select "General" tab
4. Click "Check for Updates" button

#### Automatic Updates
- The app automatically checks for updates every 24 hours
- Users will be notified when updates are available
- Updates are downloaded and installed automatically (ZIP format)

## Distribution Workflow

### Initial Release (DMG)
1. **Build DMG**: `fastforge release --name prod --jobs macos-dmg`
2. **Upload**: Distribute DMG via your website, GitHub releases, etc.
3. **Users Install**: Users download and install from DMG

### Subsequent Updates (ZIP)
1. **Build ZIP**: `fastforge release --name prod --jobs macos-zip`
2. **Sign**: Generate signature with `dart run auto_updater:sign_update`
3. **Update Appcast**: Add new version entry to appcast.xml
4. **Deploy**: Upload ZIP and updated appcast.xml to server
5. **Auto-Update**: Users receive automatic updates

## File Structure
```
autoquill_ai/
├── lib/core/services/auto_update_service.dart
├── macos/
│   ├── packaging/dmg/make_config.yaml (DMG configuration)
│   ├── Podfile (Sparkle added)
│   └── Runner/
│       ├── Info.plist (public key added)
│       └── Release.entitlements (sandbox disabled)
├── distribute_options.yaml (Fastforge configuration)
├── dist/
│   ├── appcast.xml.template
│   ├── appcast.xml (for updates)
│   ├── release_notes.html
│   └── 1.0.0+1/
│       ├── autoquill_ai-1.0.0+1-macos.dmg (26.5MB)
│       └── autoquill_ai-1.0.0+1-macos.zip (24.8MB)
└── AUTO_UPDATE_SETUP.md (this file)
```

## Configuration Options

### Update Feed URL
**Current**: Set in `AutoUpdateService._feedURL`
**Change**: Update the URL to point to your appcast.xml location

### Update Interval
**Default**: 86400 seconds (24 hours)
**Minimum**: 3600 seconds (1 hour)
**Disable**: Set to 0

### DMG Appearance
**Configuration**: `macos/packaging/dmg/make_config.yaml`
**Customization**: 
- Window size and position
- Icon and background
- File positioning

### Testing Updates
For testing, you can use a local server:
```bash
# In the dist/ directory
python3 -m http.server 5002
# or
serve -l 5002
```

Then update the feed URL to: `http://localhost:5002/appcast.xml`

## Security Considerations

### Signing Keys
- **Private Key**: Stored in macOS Keychain (never share!)
- **Public Key**: Embedded in app bundle
- **Backup**: Save private key securely - losing it prevents future updates

### HTTPS Required
- Always use HTTPS for production appcast URLs
- Ensures update integrity and prevents man-in-the-middle attacks

### Sandbox Limitations
- Auto-updater requires sandbox to be disabled in release builds
- This is necessary for the update mechanism to function properly

### DMG Distribution
- DMG files can be distributed outside Mac App Store
- No notarization required for testing, but recommended for production
- Users may see security warnings without proper code signing

## Troubleshooting

### Common Issues

1. **Updates Not Detected**
   - Verify appcast.xml is accessible
   - Check feed URL in AutoUpdateService
   - Ensure proper XML format

2. **Signature Verification Failed**
   - Verify signature was generated correctly
   - Check public key in Info.plist matches private key
   - Ensure ZIP file wasn't modified after signing

3. **DMG Creation Failed**
   - Ensure appdmg is installed: `npm install -g appdmg`
   - Check make_config.yaml syntax
   - Verify icon paths are correct

4. **Network Issues**
   - Check entitlements include network permissions
   - Verify HTTPS certificates are valid
   - Test feed URL accessibility

### Debug Mode
- Auto-updater only initializes in release mode by default
- For testing, temporarily modify the condition in `main.dart`

## Production Checklist

- [ ] **Code Signing**: Set up proper macOS code signing certificates
- [ ] **Notarization**: Submit DMG for Apple notarization (recommended)
- [ ] **HTTPS Server**: Set up secure hosting for appcast.xml and ZIP files
- [ ] **Update Feed URL**: Change from localhost to production URL
- [ ] **Testing**: Verify both DMG installation and auto-updates work
- [ ] **Backup Keys**: Securely backup signing keys
- [ ] **Monitoring**: Set up tracking for update adoption

## Resources

- [Fastforge Documentation](https://fastforge.dev/getting-started)
- [DMG Maker Documentation](https://fastforge.dev/makers/dmg)
- [auto_updater package documentation](https://pub.dev/packages/auto_updater)
- [Sparkle framework documentation](https://sparkle-project.org/)
- [Apple Code Signing Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/)

---

**Important**: Always test the update mechanism thoroughly in a staging environment before deploying to production users. 