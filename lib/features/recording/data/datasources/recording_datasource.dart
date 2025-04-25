import 'dart:io';
import 'package:record/record.dart';

abstract class RecordingDataSource {
  Future<void> startRecording();
  Future<String> stopRecording();
  Future<void> pauseRecording();
  Future<void> resumeRecording();
  Future<void> cancelRecording();
  Future<bool> get isRecording;
  Future<bool> get isPaused;
}

class RecordingDataSourceImpl implements RecordingDataSource {
  final AudioRecorder recorder;
  String? _currentRecordingPath;

  RecordingDataSourceImpl({required this.recorder});

  Future<String> _getRecordingPath() async {
    // Get system Documents directory
    final home = Platform.environment['HOME'];
    if (home == null) throw Exception('Could not find home directory');
    
    final recordingsDir = Directory('$home/Documents/AutoQuillAIRecordings');
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    
    return '${recordingsDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  @override
  Future<void> startRecording() async {
    if (!await recorder.hasPermission()) {
      throw Exception('Microphone permission not granted');
    }
    _currentRecordingPath = await _getRecordingPath();
    final config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,
    );
    await recorder.start(config, path: _currentRecordingPath!);
  }

  @override
  Future<String> stopRecording() async {
    final path = await recorder.stop();
    if (path == null) throw Exception('Failed to stop recording');
    _currentRecordingPath = null;
    return path;
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
      // Delete the current recording file
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
      _currentRecordingPath = null;
    }
  }
}
