import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for managing sound settings and platform-specific sound functionality
class SoundService {
  static const MethodChannel _channel = MethodChannel('com.autoquill.sound');

  /// Sets the sound enabled state on the platform side
  static Future<void> setSoundEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setSoundEnabled', {'enabled': enabled});
      if (kDebugMode) {
        print('Sound enabled state set to: $enabled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting sound enabled state: $e');
      }
    }
  }

  /// Gets the sound enabled state from the platform side
  static Future<bool> getSoundEnabled() async {
    try {
      final result = await _channel.invokeMethod('getSoundEnabled');
      return result as bool? ?? true;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting sound enabled state: $e');
      }
      return true; // Default to enabled
    }
  }

  /// Plays a system sound on macOS
  /// Available sound types: glass, ping, pop, purr, sosumi, submarine, blow, bottle, frog, funk, morse
  static Future<void> playSystemSound(String soundType) async {
    try {
      await _channel.invokeMethod('playSystemSound', {'type': soundType});
    } catch (e) {
      if (kDebugMode) {
        print('Error playing system sound: $e');
      }
    }
  }

  /// Convenience methods for common system sounds
  static Future<void> playGlassSound() => playSystemSound('glass');
  static Future<void> playPingSound() => playSystemSound('ping');
  static Future<void> playPopSound() => playSystemSound('pop');
  static Future<void> playPurrSound() => playSystemSound('purr');
}
