import 'package:flutter/foundation.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:keypress_simulator/keypress_simulator.dart';
import '../../../core/storage/transcription_storage.dart';
import 'package:flutter/services.dart';
import '../../../features/recording/data/platform/recording_overlay_platform.dart';
import '../../../core/utils/sound_player.dart';

/// Service for handling clipboard operations
class ClipboardService {
  /// Copy text to clipboard using pasteboard and then simulate paste command
  static Future<void> copyToClipboard(String text) async {
    try {
      // Trim any leading/trailing whitespace before copying to clipboard
      final trimmedText = text.trim();
      
      // Update overlay to show transcription is complete
      await RecordingOverlayPlatform.setTranscriptionCompleted();
      
      // Copy plain text to clipboard
      Pasteboard.writeText(trimmedText);
      
      if (kDebugMode) {
        print('Transcription copied to clipboard');
      }
      
      // Simulate paste command (Meta + V) after a short delay
      await Future.delayed(const Duration(milliseconds: 200));
      await _simulatePasteCommand();
      
      // After pasting, save as a file in the dedicated transcriptions directory for backup
      try {
        final filePath = await TranscriptionStorage.saveTranscription(trimmedText);
        
        if (kDebugMode) {
          print('Transcription saved to file: $filePath');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error saving transcription to file: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error copying to clipboard: $e');
      }
      // Hide the overlay on error
      await RecordingOverlayPlatform.hideOverlay();
    }
  }
  
  
  /// Simulate paste command (Meta + V)
  static Future<void> _simulatePasteCommand() async {
    try {
      // Play typing sound for paste operation
      await SoundPlayer.playTypingSound();
      
      // Simulate key down for Meta + V
      await keyPressSimulator.simulateKeyDown(
        PhysicalKeyboardKey.keyV,
        [ModifierKey.metaModifier],
      );
      
      // Simulate key up for Meta + V
      await keyPressSimulator.simulateKeyUp(
        PhysicalKeyboardKey.keyV,
        [ModifierKey.metaModifier],
      );
      
      if (kDebugMode) {
        print('Paste command simulated');
      }
      
      // Now that we've pasted the text, hide the overlay
      await RecordingOverlayPlatform.hideOverlay();
    } catch (e) {
      if (kDebugMode) {
        print('Error simulating paste command: $e');
      }
      // Play error sound
      await SoundPlayer.playErrorSound();
      
      // Hide the overlay even if there's an error
      await RecordingOverlayPlatform.hideOverlay();
    }
  }
}
