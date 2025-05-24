import 'dart:io';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import '../platform/recording_overlay_platform.dart';
import '../../utils/audio_utils.dart';

abstract class RecordingDataSource {
  Future<void> startRecording();
  Future<String> stopRecording();
  Future<void> pauseRecording();
  Future<void> resumeRecording();
  Future<void> cancelRecording();
  Future<void> restartRecording();
  Future<bool> get isRecording;
  Future<bool> get isPaused;
}

class RecordingDataSourceImpl implements RecordingDataSource {
  final AudioRecorder recorder;
  String? _currentRecordingPath;
  // ignore: unused_field
  bool _isRecording = false;
  bool _isInitialized = false;

  // Track recording start time to calculate duration
  DateTime? _recordingStartTime;

  // Minimum recording duration in seconds
  static const int _minimumRecordingDuration = 5;

  RecordingDataSourceImpl({required this.recorder});

  /// Initialize the recording system
  /// This should be called when the app starts to ensure the recording system is ready
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Only setup the directory structure, don't check permissions yet
      // Permissions will be checked when the user actually tries to record

      // Ensure the recordings directory exists
      final recordingsDir = await _getRecordingsDirectory();
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      // Validate that we can write to the directory
      final testFile = File('${recordingsDir.path}/test_init.txt');
      await testFile.writeAsString('test');
      await testFile.delete();

      _isInitialized = true;
      if (kDebugMode) {
        print(
            'Recording system initialized successfully (without permission check)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing recording system: $e');
      }
      // We'll try again when needed
    }
  }

  Future<Directory> _getRecordingsDirectory() async {
    // Get system Documents directory
    final home = Platform.environment['HOME'];
    if (home == null) throw Exception('Could not find home directory');

    return Directory('$home/Documents/AutoQuillAIRecordings');
  }

  Future<String> _getRecordingPath() async {
    final recordingsDir = await _getRecordingsDirectory();
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }

    // Generate a unique filename based on timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${recordingsDir.path}/recording_$timestamp.wav';
  }

  @override
  Future<void> startRecording() async {
    if (kDebugMode) {
      print('Recording started');
    }

    // Ensure the recording system is initialized
    if (!_isInitialized) {
      await initialize();
    }

    if (!await recorder.hasPermission()) {
      throw Exception('Microphone permission not granted');
    }

    // Get a unique path for this recording
    _currentRecordingPath = await _getRecordingPath();
    if (kDebugMode) {
      print('Recording to: $_currentRecordingPath');
    }

    final config = RecordConfig(
      encoder: AudioEncoder.wav, // Using WAV format as recommended by Groq API
      bitRate: 128000,
      sampleRate: 44100,
    );

    await recorder.start(config, path: _currentRecordingPath!);
    _isRecording = true;

    // Store the recording start time
    _recordingStartTime = DateTime.now();
    if (kDebugMode) {
      print('Recording started at: $_recordingStartTime');
    }

    // Show the recording overlay
    await RecordingOverlayPlatform.showOverlay();

    // Start sending audio levels to the platform
    RecordingOverlayPlatform.startSendingAudioLevels(() async {
      // Get the current amplitude from the recorder
      // The record package doesn't provide direct amplitude access,
      // so we'll use a simulated value for now
      return _getSimulatedAudioLevel();
    });
  }

  // Simulates an audio level between 0.0 and 1.0
  // In a real implementation, this would get the actual audio level from the recorder
  double _getSimulatedAudioLevel() {
    // Generate a somewhat realistic audio pattern
    // Base level plus some randomness
    final baseLevel = 0.2;
    final randomComponent = math.Random().nextDouble() * 0.6;

    // Occasionally add a spike for more natural look
    final spike = math.Random().nextInt(10) == 0 ? 0.3 : 0.0;

    return math.min(1.0, baseLevel + randomComponent + spike);
  }

  @override
  Future<String> stopRecording() async {
    if (kDebugMode) {
      print('Recording stopped');
    }
    final recordingEndTime = DateTime.now();

    // Stop the recording immediately to capture only what the user intended
    final path = await recorder.stop();
    if (path == null) throw Exception('Failed to stop recording');

    _isRecording = false;

    // Update the overlay text to show recording stopped
    await RecordingOverlayPlatform.setRecordingStopped();

    // Check if we need to pad the recording with silence
    String finalPath = path;
    if (_recordingStartTime != null) {
      final recordingDuration =
          recordingEndTime.difference(_recordingStartTime!).inMilliseconds /
              1000.0;
      if (kDebugMode) {
        print('Recording duration: $recordingDuration seconds');
      }

      if (recordingDuration < _minimumRecordingDuration) {
        if (kDebugMode) {
          print(
              'Recording too short, padding with silence to reach $_minimumRecordingDuration seconds');
        }

        try {
          // Pad the recording with silence to reach the minimum duration
          finalPath = await AudioUtils.padWithSilence(
              path, Duration(seconds: _minimumRecordingDuration));
          if (kDebugMode) {
            print('Successfully padded recording with silence: $finalPath');
          }

          // Delete the original file if it's different from the padded one
          if (finalPath != path) {
            try {
              await File(path).delete();
              if (kDebugMode) {
                print('Deleted original short recording file');
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error deleting original recording file: $e');
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error padding recording with silence: $e');
          }
          // If padding fails, we'll use the original recording
          finalPath = path;
        }
      }
    }

    _currentRecordingPath = null;
    _recordingStartTime = null;
    return finalPath;
  }

  @override
  Future<void> pauseRecording() async {
    await recorder.pause();
  }

  @override
  Future<void> resumeRecording() async {
    await recorder.resume();
  }

  @override
  Future<bool> get isRecording async => await recorder.isRecording();

  @override
  Future<bool> get isPaused async => await recorder.isPaused();

  @override
  Future<void> cancelRecording() async {
    if (await isRecording && _currentRecordingPath != null) {
      await recorder.stop();
      _isRecording = false;
      // Delete the current recording file
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
      _currentRecordingPath = null;
      _recordingStartTime = null;

      // Hide the recording overlay
      await RecordingOverlayPlatform.hideOverlay();
    }
  }

  @override
  Future<void> restartRecording() async {
    // First stop the current recording but don't hide the overlay yet
    if (await isRecording) {
      await recorder.stop();
      _isRecording = false;

      // Delete the current recording file if it exists
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Reset recording start time
      _recordingStartTime = null;
    }

    // Then start a new recording
    await startRecording();
  }
}
