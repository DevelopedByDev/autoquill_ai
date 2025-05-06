import 'package:flutter/foundation.dart';
import 'package:bot_toast/bot_toast.dart';

/// Handler for text hotkey functionality
class TextHotkeyHandler {
  /// Handles the text hotkey press
  static void handleHotkey() async {
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
}
