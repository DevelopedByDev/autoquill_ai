import 'dart:async';
import 'package:flutter/services.dart';

class RecordingOverlayPlatform {
  static const MethodChannel _channel = MethodChannel('com.autoquill.recording_overlay');
  static Timer? _levelUpdateTimer;

  /// Shows the recording overlay
  static Future<void> showOverlay() async {
    try {
      await _channel.invokeMethod('showOverlay');
    } on PlatformException catch (e) {
      print('Failed to show overlay: ${e.message}');
    }
  }

  /// Hides the recording overlay
  static Future<void> hideOverlay() async {
    try {
      await _channel.invokeMethod('hideOverlay');
      // Stop sending audio levels when hiding the overlay
      _stopSendingAudioLevels();
    } on PlatformException catch (e) {
      print('Failed to hide overlay: ${e.message}');
    }
  }
  
  /// Updates the audio level in the overlay
  static Future<void> updateAudioLevel(double level) async {
    try {
      await _channel.invokeMethod('updateAudioLevel', {'level': level});
    } on PlatformException catch (e) {
      print('Failed to update audio level: ${e.message}');
    }
  }
  
  /// Starts sending periodic audio level updates
  /// The audioLevelProvider function should return the current audio level (0.0 to 1.0)
  static void startSendingAudioLevels(Future<double> Function() audioLevelProvider) {
    // Stop any existing timer
    _stopSendingAudioLevels();
    
    // Start a new timer to send audio levels every 100ms
    _levelUpdateTimer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      try {
        final level = await audioLevelProvider();
        await updateAudioLevel(level);
      } catch (e) {
        print('Error getting audio level: $e');
      }
    });
  }
  
  /// Stops sending audio level updates
  static void _stopSendingAudioLevels() {
    _levelUpdateTimer?.cancel();
    _levelUpdateTimer = null;
  }
}
