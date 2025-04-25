import '../../data/models/transcription_response.dart';

abstract class TranscriptionRepository {
  Future<TranscriptionResponse> transcribeAudio(String audioPath, String apiKey);
  Future<void> saveTranscription(String audioPath, String transcription);
  Future<String?> getTranscription(String audioPath);
}
