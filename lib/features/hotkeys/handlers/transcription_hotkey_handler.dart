import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../../core/stats/stats_service.dart';

import 'package:autoquill_ai/features/recording/domain/repositories/recording_repository.dart';
import 'package:autoquill_ai/features/transcription/domain/repositories/transcription_repository.dart';
import '../../../features/transcription/services/smart_transcription_service.dart';
import '../../../features/transcription/services/phrase_replacement_service.dart';
import '../../../features/recording/data/platform/recording_overlay_platform.dart';
import '../services/clipboard_service.dart';
import '../../../core/utils/sound_player.dart';
import '../utils/hotkey_converter.dart';

/// Handler for transcription hotkey functionality
class TranscriptionHotkeyHandler {
  // Flag to track if recording is in progress via hotkey
  static bool _isHotkeyRecordingActive = false;

  // Path to the recorded audio file when using hotkey
  static String? _hotkeyRecordedFilePath;

  // Repositories for direct access
  static RecordingRepository? _recordingRepository;
  static TranscriptionRepository? _transcriptionRepository;

  // Recording start time for tracking duration
  static DateTime? _recordingStartTime;

  // Stats service for tracking stats
  static final StatsService _statsService = StatsService();

  /// Initialize the handler with necessary repositories
  static void initialize(RecordingRepository recordingRepository,
      TranscriptionRepository transcriptionRepository) {
    _recordingRepository = recordingRepository;
    _transcriptionRepository = transcriptionRepository;

    // Initialize stats service without blocking
    _ensureStatsInitialized();
  }

  /// Ensure stats box is initialized
  static void _ensureStatsInitialized() {
    // Run async initialization without awaiting to avoid blocking
    Future(() async {
      try {
        if (!Hive.isBoxOpen('stats')) {
          await Hive.openBox('stats');
        }
        await _statsService.init();
      } catch (e) {
        if (kDebugMode) {
          print('Error initializing stats in TranscriptionHotkeyHandler: $e');
        }
      }
    });
  }

  /// Handles the transcription hotkey press
  static void handleHotkey() async {
    if (_recordingRepository == null || _transcriptionRepository == null) {
      BotToast.showText(text: 'Recording system not initialized');
      return;
    }

    // Ensure settings box is open
    if (!Hive.isBoxOpen('settings')) {
      try {
        await Hive.openBox('settings');
      } catch (e) {
        if (kDebugMode) {
          print('Error opening settings box: $e');
        }
        BotToast.showText(text: 'Error accessing settings');
        return;
      }
    }

    // Ensure stats box is open
    if (!Hive.isBoxOpen('stats')) {
      try {
        await Hive.openBox('stats');
        await _statsService.init();
      } catch (e) {
        if (kDebugMode) {
          print('Error opening stats box: $e');
        }
        // Continue anyway, as this is not critical
      }
    }

    // Check if API key is available
    final apiKey = Hive.box('settings').get('groq_api_key');
    if (apiKey == null || apiKey.isEmpty) {
      BotToast.showText(
          text: 'No API key found. Please add your Groq API key in Settings.');
      return;
    }

    // Check if this is our own recording or another mode's recording
    if (RecordingOverlayPlatform.isRecordingInProgress &&
        !_isHotkeyRecordingActive) {
      // Another mode is recording, don't interrupt it
      BotToast.showText(text: 'Another recording is in progress');
      return;
    }

    if (!_isHotkeyRecordingActive) {
      // Start recording directly using the repository
      try {
        // Play the start recording sound
        await SoundPlayer.playStartRecordingSound();

        // Get the transcription hotkey for display
        final transcriptionHotkey =
            _getHotkeyDisplayString('transcription_hotkey');

        if (kDebugMode) {
          print('Transcription hotkey display string: "$transcriptionHotkey"');
        }

        // Show the overlay with the transcription mode and hotkey info
        await RecordingOverlayPlatform.showOverlayWithModeAndHotkeys(
            'Transcription', transcriptionHotkey, 'Esc');
        await _recordingRepository!.startRecording();
        _isHotkeyRecordingActive = true;
        _recordingStartTime = DateTime.now();
        BotToast.showText(text: 'Recording started');
      } catch (e) {
        if (kDebugMode) {
          print('Error starting recording: $e');
        }
        // Play error sound
        await SoundPlayer.playErrorSound();
        BotToast.showText(text: 'Failed to start recording: $e');
      }
    } else {
      // Stop recording and transcribe directly
      try {
        // Play the stop recording sound
        await SoundPlayer.playStopRecordingSound();

        // Stop recording
        _hotkeyRecordedFilePath = await _recordingRepository!.stopRecording();
        _isHotkeyRecordingActive = false;

        // Calculate recording duration
        if (_recordingStartTime != null) {
          try {
            final recordingDuration =
                DateTime.now().difference(_recordingStartTime!);
            await _statsService
                .addTranscriptionTime(recordingDuration.inSeconds);
          } catch (e) {
            if (kDebugMode) {
              print('Error updating transcription time: $e');
            }
            // Fallback to direct Hive update if the stats service fails
            try {
              if (Hive.isBoxOpen('stats')) {
                final box = Hive.box('stats');
                final currentTime =
                    box.get('transcription_time_seconds', defaultValue: 0);
                box.put(
                    'transcription_time_seconds',
                    currentTime +
                        DateTime.now()
                            .difference(_recordingStartTime!)
                            .inSeconds);
              }
            } catch (_) {}
          } finally {
            _recordingStartTime = null;
          }
        }

        BotToast.showText(text: 'Recording stopped, transcribing...');

        // Transcribe the audio
        await _transcribeAndCopyToClipboard(_hotkeyRecordedFilePath!, apiKey);
      } catch (e) {
        BotToast.showText(text: 'Error during recording or transcription: $e');
      }
    }
  }

  /// Transcribe audio and copy to clipboard without affecting UI
  static Future<void> _transcribeAndCopyToClipboard(
      String audioPath, String apiKey) async {
    try {
      // Update overlay to show we're processing the audio
      await RecordingOverlayPlatform.setProcessingAudio();

      // Transcribe the audio
      final response =
          await _transcriptionRepository!.transcribeAudio(audioPath, apiKey);
      // Trim any leading/trailing whitespace from the transcription text
      var transcriptionText = response.text.trim();

      // Check if smart transcription is enabled
      final settingsBox = Hive.box('settings');

      // Apply phrase replacements before smart transcription
      final Map<dynamic, dynamic>? storedReplacements =
          settingsBox.get('phrase_replacements');

      if (storedReplacements != null && storedReplacements.isNotEmpty) {
        final Map<String, String> phraseReplacements =
            Map<String, String>.from(storedReplacements);

        if (kDebugMode) {
          print('Applying phrase replacements: $phraseReplacements');
        }

        transcriptionText = PhraseReplacementService.applyReplacements(
            transcriptionText, phraseReplacements);

        if (kDebugMode) {
          print(
              'Transcription text after phrase replacements: "$transcriptionText"');
        }
      }
      final smartTranscriptionEnabled = settingsBox
          .get('smart_transcription_enabled', defaultValue: false) as bool;

      if (kDebugMode) {
        print('Smart transcription enabled: $smartTranscriptionEnabled');
        print('Transcription text length: ${transcriptionText.length}');
        print(
            'Checking smart transcription condition: ${smartTranscriptionEnabled && transcriptionText.isNotEmpty}');
      }

      if (smartTranscriptionEnabled && transcriptionText.isNotEmpty) {
        try {
          // Update overlay to show smart transcription is processing
          await RecordingOverlayPlatform.setProcessingAudio();

          if (kDebugMode) {
            print('Applying smart transcription to: $transcriptionText');
          }

          // Apply smart transcription enhancement
          transcriptionText =
              await SmartTranscriptionService.enhanceTranscription(
                  transcriptionText, apiKey);

          if (kDebugMode) {
            print('Smart transcription result: $transcriptionText');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Smart transcription failed, using original text: $e');
          }
          // Continue with original transcription if smart transcription fails
        }
      }

      // Copy to clipboard - this will also update the overlay state to "Transcription copied"
      // and hide the overlay after pasting
      await ClipboardService.copyToClipboard(transcriptionText,
          mode: 'transcription');

      // Update word count in Hive using StatsService
      if (transcriptionText.isNotEmpty) {
        // Make sure stats box is initialized first
        _ensureStatsInitialized();

        // Wait a moment to ensure box is open
        await Future.delayed(Duration(milliseconds: 100));

        try {
          // Use the StatsService to update the word count
          await _statsService.addTranscriptionWords(transcriptionText);
        } catch (e) {
          if (kDebugMode) {
            print('Error updating word count via StatsService: $e');
          }

          // Fallback: Update directly in the stats box
          try {
            if (Hive.isBoxOpen('stats')) {
              final wordCount =
                  transcriptionText.trim().split(RegExp(r'\s+')).length;
              final box = Hive.box('stats');
              final currentCount =
                  box.get('transcription_words_count', defaultValue: 0);
              final newCount = currentCount + wordCount;

              // Use synchronous put for immediate update
              box.put('transcription_words_count', newCount);
            } else {
              // Try to open the box and update
              await Hive.openBox('stats');
              final wordCount =
                  transcriptionText.trim().split(RegExp(r'\s+')).length;
              final box = Hive.box('stats');
              final currentCount =
                  box.get('transcription_words_count', defaultValue: 0);
              final newCount = currentCount + wordCount;
              box.put('transcription_words_count', newCount);
            }
          } catch (boxError) {
            if (kDebugMode) {
              print('Error updating word count directly: $boxError');
            }
          }
        }
      }

      BotToast.showText(text: 'Transcription copied to clipboard');
    } catch (e) {
      // Hide the overlay on error
      await RecordingOverlayPlatform.hideOverlay();
      BotToast.showText(text: 'Transcription failed: $e');
    }
  }

  /// Get hotkey display string for the overlay
  static String? _getHotkeyDisplayString(String hotkeyKey) {
    try {
      if (!Hive.isBoxOpen('settings')) return null;

      final settingsBox = Hive.box('settings');
      final hotkeyData = settingsBox.get(hotkeyKey);

      if (hotkeyData == null) return null;

      // Convert the stored hotkey data to a HotKey object and use its display formatting
      if (hotkeyData is Map) {
        try {
          // Use the existing hotkey converter to get a proper HotKey object
          final hotkey = hotKeyConverter(hotkeyData);

          if (kDebugMode) {
            print('Converted hotkey: ${hotkey.toJson()}');
            print('Key type: ${hotkey.key.runtimeType}');
            print('Key label: ${hotkey.key.keyLabel}');
          }

          // Format for macOS display
          String keyText = '';

          // Add modifiers in the correct order for macOS
          if (hotkey.modifiers?.contains(HotKeyModifier.meta) ?? false) {
            keyText += '⌘';
          }
          if (hotkey.modifiers?.contains(HotKeyModifier.control) ?? false) {
            keyText += '⌃';
          }
          if (hotkey.modifiers?.contains(HotKeyModifier.alt) ?? false) {
            keyText += '⌥';
          }
          if (hotkey.modifiers?.contains(HotKeyModifier.shift) ?? false) {
            keyText += '⇧';
          }

          // Add the key itself using Flutter's built-in keyLabel
          final keySymbol = _getMacKeySymbol(hotkey.key);
          keyText += keySymbol;

          if (kDebugMode) {
            print('Final hotkey display string: "$keyText"');
          }

          return keyText.isNotEmpty ? keyText : null;
        } catch (e) {
          if (kDebugMode) {
            print('Error converting hotkey data to HotKey object: $e');
          }
          return null;
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting hotkey display string: $e');
      }
      return null;
    }
  }

  /// Convert key to Mac symbol (similar to HotkeyDisplay widget)
  static String _getMacKeySymbol(KeyboardKey key) {
    // Convert common keys to their Mac symbols
    switch (key.keyLabel) {
      case 'Arrow Up':
        return '↑';
      case 'Arrow Down':
        return '↓';
      case 'Arrow Left':
        return '←';
      case 'Arrow Right':
        return '→';
      case 'Enter':
        return '↩';
      case 'Tab':
        return '⇥';
      case 'Escape':
        return '⎋';
      case 'Delete':
        return '⌫';
      case 'Page Up':
        return '⇞';
      case 'Page Down':
        return '⇟';
      case 'Home':
        return '↖';
      case 'End':
        return '↘';
      case 'Space':
        return 'Space';
      default:
        // For letter keys and others, just use the label
        return key.keyLabel;
    }
  }

  /// Check if transcription recording is currently active
  static bool isRecordingActive() {
    return _isHotkeyRecordingActive;
  }

  /// Cancel the current transcription recording
  static Future<void> cancelRecording() async {
    if (!_isHotkeyRecordingActive) return;

    try {
      // Cancel the recording
      await _recordingRepository?.cancelRecording();
      _isHotkeyRecordingActive = false;
      _recordingStartTime = null;
      _hotkeyRecordedFilePath = null;

      // Hide the overlay
      await RecordingOverlayPlatform.hideOverlay();

      BotToast.showText(text: 'Transcription recording cancelled');

      if (kDebugMode) {
        print('Transcription recording cancelled via Esc key');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cancelling transcription recording: $e');
      }
      BotToast.showText(text: 'Error cancelling recording');
    }
  }
}
