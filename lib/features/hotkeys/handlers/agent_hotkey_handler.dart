import 'package:flutter/foundation.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:autoquill_ai/features/agent/agent_service.dart';

/// Handler for agent hotkey functionality
class AgentHotkeyHandler {
  // Agent service for handling agent mode
  static AgentService? _agentService;
  
  /// Initialize the handler with necessary services
  static void initialize(AgentService agentService) {
    _agentService = agentService;
  }
  
  /// Handles the agent hotkey press
  static void handleHotkey() async {
    if (_agentService == null) {
      BotToast.showText(text: 'Agent service not initialized');
      return;
    }
    
    try {
      // Delegate to the agent service
      await _agentService!.handleAgentHotkey();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling agent hotkey: $e');
      }
      BotToast.showText(text: 'Error activating agent mode');
    }
  }
}
