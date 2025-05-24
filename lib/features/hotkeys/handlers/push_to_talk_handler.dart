import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/stats/stats_service.dart';
import 'package:autoquill_ai/features/recording/domain/repositories/recording_repository.dart';
import 'package:autoquill_ai/features/transcription/domain/repositories/transcription_repository.dart';
import '../../../features/transcription/services/smart_transcription_service.dart';
import '../../../features/transcription/services/phrase_replacement_service.dart';
import '../../../features/recording/data/platform/recording_overlay_platform.dart';
import '../services/clipboard_service.dart';
import '../../../core/utils/sound_player.dart';

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
          print('Error initializing stats in PushToTalkHandler: $e');
        }
      }
    });
  }

  /// Handles the push-to-talk key down event
  static void handleKeyDown() async {
    if (_recordingRepository == null || _transcriptionRepository == null) {
      BotToast.showText(text: 'Recording system not initialized');
      return;
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
      // Play the start recording sound
      await SoundPlayer.playStartRecordingSound();

      // Show the overlay with the push-to-talk mode
      await RecordingOverlayPlatform.showOverlayWithMode('Push-to-Talk');
      await _recordingRepository!.startRecording();
      _isPushToTalkRecordingActive = true;
      _recordingStartTime = DateTime.now();
      BotToast.showText(text: 'Push-to-talk recording started');

      if (kDebugMode) {
        print('Push-to-talk recording started');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error starting push-to-talk recording: $e');
      }
      // Play error sound
      await SoundPlayer.playErrorSound();
      BotToast.showText(text: 'Failed to start recording: $e');
    }
  }

  /// Handles the push-to-talk key up event
  static void handleKeyUp() async {
    // Only process if we have an active push-to-talk recording
    if (!_isPushToTalkRecordingActive) {
      return;
    }

    try {
      // Play the stop recording sound
      await SoundPlayer.playStopRecordingSound();

      // Stop recording
      _pushToTalkRecordedFilePath = await _recordingRepository!.stopRecording();
      _isPushToTalkRecordingActive = false;

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
      await ClipboardService.copyToClipboard(transcriptionText);

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
}
