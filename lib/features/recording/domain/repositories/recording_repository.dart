abstract class RecordingRepository {
  Future<void> startRecording();
  Future<String> stopRecording();
  Future<void> pauseRecording();
  Future<void> resumeRecording();
  Future<void> cancelRecording();
  Future<void> restartRecording();
  Future<bool> get isRecording;
  Future<bool> get isPaused;
}
