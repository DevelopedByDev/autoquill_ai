import 'package:flutter/services.dart';

class RecordingOverlayPlatform {
  static const MethodChannel _channel = MethodChannel('com.autoquill.recording_overlay');

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
    } on PlatformException catch (e) {
      print('Failed to hide overlay: ${e.message}');
    }
  }
}
