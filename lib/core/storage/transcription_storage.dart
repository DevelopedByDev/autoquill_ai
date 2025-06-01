import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Utility class for managing transcription storage
class TranscriptionStorage {
  /// Get the directory where transcriptions are stored
  static Future<Directory> getTranscriptionsDirectory() async {
    // Use application support directory (no special permissions needed)
    final appSupportDir = await getApplicationSupportDirectory();
    return Directory('${appSupportDir.path}/transcriptions');
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
