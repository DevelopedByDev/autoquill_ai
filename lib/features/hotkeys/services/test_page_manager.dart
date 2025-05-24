import 'package:flutter/foundation.dart';

/// Manager for handling transcription results on the test page
/// This allows the test page to receive transcription results directly
/// instead of relying on system paste commands
class TestPageManager {
  static bool _isTestPageActive = false;
  static Function(String)? _onPushToTalkResult;
  static Function(String)? _onTranscriptionResult;
  static Function(String)? _onAssistantResult;

  /// Register the test page to receive transcription results
  static void registerTestPage({
    required Function(String) onPushToTalkResult,
    required Function(String) onTranscriptionResult,
    required Function(String) onAssistantResult,
  }) {
    _isTestPageActive = true;
    _onPushToTalkResult = onPushToTalkResult;
    _onTranscriptionResult = onTranscriptionResult;
    _onAssistantResult = onAssistantResult;

    if (kDebugMode) {
      print('Test page registered for direct transcription results');
    }
  }

  /// Unregister the test page
  static void unregisterTestPage() {
    _isTestPageActive = false;
    _onPushToTalkResult = null;
    _onTranscriptionResult = null;
    _onAssistantResult = null;

    if (kDebugMode) {
      print('Test page unregistered from transcription results');
    }
  }

  /// Check if test page is currently active
  static bool get isTestPageActive => _isTestPageActive;

  /// Send push-to-talk result to test page
  static void sendPushToTalkResult(String text) {
    if (_isTestPageActive && _onPushToTalkResult != null) {
      _onPushToTalkResult!(text);
      if (kDebugMode) {
        print(
            'Push-to-talk result sent to test page: ${text.length} characters');
      }
    }
  }

  /// Send transcription result to test page
  static void sendTranscriptionResult(String text) {
    if (_isTestPageActive && _onTranscriptionResult != null) {
      _onTranscriptionResult!(text);
      if (kDebugMode) {
        print(
            'Transcription result sent to test page: ${text.length} characters');
      }
    }
  }

  /// Send assistant result to test page
  static void sendAssistantResult(String text) {
    if (_isTestPageActive && _onAssistantResult != null) {
      _onAssistantResult!(text);
      if (kDebugMode) {
        print('Assistant result sent to test page: ${text.length} characters');
      }
    }
  }
}
