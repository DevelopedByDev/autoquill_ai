import 'dart:async';
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
import '../core/hotkey_handler.dart';

/// Handler for push-to-talk hotkey functionality
class PushToTalkHandler {
  // Flag to track if recording is in progress via push-to-talk
  static bool _isPushToTalkRecordingActive = false;

  // Path to the recorded audio file when using push-to-talk
  static String? _pushToTalkRecordedFilePath;

  // Repositories for direct access
  static RecordingRepository? _recordingRepository;
  static TranscriptionRepository? _transcriptionRepository;

  // Recording start time for tracking duration
  static DateTime? _recordingStartTime;

  // Timer for minimum hold duration check
  static Timer? _minimumHoldTimer;

  // Fallback timer for first use cleanup
  static Timer? _firstUseCleanupTimer;

  // Initialization state tracking
  static bool _isInitialized = false;
  static DateTime? _initializationTime;
  static bool _hasBeenUsedOnce = false;
  static DateTime? _firstKeyDownTime;
  static bool _isFirstUseInProgress = false;

  // Race condition handling for first use
  static bool _isRecordingStartupInProgress = false;
  static bool _hasQueuedKeyUp = false;

  // Stats service for tracking stats
  static final StatsService _statsService = StatsService();

  /// Initialize the handler with necessary repositories
  static void initialize(RecordingRepository recordingRepository,
      TranscriptionRepository transcriptionRepository) {
    _recordingRepository = recordingRepository;
    _transcriptionRepository = transcriptionRepository;

    // Initialize stats service without blocking
    _ensureStatsInitialized();

    // Mark as initialized and record the time
    _isInitialized = true;
    _initializationTime = DateTime.now();

    if (kDebugMode) {
      print('PushToTalkHandler initialized at ${_initializationTime}');
    }
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
          print('Error initializing stats in PushToTalkHandler: $e');
        }
      }
    });
  }

  /// Check if the handler is ready for operations
  static bool _isSystemReady() {
    // Must be initialized
    if (!_isInitialized || _initializationTime == null) {
      if (kDebugMode) {
        print('PushToTalkHandler not yet initialized');
      }
      return false;
    }

    // No delay needed - race condition is handled by queued keyUp mechanism
    // Just check that repositories are available
    if (_recordingRepository == null || _transcriptionRepository == null) {
      if (kDebugMode) {
        print('PushToTalkHandler repositories not available');
      }
      return false;
    }

    return true;
  }

  /// Handles the push-to-talk key down event
  static void handleKeyDown() async {
    if (!_isSystemReady()) {
      return;
    }

    // Mark that push-to-talk has been used (for subsequent faster startup)
    if (!_hasBeenUsedOnce) {
      _hasBeenUsedOnce = true;
      _isFirstUseInProgress = true;
      _firstKeyDownTime = DateTime.now();
      if (kDebugMode) {
        print(
            'Marking push-to-talk as having been used once - FIRST USE at ${_firstKeyDownTime}');
      }
    }

    // Check if push-to-talk is enabled
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

    final pushToTalkEnabled = Hive.box('settings')
        .get('push_to_talk_enabled', defaultValue: true) as bool;
    if (!pushToTalkEnabled) {
      if (kDebugMode) {
        print('Push-to-talk is disabled in settings');
      }
      return;
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
        !_isPushToTalkRecordingActive) {
      // Another mode is recording, don't interrupt it
      BotToast.showText(text: 'Another recording is in progress');
      return;
    }

    // Prevent duplicate key down events
    if (_isPushToTalkRecordingActive) {
      return;
    }

    // Start recording
    try {
      // Mark that recording startup is in progress to handle race conditions
      _isRecordingStartupInProgress = true;
      _hasQueuedKeyUp = false;

      // Register Esc key for cancellation
      await HotkeyHandler.registerEscKeyForRecording();

      // Play the start recording sound
      await SoundPlayer.playStartRecordingSound();

      // Get the push-to-talk hotkey for display
      final pushToTalkHotkey = _getHotkeyDisplayString('push_to_talk_hotkey');

      // Show the overlay with the push-to-talk mode and hotkey info
      await RecordingOverlayPlatform.showOverlayWithModeAndHotkeys(
          'Push-to-Talk', pushToTalkHotkey, 'Esc');
      await _recordingRepository!.startRecording();
      _isPushToTalkRecordingActive = true;
      _recordingStartTime = DateTime.now();

      // Recording startup is complete
      _isRecordingStartupInProgress = false;

      // Check if keyUp arrived during startup
      if (_hasQueuedKeyUp) {
        if (kDebugMode) {
          print(
              'Processing queued keyUp that arrived during recording startup');
        }
        _hasQueuedKeyUp = false;
        // Process the queued keyUp immediately
        handleKeyUp();
        return;
      }

      // Start minimum hold timer - check if still held after 200ms
      _minimumHoldTimer = Timer(Duration(milliseconds: 200), () {
        // If recording is no longer active after 200ms, it means the key was released too quickly
        if (!_isPushToTalkRecordingActive) {
          if (kDebugMode) {
            print('Push-to-talk key was released too quickly, auto-cancelling');
          }
          // The recording would have already been stopped by handleKeyUp,
          // but we need to ensure proper cleanup
          _ensureRecordingCleanup();
        } else {
          if (kDebugMode) {
            print(
                'Push-to-talk minimum hold duration met, continuing recording');
          }
        }
        _minimumHoldTimer = null;
      });

      // For first use, add a fallback cleanup timer to handle macOS initialization issues
      if (_isFirstUseInProgress) {
        _firstUseCleanupTimer = Timer(Duration(seconds: 3), () {
          if (_isPushToTalkRecordingActive && _isFirstUseInProgress) {
            if (kDebugMode) {
              print(
                  'FIRST USE: Fallback cleanup triggered - possible macOS hotkey initialization issue');
            }
            _ensureRecordingCleanup();
            _isFirstUseInProgress = false;
          }
          _firstUseCleanupTimer = null;
        });
      }

      BotToast.showText(text: 'Push-to-talk recording started');

      if (kDebugMode) {
        print('Push-to-talk recording started');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error starting push-to-talk recording: $e');
      }

      // Cancel the minimum hold timer if it was started
      if (_minimumHoldTimer != null) {
        _minimumHoldTimer!.cancel();
        _minimumHoldTimer = null;
      }

      // Cancel the first use cleanup timer if it was started
      if (_firstUseCleanupTimer != null) {
        _firstUseCleanupTimer!.cancel();
        _firstUseCleanupTimer = null;
      }

      // Reset recording state
      _isPushToTalkRecordingActive = false;
      _recordingStartTime = null;
      _isFirstUseInProgress = false;
      _isRecordingStartupInProgress = false;
      _hasQueuedKeyUp = false;

      // Unregister Esc key if recording failed to start
      await HotkeyHandler.unregisterEscKeyForRecording();
      // Play error sound
      await SoundPlayer.playErrorSound();
      BotToast.showText(text: 'Failed to start recording: $e');
    }
  }

  /// Handles the push-to-talk key up event
  static void handleKeyUp() async {
    final keyUpTime = DateTime.now();

    // Add detailed diagnostics for first use
    if (_isFirstUseInProgress && _firstKeyDownTime != null) {
      final totalEventTime = keyUpTime.difference(_firstKeyDownTime!);
      if (kDebugMode) {
        print(
            'FIRST USE: keyUp received ${totalEventTime.inMilliseconds}ms after keyDown');
        print('FIRST USE: Recording active: $_isPushToTalkRecordingActive');
        print('FIRST USE: Recording start time: $_recordingStartTime');
        print(
            'FIRST USE: Recording startup in progress: $_isRecordingStartupInProgress');
      }
    }

    // Handle race condition: if recording startup is in progress, queue this keyUp
    if (_isRecordingStartupInProgress) {
      if (kDebugMode) {
        print(
            'keyUp received during recording startup - queuing for later processing');
      }
      _hasQueuedKeyUp = true;
      return;
    }

    // Only process if we have an active push-to-talk recording
    if (!_isPushToTalkRecordingActive) {
      if (_isFirstUseInProgress) {
        if (kDebugMode) {
          print(
              'FIRST USE: keyUp received but recording not active - possible macOS initialization issue');
        }
        _isFirstUseInProgress = false;
      }
      return;
    }

    // Check if the minimum hold duration was met
    bool wasQuickRelease = false;
    Duration? holdDuration;
    if (_recordingStartTime != null) {
      holdDuration = keyUpTime.difference(_recordingStartTime!);
      wasQuickRelease = holdDuration.inMilliseconds < 200;

      if (_isFirstUseInProgress) {
        if (kDebugMode) {
          print(
              'FIRST USE: Hold duration calculated as ${holdDuration.inMilliseconds}ms');
          print('FIRST USE: Quick release detected: $wasQuickRelease');
        }
      }
    }

    // Cancel the minimum hold timer if it's still running
    if (_minimumHoldTimer != null) {
      _minimumHoldTimer!.cancel();
      _minimumHoldTimer = null;
    }

    // Cancel the first use cleanup timer if it's running
    if (_firstUseCleanupTimer != null) {
      _firstUseCleanupTimer!.cancel();
      _firstUseCleanupTimer = null;
    }

    // If this was a quick release, cancel the recording
    if (wasQuickRelease) {
      if (kDebugMode) {
        print(
            'Push-to-talk key released too quickly (${holdDuration?.inMilliseconds ?? 0}ms < 200ms), auto-cancelling${_isFirstUseInProgress ? " [FIRST USE]" : ""}');
      }

      // Add a longer delay for first use to account for macOS initialization
      final delay = _isFirstUseInProgress ? 200 : 50;
      await Future.delayed(Duration(milliseconds: delay));

      await _ensureRecordingCleanup();
      _isFirstUseInProgress = false;
      return;
    }

    if (kDebugMode) {
      print(
          'Push-to-talk held for ${holdDuration?.inMilliseconds ?? 0}ms, proceeding with transcription${_isFirstUseInProgress ? " [FIRST USE]" : ""}');
    }

    // Mark first use as complete
    _isFirstUseInProgress = false;

    try {
      // Play the stop recording sound
      await SoundPlayer.playStopRecordingSound();

      // Stop recording
      _pushToTalkRecordedFilePath = await _recordingRepository!.stopRecording();
      _isPushToTalkRecordingActive = false;

      // Unregister Esc key since recording is done
      await HotkeyHandler.unregisterEscKeyForRecording();

      // Calculate recording duration
      if (_recordingStartTime != null) {
        try {
          final recordingDuration =
              DateTime.now().difference(_recordingStartTime!);
          await _statsService.addTranscriptionTime(recordingDuration.inSeconds);
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

      if (kDebugMode) {
        print('Push-to-talk recording stopped, transcribing...');
      }

      // Transcribe the audio
      if (_pushToTalkRecordedFilePath != null) {
        final apiKey = Hive.box('settings').get('groq_api_key');
        await _transcribeAndCopyToClipboard(
            _pushToTalkRecordedFilePath!, apiKey);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during push-to-talk recording or transcription: $e');
      }
      BotToast.showText(text: 'Error during recording or transcription: $e');
    }
  }

  /// Transcribe audio and copy to clipboard without affecting UI
  static Future<void> _transcribeAndCopyToClipboard(
      String audioPath, String apiKey) async {
    try {
      // Update overlay to show we're processing the audio
      await RecordingOverlayPlatform.setProcessingAudio();

      // Start transcription request immediately
      final transcriptionFuture =
          _transcriptionRepository!.transcribeAudio(audioPath, apiKey);

      // Check settings while transcription is in progress
      final settingsBox = Hive.box('settings');
      final smartTranscriptionEnabled = settingsBox
          .get('smart_transcription_enabled', defaultValue: false) as bool;
      final Map<dynamic, dynamic>? storedReplacements =
          settingsBox.get('phrase_replacements');

      // Wait for transcription to complete
      final response = await transcriptionFuture;

      // Trim any leading/trailing whitespace from the transcription text
      var transcriptionText = response.text.trim();

      // Apply phrase replacements if available
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

      if (kDebugMode) {
        print('Smart transcription enabled: $smartTranscriptionEnabled');
        print('Transcription text length: ${transcriptionText.length}');
        print(
            'Checking smart transcription condition: ${smartTranscriptionEnabled && transcriptionText.isNotEmpty}');
      }

      // If smart transcription is enabled, start it in parallel
      Future<String>? smartTranscriptionFuture;
      if (smartTranscriptionEnabled && transcriptionText.isNotEmpty) {
        if (kDebugMode) {
          print('Starting smart transcription enhancement');
        }
        smartTranscriptionFuture =
            SmartTranscriptionService.enhanceTranscription(
                transcriptionText, apiKey);
      }

      // If smart transcription is running, wait for it with timeout
      if (smartTranscriptionFuture != null) {
        try {
          transcriptionText = await smartTranscriptionFuture.timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              if (kDebugMode) {
                print('Smart transcription timed out, using original text');
              }
              return transcriptionText;
            },
          );

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
          mode: 'push_to_talk');

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

          // Format for macOS display with spaces between symbols
          List<String> keyParts = [];

          // Add modifiers in the correct order for macOS
          if (hotkey.modifiers?.contains(HotKeyModifier.meta) ?? false) {
            keyParts.add('⌘');
          }
          if (hotkey.modifiers?.contains(HotKeyModifier.control) ?? false) {
            keyParts.add('⌃');
          }
          if (hotkey.modifiers?.contains(HotKeyModifier.alt) ?? false) {
            keyParts.add('⌥');
          }
          if (hotkey.modifiers?.contains(HotKeyModifier.shift) ?? false) {
            keyParts.add('⇧');
          }

          // Add the key itself using Flutter's built-in keyLabel
          keyParts.add(_getMacKeySymbol(hotkey.key));

          // Join with spaces
          final keyText = keyParts.join(' ');

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

  /// Check if push-to-talk recording is currently active
  static bool isRecordingActive() {
    return _isPushToTalkRecordingActive;
  }

  /// Cancel the current push-to-talk recording
  static Future<void> cancelRecording() async {
    if (!_isPushToTalkRecordingActive) {
      if (kDebugMode) {
        print('Push-to-talk cancellation called but recording not active');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('Cancelling active push-to-talk recording...');
      }

      // Cancel the minimum hold timer if it's still running
      if (_minimumHoldTimer != null) {
        _minimumHoldTimer!.cancel();
        _minimumHoldTimer = null;
      }

      // Cancel the first use cleanup timer if it's running
      if (_firstUseCleanupTimer != null) {
        _firstUseCleanupTimer!.cancel();
        _firstUseCleanupTimer = null;
      }

      // Cancel the recording
      await _recordingRepository?.cancelRecording();
      _isPushToTalkRecordingActive = false;
      _recordingStartTime = null;
      _pushToTalkRecordedFilePath = null;

      // Unregister Esc key since recording is cancelled
      await HotkeyHandler.unregisterEscKeyForRecording();

      // Hide the overlay
      await RecordingOverlayPlatform.hideOverlay();

      BotToast.showText(text: 'Push-to-talk recording cancelled');

      if (kDebugMode) {
        print('Push-to-talk recording cancelled successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cancelling push-to-talk recording: $e');
      }

      // Force cleanup even if cancellation failed
      _isPushToTalkRecordingActive = false;
      _recordingStartTime = null;
      _pushToTalkRecordedFilePath = null;
      if (_minimumHoldTimer != null) {
        _minimumHoldTimer!.cancel();
        _minimumHoldTimer = null;
      }

      try {
        await RecordingOverlayPlatform.hideOverlay();
      } catch (_) {
        // Ignore overlay errors
      }

      BotToast.showText(text: 'Error cancelling recording');
    }
  }

  /// Ensure recording cleanup when key is released too quickly
  static Future<void> _ensureRecordingCleanup() async {
    try {
      if (kDebugMode) {
        print('Starting push-to-talk cleanup due to quick release...');
      }

      // For the first use, add extra delay to let system settle
      if (!_hasBeenUsedOnce) {
        if (kDebugMode) {
          print('First use detected, adding extra delay for cleanup');
        }
        await Future.delayed(Duration(milliseconds: 200));
      }

      // First, cancel the minimum hold timer to prevent any race conditions
      if (_minimumHoldTimer != null) {
        _minimumHoldTimer!.cancel();
        _minimumHoldTimer = null;
      }

      // Cancel the first use cleanup timer if it's running
      if (_firstUseCleanupTimer != null) {
        _firstUseCleanupTimer!.cancel();
        _firstUseCleanupTimer = null;
      }

      // Reset recording state BEFORE attempting to cancel recording
      final wasRecordingActive = _isPushToTalkRecordingActive;
      _isPushToTalkRecordingActive = false;
      _recordingStartTime = null;
      _pushToTalkRecordedFilePath = null;
      _isFirstUseInProgress = false;
      _isRecordingStartupInProgress = false;
      _hasQueuedKeyUp = false;

      // Try to cancel recording if it was active, but don't fail the cleanup if this fails
      // Also check if system is ready - if not, we might be in early startup
      if (wasRecordingActive &&
          _recordingRepository != null &&
          _isInitialized) {
        try {
          await _recordingRepository!.cancelRecording();
          if (kDebugMode) {
            print('Recording repository cancellation completed');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Warning: Recording repository cancellation failed: $e');
          }
          // Continue with cleanup even if recording cancellation fails
        }
      } else if (wasRecordingActive && !_isInitialized) {
        if (kDebugMode) {
          print(
              'Skipping recording cancellation - system not fully initialized');
        }
      }

      // Unregister Esc key - this should always work if system is initialized
      if (_isInitialized) {
        try {
          await HotkeyHandler.unregisterEscKeyForRecording();
          if (kDebugMode) {
            print('Esc key unregistered successfully');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Warning: Esc key unregistration failed: $e');
          }
        }
      }

      // Force hide the overlay - this is critical and should work even during startup
      // For first use, try multiple times with delays
      bool overlayHidden = false;
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          await RecordingOverlayPlatform.hideOverlay();
          overlayHidden = true;
          if (kDebugMode) {
            print('Overlay hidden successfully on attempt $attempt');
          }
          break;
        } catch (e) {
          if (kDebugMode) {
            print('Warning: Overlay hiding failed on attempt $attempt: $e');
          }
          if (attempt < 3) {
            await Future.delayed(Duration(milliseconds: 100 * attempt));
          }
        }
      }

      if (!overlayHidden) {
        if (kDebugMode) {
          print('Error: Failed to hide overlay after 3 attempts');
        }
      }

      // Show user feedback
      BotToast.showText(text: 'Push-to-talk cancelled (released too quickly)');

      if (kDebugMode) {
        print('Push-to-talk cleanup completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during push-to-talk cleanup: $e');
      }

      // Emergency fallback - force reset everything
      _isPushToTalkRecordingActive = false;
      _recordingStartTime = null;
      _pushToTalkRecordedFilePath = null;
      if (_minimumHoldTimer != null) {
        _minimumHoldTimer!.cancel();
        _minimumHoldTimer = null;
      }

      // Try one more time to hide the overlay with force
      try {
        for (int i = 0; i < 3; i++) {
          RecordingOverlayPlatform.hideOverlay();
          await Future.delayed(Duration(milliseconds: 50));
        }
      } catch (_) {
        // Ignore any further errors
      }
    }
  }
}
