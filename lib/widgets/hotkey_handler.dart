import 'package:hotkey_manager/hotkey_manager.dart';

import 'package:autoquill_ai/features/recording/presentation/bloc/recording_bloc.dart';
import 'package:autoquill_ai/features/recording/domain/repositories/recording_repository.dart';
import 'package:autoquill_ai/features/transcription/presentation/bloc/transcription_bloc.dart';
import 'package:autoquill_ai/features/transcription/domain/repositories/transcription_repository.dart';
import 'package:autoquill_ai/features/hotkeys/utils/hotkey_registration.dart';

// Import the refactored implementation
import 'package:autoquill_ai/features/hotkeys/core/hotkey_handler.dart' as refactored;

/// A centralized class for handling keyboard hotkeys throughout the application
/// This is a facade that forwards calls to the refactored implementation
class HotkeyHandler {
  
  /// Set the blocs and repositories for handling recording and transcription
  static void setBlocs(RecordingBloc recordingBloc, TranscriptionBloc transcriptionBloc, 
      RecordingRepository recordingRepository, TranscriptionRepository transcriptionRepository) {
    // Forward to refactored implementation
    refactored.HotkeyHandler.setBlocs(
      recordingBloc, 
      transcriptionBloc, 
      recordingRepository, 
      transcriptionRepository
    );
  }

  /// Handles keyDown events for any registered hotkey
  static void keyDownHandler(HotKey hotKey) {
    // Forward to refactored implementation
    refactored.HotkeyHandler.keyDownHandler(hotKey);
  }

  /// Handles keyUp events for any registered hotkey
  static void keyUpHandler(HotKey hotKey) {
    // Forward to refactored implementation
    refactored.HotkeyHandler.keyUpHandler(hotKey);
  }

  /// Registers a hotkey with the system
  static Future<void> registerHotKey(HotKey hotKey, String setting) async {
    // Forward to refactored implementation in HotkeyRegistration
    await HotkeyRegistration.registerHotKey(
      hotKey, 
      setting, 
      refactored.HotkeyHandler.keyDownHandler, 
      refactored.HotkeyHandler.keyUpHandler
    );
  }

  /// Unregisters a hotkey from the system
  static Future<void> unregisterHotKey(String setting) async {
    // Forward to refactored implementation in HotkeyRegistration
    await HotkeyRegistration.unregisterHotKey(setting);
  }

  /// Prepares hotkeys for lazy loading
  /// This method quickly reads hotkeys from storage without registering them
  static Future<void> prepareHotkeys() async {
    // Forward to refactored implementation
    await HotkeyRegistration.prepareHotkeys();
  }

  // _registerHotkeyFromCache is now private in the refactored implementation

  /// Loads and registers all stored hotkeys from settings in parallel
  static Future<void> loadAndRegisterStoredHotkeys() async {
    // Forward to refactored implementation
    await HotkeyRegistration.loadAndRegisterStoredHotkeys(
      keyDownHandler: refactored.HotkeyHandler.keyDownHandler,
      keyUpHandler: refactored.HotkeyHandler.keyUpHandler
    );
  }
  
  /// Lazy loads hotkeys after UI is rendered
  static Future<void> lazyLoadHotkeys() async {
    // Forward to refactored implementation
    await refactored.HotkeyHandler.lazyLoadHotkeys();
  }
  
  /// Reloads all hotkeys to ensure changes take effect immediately
  /// This unregisters all existing hotkeys and registers them again from storage
  static Future<void> reloadHotkeys() async {
    // Forward to refactored implementation
    await refactored.HotkeyHandler.reloadHotkeys();
  }
  
  // _handleTranscriptionHotkey is now in TranscriptionHotkeyHandler
  
  // _handleAssistantHotkey is now in AssistantHotkeyHandler
  
  // _handleAgentHotkey is now in AgentHotkeyHandler
  
  // _handleTextHotkey is now in TextHotkeyHandler
  
  // _transcribeAndCopyToClipboard is now in TranscriptionHotkeyHandler
  
  // _copyToClipboard is now in ClipboardService
  
  // _simulatePasteCommand is now in ClipboardService
}
