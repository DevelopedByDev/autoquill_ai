import 'package:flutter/foundation.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:keypress_simulator/keypress_simulator.dart';
import '../../../core/storage/transcription_storage.dart';
import 'package:flutter/services.dart';
import '../../../features/recording/data/platform/recording_overlay_platform.dart';
import '../../../core/utils/sound_player.dart';
import 'test_page_manager.dart';

/// Service for handling clipboard operations
class ClipboardService {
  /// Copy text to clipboard using pasteboard and then simulate paste command
  /// If test page is active, send text directly to it instead
  static Future<void> copyToClipboard(String text, {String? mode}) async {
    try {
      // Trim any leading/trailing whitespace before copying to clipboard
      var processedText = text.trim();

      // Add a space at the end for transcription and push-to-talk modes
      // to enable seamless continuation of transcriptions
      if (mode == 'transcription' || mode == 'push_to_talk') {
        processedText = '$processedText ';
      }

      // Update overlay to show transcription is complete
      await RecordingOverlayPlatform.setTranscriptionCompleted();

      // Copy plain text to clipboard
      Pasteboard.writeText(processedText);

      if (kDebugMode) {
        print('Transcription copied to clipboard');
      }

      // Check if test page is active and send directly to it
      if (TestPageManager.isTestPageActive) {
        if (kDebugMode) {
          print('Test page is active, sending result directly (mode: $mode)');
        }

        // Send to appropriate test field based on mode
        switch (mode) {
          case 'push_to_talk':
            TestPageManager.sendPushToTalkResult(processedText);
            break;
          case 'transcription':
            TestPageManager.sendTranscriptionResult(processedText);
            break;
          case 'assistant':
            TestPageManager.sendAssistantResult(processedText);
            break;
          default:
            // Default to transcription if mode not specified
            TestPageManager.sendTranscriptionResult(processedText);
            break;
        }

        // Play typing sound for feedback
        await SoundPlayer.playTypingSound();

        // Hide overlay after sending to test page
        await RecordingOverlayPlatform.hideOverlay();
      } else {
        // Normal behavior: simulate paste command for regular app usage
        await Future.delayed(const Duration(milliseconds: 200));
        await _simulatePasteCommand();
      }

      // After processing, save as a file in the dedicated transcriptions directory for backup
      // Note: Save the original trimmed text without the extra space for file storage
      try {
        final filePath =
            await TranscriptionStorage.saveTranscription(text.trim());

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
