import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:keypress_simulator/keypress_simulator.dart';
import 'package:autoquill_ai/features/assistant/assistant_service.dart';
import 'package:autoquill_ai/core/storage/app_storage.dart';
import 'package:autoquill_ai/widgets/hotkey_converter.dart';
import 'package:autoquill_ai/features/recording/presentation/bloc/recording_bloc.dart';
import 'package:autoquill_ai/features/recording/domain/repositories/recording_repository.dart';
import 'package:autoquill_ai/features/transcription/presentation/bloc/transcription_bloc.dart';
import 'package:autoquill_ai/features/transcription/domain/repositories/transcription_repository.dart';

/// A centralized class for handling keyboard hotkeys throughout the application
class HotkeyHandler {
  // References to the blocs for recording and transcription
  static RecordingBloc? _recordingBloc;
  static TranscriptionBloc? _transcriptionBloc;
  
  // References to repositories for direct access (bypassing blocs)
  static RecordingRepository? _recordingRepository;
  static TranscriptionRepository? _transcriptionRepository;
  
  // Flag to track if recording is in progress via hotkey
  static bool _isHotkeyRecordingActive = false;
  
  // Path to the recorded audio file when using hotkey
  static String? _hotkeyRecordedFilePath;
  
  // Assistant service for handling assistant mode
  static final AssistantService _assistantService = AssistantService();
  // Cache for converted hotkeys to avoid repeated conversions
  static final Map<String, HotKey> _hotkeyCache = {};
  
  // Flag to track if hotkeys have been loaded
  static bool _hotkeysLoaded = false;
  
  // Track active hotkeys to prevent duplicate events
  static final Set<String> _activeHotkeys = {};
  
  /// Set the blocs and repositories for handling recording and transcription
  static void setBlocs(RecordingBloc recordingBloc, TranscriptionBloc transcriptionBloc, 
      RecordingRepository recordingRepository, TranscriptionRepository transcriptionRepository) {
    _recordingBloc = recordingBloc;
    _transcriptionBloc = transcriptionBloc;
    _recordingRepository = recordingRepository;
    _transcriptionRepository = transcriptionRepository;
    
    // Initialize the assistant service with repositories
    _assistantService.setRepositories(recordingRepository, transcriptionRepository);
  }

  /// Handles keyDown events for any registered hotkey
  static void keyDownHandler(HotKey hotKey) {
    // Check if this hotkey is already being processed to avoid duplicates
    String hotkeyId = '${hotKey.hashCode}';
    
    // If this hotkey is already active, ignore this event
    if (_activeHotkeys.contains(hotkeyId)) {
      if (kDebugMode) {
        print("Ignoring duplicate keyDown for ${hotKey.debugName}");
      }
      return;
    }
    
    // Mark this hotkey as active
    _activeHotkeys.add(hotkeyId);
    
    // Debug information about the hotkey
    if (kDebugMode) {
      print("Hotkey identifier: '${hotKey.identifier}'");
      print("Blocs initialized: ${_recordingBloc != null && _transcriptionBloc != null}");
    }
    
    // Handle hotkeys based on identifier
    if (hotKey.identifier == 'transcription_hotkey') {
      if (kDebugMode) {
        print("Transcription hotkey detected, handling...");
      }
      _handleTranscriptionHotkey();
    } else if (hotKey.identifier == 'assistant_hotkey') {
      if (kDebugMode) {
        print("Assistant hotkey detected, handling...");
      }
      _handleAssistantHotkey();
    } else if (hotKey.identifier == 'agent_hotkey') {
      if (kDebugMode) {
        print("Agent hotkey detected, handling...");
      }
      _handleAgentHotkey();
    } else if (hotKey.identifier == 'text_hotkey') {
      if (kDebugMode) {
        print("Text hotkey detected, handling...");
      }
      _handleTextHotkey();
    } else if (kDebugMode) {
      print("Unknown hotkey: '${hotKey.identifier}'");
    }
    
    String log = 'keyDown ${hotKey.debugName} (${hotKey.scope})';
    BotToast.showText(text: log);
    if (kDebugMode) {
      print("keyDown ${hotKey.debugName} (${hotKey.scope})");
    }
  }

  /// Handles keyUp events for any registered hotkey
  static void keyUpHandler(HotKey hotKey) {
    // Remove this hotkey from active set on key up
    String hotkeyId = '${hotKey.hashCode}';
    _activeHotkeys.remove(hotkeyId);
    
    String log = 'keyUp   ${hotKey.debugName} (${hotKey.scope})';
    BotToast.showText(text: log);
    if (kDebugMode) {
      print("keyUp ${hotKey.debugName} (${hotKey.scope})");
    }
  }

  /// Registers a hotkey with the system
  static Future<void> registerHotKey(HotKey hotKey, String setting) async {
    try {
      await hotKeyManager.register(
        hotKey,
        keyDownHandler: keyDownHandler,
        keyUpHandler: keyUpHandler,
      );
      
      // Update cache
      _hotkeyCache[setting] = hotKey;
      
      final keyData = {
        'identifier': hotKey.identifier,
        'key': {
          'keyId': hotKey.key is LogicalKeyboardKey
              ? (hotKey.key as LogicalKeyboardKey).keyId
              : null,
          'usageCode': hotKey.key is PhysicalKeyboardKey
              ? (hotKey.key as PhysicalKeyboardKey).usbHidUsage
              : null,
        },
        'modifiers': hotKey.modifiers?.map((m) => m.name).toList() ?? <String>[],
        'scope': hotKey.scope.name,
      };
      
      await AppStorage.saveHotkey(setting, keyData);
    } catch (e) {
      if (kDebugMode) {
        print('Error registering hotkey for $setting: $e');
      }
    }
  }

  /// Unregisters a hotkey from the system
  static Future<void> unregisterHotKey(String setting) async {
    try {
      // Check cache first
      if (_hotkeyCache.containsKey(setting)) {
        await hotKeyManager.unregister(_hotkeyCache[setting]!);
        _hotkeyCache.remove(setting);
      } else {
        final hotkeyData = Hive.box('settings').get(setting);
        if (hotkeyData != null) {
          final hotkey = hotKeyConverter(hotkeyData);
          await hotKeyManager.unregister(hotkey);
        }
      }
      await AppStorage.deleteHotkey(setting);
    } catch (e) {
      if (kDebugMode) {
        print('Error unregistering hotkey for $setting: $e');
      }
    }
  }

  /// Prepares hotkeys for lazy loading
  /// This method quickly reads hotkeys from storage without registering them
  static Future<void> prepareHotkeys() async {
    if (_hotkeysLoaded) return;
    
    final stopwatch = Stopwatch()..start();
    
    try {
      final settingsBox = Hive.box('settings');
      final transcriptionHotkey = settingsBox.get('transcription_hotkey');
      final assistantHotkey = settingsBox.get('assistant_hotkey');
      final agentHotkey = settingsBox.get('agent_hotkey');
      final textHotkey = settingsBox.get('text_hotkey');
      
      // Convert hotkeys and store in cache (fast operation)
      if (transcriptionHotkey != null) {
        final hotkey = hotKeyConverter(transcriptionHotkey);
        // Explicitly set the identifier
        final updatedHotkey = HotKey(
          key: hotkey.key,
          modifiers: hotkey.modifiers,
          scope: hotkey.scope,
          identifier: 'transcription_hotkey',
        );
        _hotkeyCache['transcription_hotkey'] = updatedHotkey;
      }
      
      if (assistantHotkey != null) {
        final hotkey = hotKeyConverter(assistantHotkey);
        // Explicitly set the identifier
        final updatedHotkey = HotKey(
          key: hotkey.key,
          modifiers: hotkey.modifiers,
          scope: hotkey.scope,
          identifier: 'assistant_hotkey',
        );
        _hotkeyCache['assistant_hotkey'] = updatedHotkey;
      }
      
      if (agentHotkey != null) {
        final hotkey = hotKeyConverter(agentHotkey);
        // Explicitly set the identifier
        final updatedHotkey = HotKey(
          key: hotkey.key,
          modifiers: hotkey.modifiers,
          scope: hotkey.scope,
          identifier: 'agent_hotkey',
        );
        _hotkeyCache['agent_hotkey'] = updatedHotkey;
      }
      
      if (textHotkey != null) {
        final hotkey = hotKeyConverter(textHotkey);
        // Explicitly set the identifier
        final updatedHotkey = HotKey(
          key: hotkey.key,
          modifiers: hotkey.modifiers,
          scope: hotkey.scope,
          identifier: 'text_hotkey',
        );
        _hotkeyCache['text_hotkey'] = updatedHotkey;
      }
      
      _hotkeysLoaded = true;
      
      if (kDebugMode) {
        print('Prepared hotkeys in ${stopwatch.elapsedMilliseconds}ms');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error preparing hotkeys: $e');
      }
    }
  }

  /// Registers a single hotkey from the cache
  static Future<void> _registerHotkeyFromCache(String setting) async {
    if (!_hotkeyCache.containsKey(setting)) return;
    
    try {
      final hotkey = _hotkeyCache[setting]!;
      await hotKeyManager.register(
        hotkey,
        keyDownHandler: keyDownHandler,
        keyUpHandler: keyUpHandler,
      );
      
      if (kDebugMode) {
        print('Registered $setting hotkey');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering $setting hotkey: $e');
      }
    }
  }

  /// Loads and registers all stored hotkeys from settings in parallel
  static Future<void> loadAndRegisterStoredHotkeys() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // First unregister all existing hotkeys to avoid conflicts
      await hotKeyManager.unregisterAll();
      
      // Clear the active hotkeys set
      _activeHotkeys.clear();
      
      // First prepare the hotkeys (fast operation)
      await prepareHotkeys();
      
      // Register hotkeys in parallel
      final futures = <Future>[];
      
      for (final setting in _hotkeyCache.keys) {
        futures.add(_registerHotkeyFromCache(setting));
      }
      
      // Wait for all registrations to complete
      await Future.wait(futures);
      
      if (kDebugMode) {
        print('Registered all hotkeys in ${stopwatch.elapsedMilliseconds}ms');
        print('Active hotkeys: ${_hotkeyCache.keys.join(', ')}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering hotkeys: $e');
      }
    } finally {
      stopwatch.stop();
    }
  }
  
  /// Lazy loads hotkeys after UI is rendered
  static Future<void> lazyLoadHotkeys() async {
    // Delay to ensure UI is rendered
    await Future.delayed(const Duration(milliseconds: 500));
    await loadAndRegisterStoredHotkeys();
  }
  
  /// Handles the transcription hotkey press
  static void _handleTranscriptionHotkey() async {
    if (_recordingRepository == null || _transcriptionRepository == null) {
      BotToast.showText(text: 'Recording system not initialized');
      return;
    }
    
    // Check if API key is available
    final apiKey = Hive.box('settings').get('groq_api_key');
    if (apiKey == null || apiKey.isEmpty) {
      BotToast.showText(text: 'No API key found. Please add your Groq API key in Settings.');
      return;
    }
    
    if (!_isHotkeyRecordingActive) {
      // Start recording directly using the repository
      try {
        await _recordingRepository!.startRecording();
        _isHotkeyRecordingActive = true;
        BotToast.showText(text: 'Recording started');
      } catch (e) {
        BotToast.showText(text: 'Failed to start recording: $e');
      }
    } else {
      // Stop recording and transcribe directly
      try {
        // Stop recording
        _hotkeyRecordedFilePath = await _recordingRepository!.stopRecording();
        _isHotkeyRecordingActive = false;
        BotToast.showText(text: 'Recording stopped, transcribing...');
        
        // Transcribe the audio
        await _transcribeAndCopyToClipboard(_hotkeyRecordedFilePath!, apiKey);
      } catch (e) {
        BotToast.showText(text: 'Error during recording or transcription: $e');
      }
    }
  }
  
  /// Handles the assistant hotkey press
  static void _handleAssistantHotkey() async {
    try {
      // Delegate to the assistant service
      await _assistantService.handleAssistantHotkey();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling assistant hotkey: $e');
      }
      BotToast.showText(text: 'Error activating assistant mode');
    }
  }
  
  /// Handles the agent hotkey press
  static void _handleAgentHotkey() async {
    try {
      // Get the selected agent model from settings
      final settingsBox = Hive.box('settings');
      final selectedModel = settingsBox.get('agent-model') ?? 'compound-beta-mini';
      
      // For now, just show a toast notification with the selected model
      if (kDebugMode) {
        print('Agent hotkey pressed, using model: $selectedModel');
      }
      BotToast.showText(text: 'Agent mode activated using $selectedModel');
    } catch (e) {
      if (kDebugMode) {
        print('Error handling agent hotkey: $e');
      }
      BotToast.showText(text: 'Error activating agent mode');
    }
  }
  
  /// Handles the text hotkey press
  static void _handleTextHotkey() async {
    try {
      // For now, just show a toast notification
      if (kDebugMode) {
        print('Text hotkey pressed');
      }
      BotToast.showText(text: 'Text mode activated');
    } catch (e) {
      if (kDebugMode) {
        print('Error handling text hotkey: $e');
      }
      BotToast.showText(text: 'Error activating text mode');
    }
  }
  
  /// Transcribe audio and copy to clipboard without affecting UI
  static Future<void> _transcribeAndCopyToClipboard(String audioPath, String apiKey) async {
    try {
      // Transcribe the audio
      final response = await _transcriptionRepository!.transcribeAudio(audioPath, apiKey);
      final transcriptionText = response.text;
      
      // Copy to clipboard
      await _copyToClipboard(transcriptionText);
      
      BotToast.showText(text: 'Transcription copied to clipboard');
    } catch (e) {
      BotToast.showText(text: 'Transcription failed: $e');
    }
  }
  
  /// Copy text to clipboard using pasteboard and then simulate paste command
  static Future<void> _copyToClipboard(String text) async {
    try {
      // Copy plain text to clipboard
      Pasteboard.writeText(text);
      
      if (kDebugMode) {
        print('Transcription copied to clipboard');
      }
      
      // Also save as a file in the app documents directory for backup
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${appDir.path}/transcription_$timestamp.txt';
        final file = File(filePath);
        await file.writeAsString(text);
        
        if (kDebugMode) {
          print('Transcription saved to file: $filePath');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error saving transcription to file: $e');
        }
      }
      
      // Simulate paste command (Meta + V) after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      await _simulatePasteCommand();
      
    } catch (e) {
      if (kDebugMode) {
        print('Error copying to clipboard: $e');
      }
    }
  }
  
  /// Simulate paste command (Meta + V)
  static Future<void> _simulatePasteCommand() async {
    try {
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
    } catch (e) {
      if (kDebugMode) {
        print('Error simulating paste command: $e');
      }
    }
  }
}
