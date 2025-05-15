import 'package:flutter/services.dart';
import 'dart:io';

/// Platform-specific implementation for accessibility features
class AccessibilityPlatform {
  static const MethodChannel _channel = MethodChannel('com.autoquill.recording_overlay');
  
  /// Extracts visible text from the active application screen using OCR (macOS only)
  static Future<String> extractVisibleText() async {
    if (!Platform.isMacOS) {
      return 'Text extraction is only supported on macOS';
    }
    
    try {
      final String result = await _channel.invokeMethod('extractVisibleText');
      return result;
    } on PlatformException catch (e) {
      return 'Failed to extract text: ${e.message}';
    }
  }
}
