import 'dart:io';
import 'package:flutter/foundation.dart';

/// Utility class for managing transcription storage
class TranscriptionStorage {
  /// Get the directory where transcriptions are stored
  static Future<Directory> getTranscriptionsDirectory() async {
    // Get system Documents directory
    final home = Platform.environment['HOME'];
    if (home == null) throw Exception('Could not find home directory');

    return Directory('$home/Documents/AutoQuillAITranscriptions');
  }

  /// Save a transcription to a file
  static Future<String> saveTranscription(String text) async {
    try {
      final transcriptionsDir = await getTranscriptionsDirectory();
      // Ensure the directory exists
      if (!await transcriptionsDir.exists()) {
        await transcriptionsDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${transcriptionsDir.path}/transcription_$timestamp.txt';
      final file = File(filePath);
      await file.writeAsString(text);
      
      if (kDebugMode) {
        print('Transcription saved to file: $filePath');
      }
      
      return filePath;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving transcription to file: $e');
      }
      rethrow;
    }
  }

  /// List all saved transcriptions
  static Future<List<FileSystemEntity>> listTranscriptions() async {
    try {
      final transcriptionsDir = await getTranscriptionsDirectory();
      if (!await transcriptionsDir.exists()) {
        return [];
      }
      
      return transcriptionsDir.listSync();
    } catch (e) {
      if (kDebugMode) {
        print('Error listing transcriptions: $e');
      }
      return [];
    }
  }
}
