import 'package:hive/hive.dart';

abstract class TranscriptionLocalDataSource {
  Future<void> saveTranscription(String audioPath, String transcription);
  Future<String?> getTranscription(String audioPath);
}

class TranscriptionLocalDataSourceImpl implements TranscriptionLocalDataSource {
  final Box<String> transcriptionBox;

  TranscriptionLocalDataSourceImpl({required this.transcriptionBox});

  @override
  Future<String?> getTranscription(String audioPath) async {
    return transcriptionBox.get(audioPath);
  }

  @override
  Future<void> saveTranscription(String audioPath, String transcription) async {
    await transcriptionBox.put(audioPath, transcription);
  }
}
