import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for managing WhisperKit local transcription models
class WhisperKitService {
  static const MethodChannel _channel =
      MethodChannel('com.autoquill.whisperkit');

  /// Available model variants
  static const List<Map<String, String>> availableModels = [
    {'name': 'base', 'size': '~150 MB', 'description': 'Fastest, good quality'},
    {
      'name': 'small',
      'size': '~450 MB',
      'description': 'Good speed and quality'
    },
    {
      'name': 'medium',
      'size': '~1.5 GB',
      'description': 'Balanced performance'
    },
    {'name': 'large', 'size': '~3.1 GB', 'description': 'High quality, slower'},
    {'name': 'turbo', 'size': '~800 MB', 'description': 'Fast and accurate'},
  ];

  /// Downloads a WhisperKit model
  /// Returns a stream of download progress (0.0 to 1.0)
  static Stream<double> downloadModel(String modelName) async* {
    try {
      if (kDebugMode) {
        print('Starting download for model: $modelName');
      }

      // Start the download
      await _channel.invokeMethod('downloadModel', {'modelName': modelName});

      // Listen for progress updates
      const progressChannel = EventChannel('com.autoquill.whisperkit.progress');
      await for (final progress in progressChannel.receiveBroadcastStream()) {
        if (progress is Map && progress['modelName'] == modelName) {
          final progressValue =
              (progress['progress'] as num?)?.toDouble() ?? 0.0;
          yield progressValue;

          if (progressValue >= 1.0) {
            break;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading model $modelName: $e');
      }
      throw Exception('Failed to download model: $e');
    }
  }

  /// Gets the list of locally downloaded models
  static Future<List<String>> getDownloadedModels() async {
    try {
      final result = await _channel.invokeMethod('getDownloadedModels');
      return List<String>.from(result ?? []);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting downloaded models: $e');
      }
      return [];
    }
  }

  /// Checks if a specific model is downloaded
  static Future<bool> isModelDownloaded(String modelName) async {
    try {
      final result = await _channel
          .invokeMethod('isModelDownloaded', {'modelName': modelName});
      return result as bool? ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if model $modelName is downloaded: $e');
      }
      return false;
    }
  }

  /// Deletes a downloaded model
  static Future<bool> deleteModel(String modelName) async {
    try {
      final result =
          await _channel.invokeMethod('deleteModel', {'modelName': modelName});
      return result as bool? ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting model $modelName: $e');
      }
      return false;
    }
  }

  /// Gets the storage size of a downloaded model
  static Future<String> getModelSize(String modelName) async {
    try {
      final result =
          await _channel.invokeMethod('getModelSize', {'modelName': modelName});
      return result as String? ?? 'Unknown';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting size for model $modelName: $e');
      }
      return 'Unknown';
    }
  }

  /// Gets the path to the models directory
  static Future<String?> getModelsDirectory() async {
    try {
      final result = await _channel.invokeMethod('getModelsDirectory');
      return result as String?;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting models directory: $e');
      }
      return null;
    }
  }

  /// Opens the models directory in Finder
  static Future<bool> openModelsDirectory() async {
    try {
      final result = await _channel.invokeMethod('openModelsDirectory');
      return result as bool? ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error opening models directory: $e');
      }
      return false;
    }
  }

  /// Initializes WhisperKit (loads available models, etc.)
  static Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
      if (kDebugMode) {
        print('WhisperKit service initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing WhisperKit: $e');
      }
    }
  }
}
