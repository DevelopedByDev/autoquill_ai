import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:keypress_simulator/keypress_simulator.dart';
import 'clipboard_listener_service.dart';

/// Service to handle assistant mode functionality
class AssistantService {
  static final AssistantService _instance = AssistantService._internal();
  
  factory AssistantService() {
    return _instance;
  }
  
  AssistantService._internal() {
    _clipboardListener.init();
  }
  
  // The clipboard listener service
  final ClipboardListenerService _clipboardListener = ClipboardListenerService();
  
  /// Handle the assistant hotkey press
  Future<void> handleAssistantHotkey() async {
    if (kDebugMode) {
      print('Assistant hotkey pressed');
    }
    
    BotToast.showText(text: 'Assistant mode activated');
    
    // Simulate copy command to get selected text
    await _simulateCopyCommand();
    
    // Start watching for clipboard changes
    _clipboardListener.startWatching(
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
  
  /// Handle the selected text from clipboard
  void _handleSelectedText(String text) {
    if (kDebugMode) {
      print('Selected text: ${text.length} characters');
    }
    
    // For now, just show a toast with the length of selected text
    BotToast.showText(text: 'Selected ${text.length} characters');
    
    // TODO: Implement further processing of the selected text
    // This could involve sending it to an AI service, formatting it, etc.
  }
  
  /// Handle timeout when no clipboard changes are detected
  void _handleTimeout() {
    if (kDebugMode) {
      print('Clipboard change timeout');
    }
    
    BotToast.showText(text: 'No text was selected');
  }
  
  /// Handle empty clipboard
  void _handleEmptyClipboard() {
    if (kDebugMode) {
      print('Clipboard is empty');
    }
    
    BotToast.showText(text: 'No text was selected');
  }
  
  /// Dispose of the service
  void dispose() {
    _clipboardListener.dispose();
  }
}
