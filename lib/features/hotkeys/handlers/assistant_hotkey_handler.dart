import 'package:flutter/foundation.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:autoquill_ai/features/assistant/assistant_service.dart';

/// Handler for assistant hotkey functionality
class AssistantHotkeyHandler {
  // Assistant service for handling assistant mode
  static AssistantService? _assistantService;
  
  /// Initialize the handler with necessary services
  static void initialize(AssistantService assistantService) {
    _assistantService = assistantService;
  }
  
  /// Handles the assistant hotkey press
  static void handleHotkey() async {
    if (_assistantService == null) {
      BotToast.showText(text: 'Assistant service not initialized');
      return;
    }
    
    try {
      // Delegate to the assistant service
      await _assistantService!.handleAssistantHotkey();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling assistant hotkey: $e');
      }
      BotToast.showText(text: 'Error activating assistant mode');
    }
  }
}
