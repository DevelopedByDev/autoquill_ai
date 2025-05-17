import 'package:flutter/foundation.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:autoquill_ai/features/recording/presentation/bloc/recording_bloc.dart';
import 'package:autoquill_ai/features/recording/domain/repositories/recording_repository.dart';
import 'package:autoquill_ai/features/transcription/presentation/bloc/transcription_bloc.dart';
import 'package:autoquill_ai/features/transcription/domain/repositories/transcription_repository.dart';
import 'package:autoquill_ai/features/assistant/assistant_service.dart';

import '../handlers/transcription_hotkey_handler.dart';
import '../handlers/assistant_hotkey_handler.dart';
import '../utils/hotkey_registration.dart';

/// A centralized class for handling keyboard hotkeys throughout the application
class HotkeyHandler {
  // References to the blocs for recording and transcription
  static RecordingBloc? _recordingBloc;
  static TranscriptionBloc? _transcriptionBloc;
  
  // Assistant service for handling assistant mode
  static final AssistantService _assistantService = AssistantService();
  
  // Track active hotkeys to prevent duplicate events
  static final Set<String> _activeHotkeys = {};
  
  /// Set the blocs and repositories for handling recording and transcription
  static void setBlocs(RecordingBloc recordingBloc, TranscriptionBloc transcriptionBloc, 
      RecordingRepository recordingRepository, TranscriptionRepository transcriptionRepository) {
    _recordingBloc = recordingBloc;
    _transcriptionBloc = transcriptionBloc;
    
    // Initialize the assistant service with repositories
    _assistantService.setRepositories(recordingRepository, transcriptionRepository);
    
    // Initialize the handlers with repositories
    TranscriptionHotkeyHandler.initialize(recordingRepository, transcriptionRepository);
    AssistantHotkeyHandler.initialize(_assistantService);
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
      TranscriptionHotkeyHandler.handleHotkey();
    } else if (hotKey.identifier == 'assistant_hotkey') {
      if (kDebugMode) {
        print("Assistant hotkey detected, handling...");
      }
      AssistantHotkeyHandler.handleHotkey();

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

  /// Lazy loads hotkeys after UI is rendered
  static Future<void> lazyLoadHotkeys() async {
    // Delay to ensure UI is rendered
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // First unregister all existing hotkeys to avoid conflicts
    await hotKeyManager.unregisterAll();
    
    // Force reload hotkeys from storage
    await HotkeyRegistration.reloadAllHotkeys(
      keyDownHandler: keyDownHandler,
      keyUpHandler: keyUpHandler,
    );
    
    if (kDebugMode) {
      print('Hotkeys loaded and registered on app startup');
    }
  }
  
  /// Reloads all hotkeys to ensure changes take effect immediately
  /// This unregisters all existing hotkeys and registers them again from storage
  static Future<void> reloadHotkeys() async {
    if (kDebugMode) {
      print('Reloading all hotkeys to apply changes immediately');
    }
    
    // Clear the active hotkeys set to prevent duplicate events
    _activeHotkeys.clear();
    
    // Reload all hotkeys from storage
    await HotkeyRegistration.reloadAllHotkeys(
      keyDownHandler: keyDownHandler,
      keyUpHandler: keyUpHandler,
    );
    
    // Show a toast notification to inform the user
    BotToast.showText(text: 'Hotkey changes applied successfully');
  }
}
