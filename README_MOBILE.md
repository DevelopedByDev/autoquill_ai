# AutoQuill Mobile

This is the mobile version of AutoQuill, designed for iOS as a keyboard extension with multilingual transcription capabilities.

## Setup

### Running the Mobile Version

To run the mobile version of AutoQuill:

```bash
# Navigate to the project directory
cd /path/to/autoquill_ai

# Run the mobile app using the mobile main file
flutter run -t lib/mobile_main.dart -d ios
```

### Project Structure

The mobile version has its own dedicated structure:

```
lib/
├── mobile_main.dart                     # Mobile app entry point
└── features/
    └── mobile/
        └── presentation/
            └── pages/
                ├── mobile_onboarding_page.dart    # API key setup
                ├── mobile_main_page.dart          # Main app with navigation
                ├── mobile_home_page.dart          # Home screen with stats
                └── mobile_settings_page.dart      # Settings screen
```

### Features

#### Current Implementation (Frontend Only)

1. **Onboarding Screen**
   - Groq API key setup with validation
   - Beautiful animated interface
   - Instructions for obtaining API key

2. **Home Screen**
   - Stats display (Transcribed words, Generated words, Recording time, WPM)
   - Animated stats cards
   - Time-based greetings

3. **Settings Screen**
   - Groq API key management
   - Dictionary for difficult words
   - Phrase replacements

4. **Navigation**
   - Bottom navigation between Home and Settings
   - Smooth transitions

#### Planned Features (Backend Integration)

- Swift-based keyboard extension
- Real-time audio recording
- Groq API integration for transcription
- Multilingual support
- Stats tracking and storage

### Design

The mobile version follows the same design system as the desktop version:
- Minimalist design with clean cards
- Dark and light theme support
- Consistent typography and spacing
- Smooth animations and transitions
- Coral and blue gradient accents

### Development Notes

- Uses the same BLoC pattern as desktop version
- Shares core services and design tokens
- Responsive design for mobile screens
- Native iOS integration planned for keyboard extension

### Next Steps

1. Implement backend functionality
2. Create iOS keyboard extension in Swift
3. Add audio recording capabilities
4. Integrate with Groq API
5. Add stats persistence
6. Test on physical iOS devices 