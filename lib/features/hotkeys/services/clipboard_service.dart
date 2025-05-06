import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:keypress_simulator/keypress_simulator.dart';
import 'package:flutter/services.dart';

/// Service for handling clipboard operations
class ClipboardService {
  /// Copy text to clipboard using pasteboard and then simulate paste command
  static Future<void> copyToClipboard(String text) async {
    try {
      // Copy plain text to clipboard
      Pasteboard.writeText(text);
      
      if (kDebugMode) {
        print('Transcription copied to clipboard');
      }
      
      // Also save as a file in the app documents directory for backup
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${appDir.path}/transcription_$timestamp.txt';
        final file = File(filePath);
        await file.writeAsString(text);
        
        if (kDebugMode) {
          print('Transcription saved to file: $filePath');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error saving transcription to file: $e');
        }
      }
      
      // Simulate paste command (Meta + V) after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      await _simulatePasteCommand();
      
    } catch (e) {
      if (kDebugMode) {
        print('Error copying to clipboard: $e');
      }
    }
  }
  
  /// Simulate paste command (Meta + V)
  static Future<void> _simulatePasteCommand() async {
    try {
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
    } catch (e) {
      if (kDebugMode) {
        print('Error simulating paste command: $e');
      }
    }
  }
}
