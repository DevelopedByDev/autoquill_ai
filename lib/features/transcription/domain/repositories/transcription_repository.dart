abstract class TranscriptionRepository {
  Future<void> saveTranscription(String audioPath, String transcription);
  Future<String?> getTranscription(String audioPath);
}
