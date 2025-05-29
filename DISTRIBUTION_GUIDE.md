# 🚀 AutoQuill AI Distribution Guide

Complete guide for distributing AutoQuill AI on your landing page outside the Mac App Store.

## 📋 Prerequisites

### ✅ What You Already Have
- ✅ **Apple Developer Account** (active)
- ✅ **Developer ID Application Certificate** (for code signing)
- ✅ **Auto-Update System** (implemented with Sparkle)
- ✅ **DMG Packaging** (configured with Fastforge)

### 🔧 What You Need to Set Up
- [ ] **App-Specific Password** (for notarization)
- [ ] **Notarization Profile** (for automated notarization)
- [ ] **Hosting Solution** (for file distribution)

## 🎯 Step-by-Step Distribution Process

### **Step 1: Set Up Notarization**

Apple requires all apps distributed outside the App Store to be notarized (since macOS Catalina).

**Run the setup script:**
```bash
./scripts/setup_notarization.sh
```

This script will:
- Guide you through creating an app-specific password
- Set up your notarization profile in the keychain
- Test the configuration

**Manual Setup (if script fails):**
1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in with your Apple ID
3. Go to "App-Specific Passwords"
4. Generate password labeled "AutoQuill Notarization"
5. Run:
   ```bash
   xcrun notarytool store-credentials "autoquill-notary" \
     --apple-id "your-apple-id@email.com" \
     --password "xxxx-xxxx-xxxx-xxxx" \
     --team-id "562STT95YC"
   ```

### **Step 2: Build, Sign, and Notarize**

**Run the complete build script:**
```bash
./scripts/build_and_sign.sh
```

This script will:
1. **Clean Build**: Clean and rebuild the Flutter app
2. **Code Sign**: Sign all binaries with your Developer ID certificate
3. **Create Packages**: Generate ZIP and prepare for DMG
4. **Notarize**: Submit to Apple for notarization
5. **Staple**: Attach notarization ticket to the app
6. **Create DMG**: Generate professional installer
7. **Verify**: Final security verification

**Expected Output:**
```
dist/signed/[timestamp]/
├── AutoQuill.app                    (Signed & notarized app)
├── AutoQuill-notarized.zip         (For direct download)
└── AutoQuill-installer.dmg         (Professional installer)
```

### **Step 3: Set Up Auto-Updates**

**Sign the update package:**
```bash
# Use the notarized ZIP for auto-updates
dart run auto_updater:sign_update dist/signed/[timestamp]/AutoQuill-notarized.zip
```

**Update appcast.xml:**
1. Copy the signature from the output above
2. Update `dist/appcast.xml` with:
   - New download URL
   - Generated signature
   - Correct file size
   - Version information

### **Step 4: Set Up Hosting**

You need a web server to host your distribution files.

**Recommended Hosting Options:**

1. **GitHub Releases** (Free)
   - Upload DMG as release asset
   - Great for open source projects
   - Automatic download statistics

2. **AWS S3 + CloudFront** (Professional)
   - Fast global distribution
   - Custom domain support
   - Detailed analytics

3. **Firebase Hosting** (Simple)
   - Easy setup
   - HTTPS by default
   - Good for smaller files

4. **Your Own Server** (Full Control)
   - Complete customization
   - Direct server access
   - Can integrate with your existing infrastructure

**File Structure for Hosting:**
```
your-domain.com/
├── downloads/
│   ├── AutoQuill-installer.dmg     (Main download)
│   └── AutoQuill-notarized.zip     (Auto-update)
├── updates/
│   ├── appcast.xml                 (Update feed)
│   └── release_notes.html          (Release notes)
└── index.html                      (Landing page)
```

### **Step 5: Update Your Landing Page**

**Add download links:**
```html
<!-- Primary download button -->
<a href="https://your-domain.com/downloads/AutoQuill-installer.dmg" 
   class="download-btn">
   Download AutoQuill AI for macOS
</a>

<!-- System requirements -->
<p>Requirements: macOS 10.15 or later</p>

<!-- File size and version info -->
<p>Version 1.0.0 • 25 MB</p>
```

**Update auto-updater feed URL:**
```dart
// In lib/core/services/auto_update_service.dart
static const String _feedURL = 'https://your-domain.com/updates/appcast.xml';
```

### **Step 6: Test Everything**

**Pre-Release Testing:**
1. **Download Test**: Download DMG from your website
2. **Installation Test**: Install on a clean Mac (different from development machine)
3. **Launch Test**: Verify app launches without security warnings
4. **Auto-Update Test**: Test the update mechanism
5. **Functionality Test**: Verify all features work correctly

**Security Verification:**
```bash
# On the test Mac, verify the app passes security checks
spctl --assess --type exec --verbose /Applications/AutoQuill.app

# Should output: "source=Notarized Developer ID"
```

## 🔒 Security Best Practices

### **Code Signing**
- ✅ Use Developer ID Application certificate
- ✅ Sign with `--options runtime` flag
- ✅ Sign all nested binaries and frameworks
- ✅ Verify signatures before distribution

### **Notarization**
- ✅ Submit all distributed binaries for notarization
- ✅ Staple notarization tickets to apps
- ✅ Use app-specific passwords (never your main Apple ID password)
- ✅ Test on clean systems before release

### **Distribution**
- ✅ Use HTTPS for all download links
- ✅ Verify file integrity with checksums
- ✅ Keep private keys secure and backed up
- ✅ Monitor download analytics and user feedback

## 📊 Launch Checklist

### **Pre-Launch**
- [ ] App builds and signs successfully
- [ ] Notarization completes without errors
- [ ] DMG mounts and installs correctly
- [ ] App launches on clean Mac without warnings
- [ ] Auto-updater connects to correct feed URL
- [ ] Landing page download links work
- [ ] HTTPS certificates are valid
- [ ] Analytics tracking is set up

### **Launch Day**
- [ ] Upload final signed files to hosting
- [ ] Update landing page with download links
- [ ] Test download process end-to-end
- [ ] Announce availability
- [ ] Monitor for user feedback and issues

### **Post-Launch**
- [ ] Monitor download analytics
- [ ] Watch for user-reported issues
- [ ] Prepare update process for future releases
- [ ] Keep certificates and profiles up to date

## 🛠️ Troubleshooting

### **Common Issues**

**"App is damaged and can't be opened"**
- Solution: App wasn't properly signed or notarized
- Fix: Re-run build_and_sign.sh script

**"Developer cannot be verified"**
- Solution: App wasn't notarized or notarization wasn't stapled
- Fix: Check notarization status and re-staple if needed

**Auto-updates not working**
- Solution: Check appcast.xml URL and signature
- Fix: Verify feed URL in AutoUpdateService and signature in appcast.xml

**DMG won't mount**
- Solution: DMG may be corrupted during upload
- Fix: Re-upload DMG, verify file integrity

### **Verification Commands**

```bash
# Check code signature
codesign --verify --deep --strict --verbose=2 AutoQuill.app

# Check notarization
xcrun stapler validate AutoQuill.app

# Test security assessment
spctl --assess --type exec --verbose AutoQuill.app

# Check auto-updater feed
curl -I https://your-domain.com/updates/appcast.xml
```

## 📞 Support Resources

- **Apple Developer Documentation**: [developer.apple.com](https://developer.apple.com/documentation/)
- **Notarization Guide**: [Apple Notarization Guide](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- **Code Signing Guide**: [Apple Code Signing Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/)
- **Sparkle Framework**: [sparkle-project.org](https://sparkle-project.org/)

---

## 🎉 Ready for Distribution!

Once you complete all these steps, your AutoQuill AI app will be:
- ✅ **Professionally signed** with your Developer ID
- ✅ **Notarized by Apple** for security trust
- ✅ **Ready for distribution** outside the Mac App Store
- ✅ **Auto-updating** for seamless user experience
- ✅ **Security compliant** with macOS requirements

Your users will be able to download and install AutoQuill AI without any security warnings, and the app will automatically keep itself updated with new releases. 