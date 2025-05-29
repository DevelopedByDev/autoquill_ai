# 📁 AutoQuill AI Distribution Scripts

This directory contains scripts for building, signing, and distributing AutoQuill AI outside the Mac App Store.

## 🚀 Quick Start

1. **Set up notarization** (one-time setup):
   ```bash
   ./scripts/setup_notarization.sh
   ```

2. **Build and sign for distribution**:
   ```bash
   ./scripts/build_and_sign.sh
   ```

## 📄 Script Details

### `setup_notarization.sh`
**Purpose**: One-time setup for Apple notarization credentials.

**What it does:**
- Guides you through creating an app-specific password
- Sets up notarization profile in macOS Keychain
- Tests the configuration

**When to run:** Once before your first distribution

### `build_and_sign.sh`
**Purpose**: Complete build, sign, and notarize process for distribution.

**What it does:**
1. Clean and build Flutter app
2. Code sign with Developer ID certificate
3. Create distribution packages (ZIP, DMG)
4. Submit for Apple notarization
5. Staple notarization ticket
6. Generate final distribution files

**When to run:** Every time you want to create a new distribution

**Output files:**
```
dist/signed/[timestamp]/
├── AutoQuill.app                    (Signed & notarized app)
├── AutoQuill-notarized.zip         (For auto-updates)
└── AutoQuill-installer.dmg         (For website distribution)
```

## 🔧 Configuration

Both scripts are pre-configured with your settings:
- **Developer ID**: `Developer ID Application: Divyansh Lalwani (562STT95YC)`
- **Bundle ID**: `com.divyansh-lalwani.autoquill-ai`
- **Team ID**: `562STT95YC`
- **Profile Name**: `autoquill-notary`

## ⚠️ Prerequisites

- ✅ Apple Developer Account ($99/year)
- ✅ Developer ID Application certificate (already installed)
- ✅ Xcode Command Line Tools
- ✅ Flutter SDK
- ✅ Fastforge package (`dart pub global activate fastforge`)

## 🛠️ Troubleshooting

### Script Permission Issues
```bash
chmod +x scripts/*.sh
```

### Notarization Profile Issues
```bash
# Delete and recreate profile
xcrun notarytool delete-credentials autoquill-notary
./scripts/setup_notarization.sh
```

### Code Signing Issues
```bash
# Check available certificates
security find-identity -v -p codesigning
```

## 📚 Documentation

For complete distribution instructions, see:
- `../DISTRIBUTION_GUIDE.md` - Complete distribution guide
- `../AUTO_UPDATE_SETUP.md` - Auto-updater setup details 