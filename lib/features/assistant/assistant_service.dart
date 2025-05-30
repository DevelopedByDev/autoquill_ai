import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:autoquill_ai/core/utils/sound_player.dart';
import 'package:autoquill_ai/core/stats/stats_service.dart';
import '../recording/data/platform/recording_overlay_platform.dart';
import 'package:http/http.dart' as http;
import 'package:keypress_simulator/keypress_simulator.dart';
import 'package:autoquill_ai/features/recording/domain/repositories/recording_repository.dart';
import 'package:autoquill_ai/features/transcription/domain/repositories/transcription_repository.dart';
import '../accessibility/domain/repositories/accessibility_repository.dart';
import 'clipboard_listener_service.dart';
import '../hotkeys/services/clipboard_service.dart';
import '../hotkeys/utils/hotkey_converter.dart';
import '../hotkeys/core/hotkey_handler.dart';

/// Service to handle assistant mode functionality
class AssistantService {
  static final AssistantService _instance = AssistantService._internal();

  factory AssistantService() {
    return _instance;
  }

  AssistantService._internal() {
    _clipboardListenerService.init();
    // Initialize stats service without awaiting to avoid blocking constructor
    _initStats();
  }

  // Initialize stats service asynchronously
  Future<void> _initStats() async {
    try {
      await _statsService.init();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing stats service: $e');
      }
    }
  }

  // Stats service for tracking word counts
  final StatsService _statsService = StatsService();

  // Flag to track if clipboard listener is active
  bool _isListening = false; // Used in handleAssistantHotkey()

  // Clipboard listener service
  final _clipboardListenerService = ClipboardListenerService();

  // Repositories
  RecordingRepository? _recordingRepository;
  TranscriptionRepository? _transcriptionRepository;

  // Accessibility repository for OCR-based text extraction
  final _accessibilityRepository = AccessibilityRepository();

  // Flag to track if recording is in progress
  bool _isRecording = false;

  // Selected text from clipboard
  String? _selectedText;

  // Path to the recorded audio file
  String? _recordedFilePath;

  // Recording start time for tracking duration
  DateTime? _recordingStartTime;

  /// Set the repositories for recording and transcription
  void setRepositories(RecordingRepository recordingRepository,
      TranscriptionRepository transcriptionRepository) {
    _recordingRepository = recordingRepository;
    _transcriptionRepository = transcriptionRepository;
  }

  /// Handle the assistant hotkey press
  Future<void> handleAssistantHotkey() async {
    if (_recordingRepository == null || _transcriptionRepository == null) {
      BotToast.showText(text: 'Recording system not initialized');
      return;
    }

    // Check if API key is available
    final apiKey = Hive.box('settings').get('groq_api_key');
    if (apiKey == null || apiKey.isEmpty) {
      BotToast.showText(
          text: 'No API key found. Please add your Groq API key in Settings.');
      return;
    }

    if (kDebugMode) {
      print('Assistant hotkey pressed');
    }

    // If already recording, stop and process
    if (_isRecording) {
      await _stopRecordingAndProcess(apiKey);
      return;
    }

    // Not recording yet, so start the text selection process
    BotToast.showText(text: 'Assistant mode activated');

    // Simulate copy command to get selected text
    await _simulateCopyCommand();

    // Start watching for clipboard changes
    _clipboardListenerService.startWatching(
      onTextChanged: _handleSelectedText,
      onTimeout: _handleTimeout,
      onEmpty: _handleEmptyClipboard,
    );
  }

  /// Simulate copy command (Meta + C)
  Future<void> _simulateCopyCommand() async {
    try {
      // Simulate key down for Meta + C
      await keyPressSimulator.simulateKeyDown(
        PhysicalKeyboardKey.keyC,
        [ModifierKey.metaModifier],
      );

      // Simulate key up for Meta + C
      await keyPressSimulator.simulateKeyUp(
        PhysicalKeyboardKey.keyC,
        [ModifierKey.metaModifier],
      );

      if (kDebugMode) {
        print('Copy command simulated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error simulating copy command: $e');
      }
      BotToast.showText(text: 'Error simulating copy command');
    }
  }

  /// Simulate paste command (Meta + V)
  Future<void> _simulatePasteCommand() async {
    try {
      // Play typing sound for paste operation
      await SoundPlayer.playTypingSound();

      // Simulate key down for Meta + V
      await keyPressSimulator.simulateKeyDown(
        PhysicalKeyboardKey.keyV,
        [ModifierKey.metaModifier],
      );

      // Simulate key up for Meta + V
      await keyPressSimulator.simulateKeyUp(
        PhysicalKeyboardKey.keyV,
        [ModifierKey.metaModifier],
      );

      if (kDebugMode) {
        print('Paste command simulated');
      }

      // Now that we've pasted the text, hide the overlay
      await RecordingOverlayPlatform.hideOverlay();
    } catch (e) {
      if (kDebugMode) {
        print('Error simulating paste command: $e');
      }
      // Play error sound
      await SoundPlayer.playErrorSound();
      BotToast.showText(text: 'Error simulating paste command');

      // Hide the overlay even if there's an error
      await RecordingOverlayPlatform.hideOverlay();
    }
  }

  /// Handle the selected text from clipboard
  Future<void> _handleSelectedText(String text) async {
    if (kDebugMode) {
      print('Selected text: ${text.length} characters');
    }

    // Store the selected text
    _selectedText = text;

    // Show toast with the length of selected text
    BotToast.showText(
        text: 'Selected ${text.length} characters. Recording instructions...');

    // Start recording the user's speech
    await _startRecording();
  }

  /// Handle timeout when no clipboard changes are detected
  Future<void> _handleTimeout() async {
    if (kDebugMode) {
      print('Clipboard change timeout');
    }

    BotToast.showText(
        text: 'No text selected. Recording instructions for generation...');

    // Set selected text to null to indicate generation-only mode
    _selectedText = null;

    // Start recording the user's speech
    await _startRecording();
  }

  /// Handle empty clipboard
  Future<void> _handleEmptyClipboard() async {
    if (kDebugMode) {
      print('Clipboard is empty');
    }

    BotToast.showText(
        text: 'No text selected. Recording instructions for generation...');

    // Set selected text to null to indicate generation-only mode
    _selectedText = null;

    // Start recording the user's speech
    await _startRecording();
  }

  /// Start recording the user's speech
  Future<void> _startRecording() async {
    if (_recordingRepository == null) {
      BotToast.showText(text: 'Recording system not initialized');
      return;
    }

    // Check if any recording is already in progress
    if (RecordingOverlayPlatform.isRecordingInProgress) {
      BotToast.showText(text: 'Another recording is already in progress');
      return;
    }

    try {
      // Register Esc key for cancellation
      await HotkeyHandler.registerEscKeyForRecording();

      // Play the start recording sound
      await SoundPlayer.playStartRecordingSound();

      // Get the assistant hotkey for display
      final assistantHotkey = _getHotkeyDisplayString('assistant_hotkey');

      // Show the overlay with the assistant mode and hotkey info
      await RecordingOverlayPlatform.showOverlayWithModeAndHotkeys(
          'Assistant', assistantHotkey, 'Esc');
      await _recordingRepository!.startRecording();
      _isRecording = true;
      _recordingStartTime = DateTime.now();
      BotToast.showText(
          text: 'Recording started. Press assistant hotkey again to stop.');
    } catch (e) {
      if (kDebugMode) {
        print('Error starting recording: $e');
      }
      // Unregister Esc key if recording failed to start
      await HotkeyHandler.unregisterEscKeyForRecording();
      // Play error sound
      await SoundPlayer.playErrorSound();
      BotToast.showText(text: 'Failed to start recording');
      await RecordingOverlayPlatform.hideOverlay();
    }
  }

  /// Stop recording and process the audio
  Future<void> _stopRecordingAndProcess(String apiKey) async {
    if (!_isRecording ||
        _recordingRepository == null ||
        _transcriptionRepository == null) {
      return;
    }

    try {
      // Play the stop recording sound
      await SoundPlayer.playStopRecordingSound();

      // Stop recording
      _recordedFilePath = await _recordingRepository!.stopRecording();
      _isRecording = false;

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
            print('Error updating transcription time in assistant service: $e');
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
      await _transcribeAndProcess(apiKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping recording: $e');
      }
      // Play error sound
      await SoundPlayer.playErrorSound();
      BotToast.showText(text: 'Error processing recording');
    }
  }

  /// Transcribe the audio and process with Groq API
  Future<void> _transcribeAndProcess(String apiKey) async {
    if (_recordedFilePath == null) {
      BotToast.showText(text: 'Missing recording');
      // Hide the overlay since we can't proceed
      await RecordingOverlayPlatform.hideOverlay();
      return;
    }

    try {
      // Update overlay to show we're processing the audio
      await RecordingOverlayPlatform.setProcessingAudio();

      // Transcribe the audio
      final response = await _transcriptionRepository!
          .transcribeAudio(_recordedFilePath!, apiKey);
      final transcribedText = response.text;

      if (kDebugMode) {
        print('Transcribed text: $transcribedText');
      }

      // Update overlay to show transcription is complete
      await RecordingOverlayPlatform.setTranscriptionCompleted();

      // Determine the mode based on whether text was selected
      final String mode = _selectedText == null ? 'generation' : 'editing';
      BotToast.showText(
          text: 'Transcription complete, processing with AI for $mode...');

      // Send to Groq API - pass _selectedText as is (can be null)
      await _sendToGroqAPI(transcribedText, _selectedText, apiKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error in transcription: $e');
      }
      // Hide the overlay on error
      await RecordingOverlayPlatform.hideOverlay();
      BotToast.showText(text: 'Transcription failed: $e');
    }
  }

  /// Send the transcribed text and selected text to Groq API
  Future<void> _sendToGroqAPI(
      String transcribedText, String? selectedText, String apiKey) async {
    try {
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

      // Prepare the message content
      final String content;

      // Check if screenshot feature is enabled
      final screenshotEnabled = Hive.box('settings')
          .get('assistant_screenshot_enabled', defaultValue: false) as bool;

      // Variables for screenshot handling
      String? screenshotPath;
      String? screenshotBase64;

      // Capture screenshot if enabled
      if (screenshotEnabled) {
        try {
          BotToast.showText(text: 'Capturing screen for context...');

          // Capture screenshot using the new cross-platform implementation
          screenshotPath = await _accessibilityRepository.captureScreenshot();

          if (screenshotPath == null) {
            BotToast.showText(
              text: 'Could not capture screenshot. Using only text input.',
              duration: const Duration(seconds: 3),
            );
          } else {
            // Convert screenshot to base64
            screenshotBase64 =
                await _accessibilityRepository.imageToBase64(screenshotPath);

            if (screenshotBase64 == null) {
              BotToast.showText(
                text: 'Could not process screenshot. Using only text input.',
                duration: const Duration(seconds: 3),
              );
            } else {
              BotToast.showText(
                text: 'Successfully captured screenshot for context.',
                duration: const Duration(seconds: 2),
              );

              if (kDebugMode) {
                print('Screenshot captured and encoded: $screenshotPath');
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error capturing screenshot: $e');
          }
          BotToast.showText(
            text: 'Error capturing screenshot: ${e.toString()}',
            duration: const Duration(seconds: 3),
          );
        }
      }
      if (selectedText != null) {
        // Edit mode - instruction followed by text to edit
        content = '$transcribedText: $selectedText';
      } else {
        // Generation mode - just the instruction
        content = transcribedText;
      }

      // Get the selected assistant model from settings
      final settingsBox = Hive.box('settings');
      final selectedModel = settingsBox.get('assistant-model') ??
          'meta-llama/llama-4-scout-17b-16e-instruct';

      // Prepare the request body
      final Map<String, dynamic> requestBody;

      // Check if we have a screenshot to include in the request
      if (screenshotBase64 != null) {
        // Using multimodal API format with image
        final List<Map<String, dynamic>> messages = [
          {
            'role': 'system',
            'content': selectedText != null
                ? 'You are a text editor that rewrites text based on instructions and visual context. Your response MUST contain ONLY the edited text with NO introductory phrases or explanations.'
                : 'You are a helpful text generation assistant that uses visual context to inform your responses. Your response MUST contain ONLY the generated text with NO introductory phrases or explanations.'
          },
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': selectedText != null
                    ? 'I will give you instructions followed by text to edit. The format will be "[INSTRUCTIONS]: [TEXT]". The screenshot shows what is on my screen for context. Only return the edited text with no additional comments or explanations. Here is my request: $content'
                    : 'I need you to generate text based on the following instructions. The screenshot shows what is on my screen for context. Only return the generated text with no additional comments or explanations. Here is my request: $content'
              },
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/png;base64,$screenshotBase64'}
              }
            ]
          }
        ];

        requestBody = {
          'model': selectedModel,
          'messages': messages,
          'temperature': 0.2,
          'max_completion_tokens': 2000,
          'stream': false
        };
      } else {
        // Text-only API format (no image)
        if (selectedText != null) {
          // Edit mode - use system prompt for text editing
          final List<Map<String, dynamic>> messages = [
            {
              'role': 'system',
              'content':
                  'You are a text editor that rewrites text based on instructions. CRITICAL: Your response MUST contain ONLY the edited text with ABSOLUTELY NO introductory phrases, NO explanations, NO "Here is the rewritten text", NO comments about what you did, and NO concluding remarks. Do not start with "Here", "I", or any other introductory word. Just give the edited text directly. The user will only see your exact output, so it must be ready to use immediately.'
            },
            {
              'role': 'user',
              'content':
                  'I will give you instructions followed by text to edit. The format will be "[INSTRUCTIONS]: [TEXT]". Only return the edited text with no additional comments or explanations. Do not start with "Here", "I", or any other introductory word or phrase.'
            },
            {
              'role': 'assistant',
              'content':
                  'I understand. I will only return the edited text with no additional comments or explanations.'
            },
            {
              'role': 'user',
              'content':
                  'IMPORTANT: Your response must start with the edited text directly. Do not include any preamble like "Here is" or "I have". $content'
            }
          ];

          requestBody = {
            'model': selectedModel,
            'messages': messages,
            'temperature': 0.2,
            'max_tokens': 2000
          };
        } else {
          // Generation mode - use system prompt for text generation
          final List<Map<String, dynamic>> messages = [
            {
              'role': 'system',
              'content':
                  'You are a helpful text generation assistant. CRITICAL: Your response MUST contain ONLY the generated text with ABSOLUTELY NO introductory phrases, NO explanations, NO "Here is the text", NO comments about what you did, and NO concluding remarks. Do not start with "Here", "I", or any other introductory word. Just give the generated text directly. The user will only see your exact output, so it must be ready to use immediately.'
            },
            {
              'role': 'user',
              'content':
                  'I will give you instructions for generating text. Only return the generated text with no additional comments or explanations. Do not start with "Here", "I", or any other introductory word or phrase.'
            },
            {
              'role': 'assistant',
              'content':
                  'I understand. I will only return the generated text with no additional comments or explanations.'
            },
            {
              'role': 'user',
              'content':
                  'IMPORTANT: Your response must start with the generated text directly. Do not include any preamble like "Here is" or "I have". $content'
            }
          ];

          requestBody = {
            'model': selectedModel,
            'messages': messages,
            'temperature': 0.2,
            'max_tokens': 2000
          };
        }
      }

      // Encode the final body with UTF-8
      final body = utf8.encode(jsonEncode(requestBody));

      // Send the request
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Extract the AI response from the JSON response with proper UTF-8 decoding
        final responseString = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonResponse = jsonDecode(responseString);
        var aiResponse = jsonResponse['choices'][0]['message']['content'];

        // print(aiResponse);

        // Post-process the response to remove common preambles
        // aiResponse = _cleanAIResponse(aiResponse);

        if (kDebugMode) {
          print('AI Response: $aiResponse');
        }

        // Copy the AI response to clipboard using the clipboard service
        // This will handle both test page and regular usage
        await ClipboardService.copyToClipboard(aiResponse, mode: 'assistant');

        BotToast.showText(text: 'AI response copied to clipboard');

        // Note: ClipboardService.copyToClipboard() now handles both pasting and overlay hiding

        // Now that the overlay is hidden, update word counts using StatsService
        try {
          // Update transcription words
          if (transcribedText.isNotEmpty) {
            await _statsService.addTranscriptionWords(transcribedText);
          }

          // Update generated words
          if (aiResponse.isNotEmpty) {
            await _statsService.addGenerationWords(aiResponse);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error updating word counts in assistant service: $e');
          }

          // Fallback: Update directly in the stats box
          try {
            // Ensure stats box is open
            if (!Hive.isBoxOpen('stats')) {
              await Hive.openBox('stats');
            }

            final box = Hive.box('stats');

            // Update transcription words
            if (transcribedText.isNotEmpty) {
              final transcriptionWordCount =
                  transcribedText.trim().split(RegExp(r'\s+')).length;
              final currentTranscriptionCount =
                  box.get('transcription_words_count', defaultValue: 0);
              box.put('transcription_words_count',
                  currentTranscriptionCount + transcriptionWordCount);
            }

            // Update generated words
            if (aiResponse.isNotEmpty) {
              final generationWordCount =
                  aiResponse.trim().split(RegExp(r'\s+')).length;
              final currentGenerationCount =
                  box.get('generation_words_count', defaultValue: 0);
              box.put('generation_words_count',
                  currentGenerationCount + generationWordCount);
            }
          } catch (boxError) {
            if (kDebugMode) {
              print(
                  'Error updating word counts directly in stats box: $boxError');
            }
          }
        }
      } else {
        if (kDebugMode) {
          print('API Error: ${response.statusCode} ${response.body}');
        }
        BotToast.showText(text: 'API Error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending to API: $e');
      }
      BotToast.showText(text: 'Error sending to API: $e');
    }
  }

  /// Get hotkey display string for the overlay
  String? _getHotkeyDisplayString(String hotkeyKey) {
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
  String _getMacKeySymbol(KeyboardKey key) {
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

  /// Check if recording is currently active
  bool get isRecording => _isRecording;

  /// Cancel the current recording
  Future<void> cancelRecording() async {
    if (!_isRecording) return;

    try {
      // Cancel the recording
      await _recordingRepository?.cancelRecording();
      _isRecording = false;
      _recordingStartTime = null;
      _recordedFilePath = null;
      _selectedText = null;

      // Unregister Esc key since recording is cancelled
      await HotkeyHandler.unregisterEscKeyForRecording();

      // Stop clipboard listener if it's active
      _clipboardListenerService.stopWatching();

      // Hide the overlay
      await RecordingOverlayPlatform.hideOverlay();

      if (kDebugMode) {
        print('Assistant recording cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cancelling assistant recording: $e');
      }
    }
  }

  /// Dispose of the service
  void dispose() {
    _clipboardListenerService.dispose();
  }
}
