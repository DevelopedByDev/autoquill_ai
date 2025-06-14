# AutoQuill AI

<div align="center">
  <img src="assets/icons/with_bg/AQOL.png" alt="AutoQuill AI Logo" width="200"/>
  
  **Professional AI-Powered Audio Transcription for macOS**
  
  [![Website](https://img.shields.io/badge/Website-getautoquill.com-2ea44f?style=flat-square)](https://www.getautoquill.com)
  [![Flutter](https://img.shields.io/badge/Flutter-3.1.3+-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
  [![macOS](https://img.shields.io/badge/macOS-10.14+-000000?style=flat-square&logo=apple)](https://www.apple.com/macos)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](https://opensource.org/licenses/MIT)
  [![Version](https://img.shields.io/badge/Version-1.2.0-blue?style=flat-square)](https://github.com/yourusername/autoquill_ai/releases)
</div>

## 📖 Overview

AutoQuill AI is a powerful, system-wide audio transcription application for macOS that transforms speech into text instantly. With advanced AI-powered transcription, intelligent text processing, and seamless system integration, AutoQuill streamlines your workflow whether you're writing documents, coding, or communicating.

### 🎯 Key Benefits

- **System-Wide Integration**: Works in any application through global hotkeys
- **AI-Powered Accuracy**: Advanced speech recognition with context awareness
- **Real-Time Processing**: Instant transcription with visual feedback
- **Smart Text Enhancement**: Automatic punctuation, formatting, and phrase replacement
- **Privacy-First Design**: Local processing with optional cloud APIs
- **Professional Workflow**: Built for developers, writers, and professionals

## ✨ Features

### 🎤 **Core Transcription Modes**

#### **Standard Transcription** (`Alt/Option + Shift + Z` by default)
- **One-touch recording**: Press hotkey to start/stop recording
- **Automatic clipboard**: Transcribed text is copied and ready to paste
- **Visual feedback**: Overlay shows recording status and hotkey reminders
- **Perfect for**: Quick notes, dictating documents, voice memos

#### **Push-to-Talk** (`Alt/Option + Space` by default)
- **Hold-to-record**: Hold key down to record, release to transcribe
- **Instant feedback**: Immediate transcription when you release the key
- **Minimum hold protection**: Prevents accidental short recordings
- **Perfect for**: Real-time communication, live note-taking, gaming

#### **AI Assistant Mode** (`Alt/Option + Shift + S` by default)
- **Context-aware processing**: Select text first, then record instructions
- **Text generation**: Create content from scratch with voice prompts
- **Smart editing**: Modify, improve, or rewrite selected text
- **Perfect for**: Content creation, editing, code comments, email composition

### 🛠️ **Smart Features**

#### **Intelligent Text Processing**
- **Auto-punctuation**: Smart punctuation based on speech patterns
- **Phrase replacement**: Custom abbreviations and text shortcuts
- **Context awareness**: Better accuracy based on content type
- **Multi-language support**: Works with multiple languages and accents

#### **Advanced Hotkey System**
- **Customizable shortcuts**: Set any key combination for each mode
- **Conflict detection**: Prevents hotkey conflicts between modes
- **System-wide registration**: Works in any application
- **Escape key cancellation**: Cancel any recording with Esc key

#### **Visual Feedback System**
- **Real-time overlay**: Shows current mode, hotkeys, and status
- **Audio cues**: Sound feedback for start/stop/error states
- **Progress indicators**: Visual confirmation of transcription progress
- **Non-intrusive design**: Overlay disappears automatically

### ⚙️ **Configuration & Settings**

#### **API Integration**
- **Groq API support**: Fast, accurate transcription with Groq's models
- **Flexible model selection**: Choose from various AI models
- **API key management**: Secure local storage of credentials
- **Offline fallback**: Basic transcription without internet connection

#### **Workflow Customization**
- **Auto-copy settings**: Configure clipboard behavior
- **Phrase replacements**: Set up custom text shortcuts
- **Theme support**: Light and dark mode options
- **Statistics tracking**: Monitor usage and transcription time

#### **Privacy & Security**
- **Local data storage**: All settings stored locally using Hive
- **Secure API handling**: Encrypted API key storage
- **No data collection**: Your transcriptions stay on your device
- **Permission management**: Clear microphone permission handling

### 🔄 **Auto-Update System**
- **Seamless updates**: Automatic background updates using Sparkle
- **Release notes**: Clear information about new features
- **Rollback protection**: Safe update mechanism with verification
- **Custom update channels**: Control update frequency and stability

## 🚀 Installation

### **Option 1: Download DMG (Recommended)**
1. Visit [AutoQuill AI Releases](https://github.com/DevelopedByDev/autoquill_ai/releases)
2. Download the latest `AutoQuill-v{version}.dmg` file
3. Open the DMG and drag AutoQuill to Applications
4. Launch AutoQuill from Applications folder

### **Option 2: Build from Source**
```bash
# Clone the repository
git clone https://github.com/DevelopedByDev/autoquill_ai.git
cd autoquill_ai

# Install dependencies
flutter pub get

# Generate app icons
flutter pub run flutter_launcher_icons

# Build and run
flutter run -d macos
```

### **System Requirements**
- **macOS**: 10.14 (Mojave) or later
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 100MB for app installation
- **Microphone**: Required for audio input
- **Internet**: Required for AI transcription (optional for basic features)

## 🎮 Usage Guide

### **Initial Setup**

1. **Launch AutoQuill** from Applications
2. **Grant microphone permission** when prompted
3. **Add API key** in Settings → API Configuration
4. **Test functionality** using the built-in test page
5. **Customize hotkeys** in Settings → Hotkeys

### **Basic Workflow**

#### **Quick Transcription**
```
1. Press Alt/Option + Shift + Z (or your custom hotkey)
2. Speak your message
3. Press Alt/Option + Shift + Z again to stop
4. Text is automatically copied to clipboard and pasted if cursor is in a text field
5. Paste (⌘V) in any application
```

#### **Push-to-Talk Mode**
```
1. Hold Alt/Option + Space (or your custom hotkey)
2. Speak while holding the key
3. Release to automatically transcribe
4. Text is copied and ready to paste
```

#### **AI Assistant Mode**
```
1. Select text in any application (⌘C to copy)
2. Press Alt/Option + Shift + S (or your custom hotkey)
3. Speak your instructions ("make this more formal")
4. AI processes and improves the text
5. Enhanced text is copied and ready to paste
```

### **Advanced Features**

#### **Custom Hotkeys**
- Go to **Settings → Hotkeys**
- Click on any hotkey to record a new combination
- Test for conflicts before saving
- Use modifier keys (⌘, ⌥, ⌃, ⇧) for system-wide compatibility

#### **Phrase Replacements**
- Set up abbreviations that expand to full phrases
- Example: "my address" → "123 Main Street, City, State 12345"
- Perfect for email signatures, addresses, common phrases

#### **Smart Transcription**
- Enable in **Settings → Transcription**
- Improves accuracy for technical terms
- Better punctuation and formatting
- Context-aware processing

## 🛠️ Development Setup

### **Prerequisites**

```bash
# Install Flutter (macOS)
[https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)

# Verify installation
flutter doctor

# Install Xcode from Mac App Store
# Install Xcode command line tools
xcode-select --install
```

### **Development Dependencies**

```bash
# Clone repository
git clone https://github.com/yourusername/autoquill_ai.git
cd autoquill_ai

# Install Flutter dependencies
flutter pub get

# Install CocoaPods dependencies (macOS)
cd macos && pod install && cd ..

# Generate launcher icons
flutter pub run flutter_launcher_icons

# Run in debug mode
flutter run -d macos
```

### **Project Structure**

```
lib/
├── core/                     # Core utilities and services
│   ├── di/                   # Dependency injection
│   ├── storage/              # Data persistence
│   ├── theme/                # App theming
│   └── utils/                # Utility functions
├── features/                 # Feature modules
│   ├── assistant/            # AI assistant functionality
│   ├── hotkeys/              # Hotkey management
│   ├── recording/            # Audio recording
│   ├── settings/             # App configuration
│   └── transcription/        # Speech-to-text
├── services/                 # External services
├── widgets/                  # Reusable UI components
└── main.dart                 # Application entry point

assets/
├── icons/                    # App icons and logos
├── sounds/                   # Audio feedback files
└── fonts/                    # Custom fonts (Inter)

macos/                        # macOS-specific code
├── Runner/                   # Swift application code
├── Podfile                   # CocoaPods dependencies
└── packaging/                # Distribution files
```

### **Architecture**

AutoQuill AI follows **Clean Architecture** principles with **BLoC pattern**:

- **Presentation Layer**: Flutter widgets and BLoC state management
- **Domain Layer**: Business logic and repository interfaces  
- **Data Layer**: API clients, local storage, and platform channels
- **Platform Layer**: macOS-specific Swift code for system integration

### **Key Technologies**

- **Flutter**: Cross-platform UI framework
- **BLoC**: State management pattern
- **Hive**: Local data storage
- **Hotkey Manager**: Global hotkey registration
- **Sparkle**: Auto-update framework
- **Swift**: macOS platform integration

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help make AutoQuill AI better:

### **Getting Started**

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Set up development environment** (see Development Setup)
4. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
5. **Make your changes** with clear, commented code
6. **Test thoroughly** on macOS
7. **Commit with clear messages** (`git commit -m 'Add amazing feature'`)
8. **Push to your branch** (`git push origin feature/amazing-feature`)
9. **Open a Pull Request** with detailed description

### **Ways to Contribute**

#### **🐛 Bug Reports**
- Use the [GitHub Issues](https://github.com/yourusername/autoquill_ai/issues) page
- Include detailed steps to reproduce
- Provide system information (macOS version, app version)
- Include console logs if available

#### **✨ Feature Requests**
- Check existing issues to avoid duplicates
- Provide clear use cases and benefits
- Consider implementation complexity
- Discuss with maintainers before major changes

#### **💻 Code Contributions**

**High-Priority Areas:**
- **Multi-language support**: Expanding language capabilities
- **Accessibility improvements**: VoiceOver, keyboard navigation
- **Performance optimization**: Faster transcription, lower memory usage
- **UI/UX enhancements**: Better visual feedback, customization options
- **Additional AI providers**: Support for more transcription APIs

**Development Guidelines:**
- Follow Flutter/Dart style guide
- Write tests for new functionality
- Update documentation for public APIs
- Ensure macOS compatibility (10.14+)
- Test with real-world scenarios

#### **📚 Documentation**
- Improve inline code comments
- Enhance README sections
- Create tutorials and guides
- Translate documentation to other languages
- Write technical blog posts

#### **🧪 Testing**
- Manual testing on different macOS versions
- Edge case discovery and reporting
- Performance testing and profiling
- Accessibility testing with assistive technologies
- Integration testing with various applications

### **Development Workflow**

#### **Code Quality Standards**
```bash
# Run static analysis
flutter analyze

# Format code
flutter format .

# Run tests
flutter test

# Build for testing
flutter build macos --debug
```

#### **Testing Guidelines**
- Test all three transcription modes thoroughly
- Verify hotkey functionality in multiple applications
- Test with different microphone setups
- Validate API key management and security
- Check auto-update mechanism

#### **Pull Request Requirements**
- [ ] **Code compiles** without warnings
- [ ] **All tests pass** (if tests exist)
- [ ] **Manual testing** completed on macOS
- [ ] **Documentation updated** for user-facing changes
- [ ] **No security vulnerabilities** introduced
- [ ] **Performance impact** considered and documented

### **Community Guidelines**

- **Be respectful** and inclusive in all interactions
- **Follow the code of conduct** (standard GitHub community guidelines)
- **Ask questions** in discussions before major changes
- **Share knowledge** and help other contributors
- **Focus on user value** when proposing features

### **Recognition**

Contributors will be recognized in:
- Project documentation
- Release notes for significant contributions  
- GitHub contributors page
- Community hall of fame (for ongoing contributors)

## 📋 Build & Distribution

### **Development Build**
```bash
# Debug build for testing
flutter run -d macos

# Release build for local testing
flutter build macos --release
```

### **Production Build**
```bash
# Complete build, sign, and notarize
./scripts/build_and_sign.sh

# Output: dist/signed/{timestamp}/AutoQuill-v{version}-notarized.zip
# Output: dist/signed/{timestamp}/AutoQuill-v{version}.dmg
```

### **Distribution Requirements**
- **Apple Developer Account** ($99/year for code signing)
- **Developer ID Certificate** for distribution outside App Store
- **App-specific password** for notarization
- **Notarization setup** for Gatekeeper compatibility

See [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) for detailed build setup.

## 📊 Project Statistics

- **Languages**: Dart (Flutter), Swift (macOS)
- **Dependencies**: 25+ Flutter packages
- **Supported platforms**: macOS 10.14+
- **Installation size**: ~50MB
- **Development time**: 12+ months
- **Active features**: 15+ core features

## 🔧 Troubleshooting

### **Common Issues**

**Microphone Permission Denied**
```bash
# Reset permissions in System Preferences → Security & Privacy → Microphone
# Restart AutoQuill after granting permission
```

**Hotkeys Not Working**
```bash
# Check for conflicts in System Preferences → Keyboard → Shortcuts
# Try different key combinations
# Restart AutoQuill to re-register hotkeys
```

**API Connection Issues**
```bash
# Verify internet connection
# Check API key validity in Settings
# Try different transcription models
```

**Build Errors**
```bash
# Clean build environment
flutter clean
rm -rf macos/Pods
cd macos && pod install && cd ..
flutter pub get
flutter build macos
```

### **Model Download Issues**

If you encounter "authorizationRequired" errors when downloading WhisperKit models, this is due to Hugging Face repository access requirements. Here are solutions:

#### **Option 1: Use Hugging Face Token (Recommended)**
1. Create a free account at [Hugging Face](https://huggingface.co/)
2. Generate an access token at [Hugging Face Tokens](https://huggingface.co/settings/tokens)
3. Set the environment variable:
   ```bash
   export HUGGING_FACE_HUB_TOKEN="your_token_here"
   ```
4. Restart the app

#### **Option 2: Manual Model Download**
1. Visit [WhisperKit Models Repository](https://huggingface.co/argmaxinc/whisperkit-coreml)
2. Download the model files manually
3. Place them in the correct directory (use "Open Models Folder" in settings)

#### **Option 3: Use Cloud Transcription Only**
- Ensure you have a valid OpenAI API key
- Disable local transcription in settings
- Use cloud-based transcription instead

### **Common Issues**

- **"Failed to initialize [model]"**: Usually indicates incomplete model download or missing files
- **"Resource temporarily unavailable"**: Close other instances of the app before starting
- **Missing modules**: Ensure you're using the correct Flutter version and dependencies

## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License - Copyright (c) 2024 Divyansh Lalwani

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software.
```

## 👨‍💻 Author

**Divyansh Lalwani**
- GitHub: [@DevelopedByDev](https://github.com/DevelopedByDev)
- Website: [getautoquill.com](https://www.getautoquill.com)
- Email: work.dslalwani@gmail.com, dlalwan1@jhu.edu

## 🙏 Acknowledgments

- **Flutter Team** for the amazing cross-platform framework
- **Groq** for providing fast and accurate AI transcription APIs
- **Sparkle** for seamless auto-update functionality
- **Open Source Community** for the incredible packages and tools
- **Beta testers** who provided valuable feedback and bug reports

## 🔗 Links

- **Website**: [getautoquill.com](https://www.getautoquill.com)
- **Download**: [Latest Release](https://github.com/yourusername/autoquill_ai/releases)
- **Documentation**: [Wiki](https://github.com/yourusername/autoquill_ai/wiki)
- **Support**: [Issues](https://github.com/yourusername/autoquill_ai/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/autoquill_ai/discussions)

---

<div align="center">
  <strong>Made with ❤️ for productivity enthusiasts</strong><br>
  <em>Transform your voice into perfectly formatted text, anywhere on macOS</em>
</div>

