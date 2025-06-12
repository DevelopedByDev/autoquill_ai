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
    {
      'name': 'large-v3_947MB',
      'size': '~947 MB',
      'description': 'High quality, optimized'
    },
    {
      'name': 'large-v3-v20240930_turbo_632MB',
      'size': '~632 MB',
      'description': 'Fast and accurate'
    },
  ];

  /// Downloads a WhisperKit model
  /// Returns a stream of download progress (0.0 to 1.0)
  static Stream<double> downloadModel(String modelName) async* {
    try {
      if (kDebugMode) {
        print('WhisperKitService: Starting download for model: $modelName');
      }

      // Yield initial progress to show download has started
      yield 0.1;

      // Start the download (this will run asynchronously)
      _channel.invokeMethod('downloadModel', {'modelName': modelName});

      if (kDebugMode) {
        print('WhisperKitService: Download initiated, simulating progress...');
      }

      // Simulate download progress and poll for completion
      double progress = 0.1;
      const maxPollingTime = Duration(minutes: 10); // Maximum wait time
      const pollInterval = Duration(seconds: 2);
      final startTime = DateTime.now();

      while (progress < 1.0) {
        await Future.delayed(pollInterval);

        // Check if download is complete
        try {
          final isDownloaded = await isModelDownloaded(modelName);
          if (isDownloaded) {
            progress = 1.0;
            yield 1.0;
            if (kDebugMode) {
              print('WhisperKitService: Download completed for $modelName');
            }
            break;
          }
        } catch (e) {
          if (kDebugMode) {
            print('WhisperKitService: Error checking download status: $e');
          }
        }

        // Check timeout
        if (DateTime.now().difference(startTime) > maxPollingTime) {
          throw Exception('Download timeout for model $modelName');
        }

        // Increment progress simulation (this gives visual feedback)
        progress = (progress + 0.1).clamp(0.0, 0.9);
        yield progress;

        if (kDebugMode) {
          print(
              'WhisperKitService: Simulated progress $progress for $modelName');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('WhisperKitService: Error downloading model $modelName: $e');
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

  /// Preloads a WhisperKit model for faster transcriptions
  static Future<void> preloadModel(String modelName) async {
    try {
      await _channel.invokeMethod('preloadModel', {
        'modelName': modelName,
      });
      if (kDebugMode) {
        print('Successfully preloaded model: $modelName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error preloading model $modelName: $e');
      }
      throw Exception('Failed to preload model: $e');
    }
  }

  /// Transcribes audio using a local WhisperKit model
  static Future<String> transcribeAudio(
      String audioPath, String modelName) async {
    try {
      final result = await _channel.invokeMethod('transcribeAudio', {
        'audioPath': audioPath,
        'modelName': modelName,
      });
      return result as String? ?? '';
    } catch (e) {
      if (kDebugMode) {
        print('Error transcribing audio with local model: $e');
      }
      throw Exception('Local transcription failed: $e');
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

  /// Initializes a model by running test inference on the sample audio file
  /// This ensures the model is fully loaded and ready for use
  static Future<bool> initializeModelWithTestAudio(String modelName) async {
    try {
      if (kDebugMode) {
        print(
            'WhisperKitService: Initializing model $modelName with test audio...');
      }

      // First check if model is downloaded
      final isDownloaded = await isModelDownloaded(modelName);
      if (!isDownloaded) {
        if (kDebugMode) {
          print('WhisperKitService: Model $modelName is not downloaded');
        }
        return false;
      }

      // Preload the model first
      await preloadModel(modelName);

      // Run test inference with the sample audio
      final result = await _channel.invokeMethod('initializeWithTestAudio', {
        'modelName': modelName,
      });

      final success = result as bool? ?? false;

      if (kDebugMode) {
        if (success) {
          print(
              'WhisperKitService: Model $modelName successfully initialized with test audio');
        } else {
          print(
              'WhisperKitService: Failed to initialize model $modelName with test audio');
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print(
            'WhisperKitService: Error initializing model $modelName with test audio: $e');
      }
      return false;
    }
  }

  /// Checks if a model is currently initialized and ready for use
  static Future<bool> isModelInitialized(String modelName) async {
    try {
      final result = await _channel.invokeMethod('isModelInitialized', {
        'modelName': modelName,
      });
      return result as bool? ?? false;
    } catch (e) {
      if (kDebugMode) {
        print(
            'WhisperKitService: Error checking if model $modelName is initialized: $e');
      }
      return false;
    }
  }
}
