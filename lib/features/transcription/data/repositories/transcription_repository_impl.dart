import '../datasources/transcription_local_datasource.dart';
import '../../domain/repositories/transcription_repository.dart';

class TranscriptionRepositoryImpl implements TranscriptionRepository {
  final TranscriptionLocalDataSource localDataSource;

  TranscriptionRepositoryImpl({required this.localDataSource});

  @override
  Future<String?> getTranscription(String audioPath) {
    return localDataSource.getTranscription(audioPath);
  }

  @override
  Future<void> saveTranscription(String audioPath, String transcription) {
    return localDataSource.saveTranscription(audioPath, transcription);
  }
}
