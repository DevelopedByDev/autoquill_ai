import '../../domain/repositories/recording_repository.dart';
import '../datasources/recording_datasource.dart';

class RecordingRepositoryImpl implements RecordingRepository {
  final RecordingDataSource dataSource;

  RecordingRepositoryImpl({required this.dataSource});

  @override
  Future<void> startRecording() => dataSource.startRecording();

  @override
  Future<String> stopRecording() => dataSource.stopRecording();

  @override
  Future<void> pauseRecording() => dataSource.pauseRecording();

  @override
  Future<void> resumeRecording() => dataSource.resumeRecording();

  @override
  Future<void> cancelRecording() => dataSource.cancelRecording();

  @override
  Future<bool> get isRecording => dataSource.isRecording;

  @override
  Future<bool> get isPaused => dataSource.isPaused;
}
