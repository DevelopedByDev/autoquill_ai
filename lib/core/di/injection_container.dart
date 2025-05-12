import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:record/record.dart';
import '../../features/transcription/data/datasources/transcription_local_datasource.dart';
import '../../features/transcription/data/repositories/transcription_repository_impl.dart';
import '../../features/transcription/domain/repositories/transcription_repository.dart';
import '../../features/recording/data/datasources/recording_datasource.dart';
import '../../features/recording/data/repositories/recording_repository_impl.dart';
import '../../features/recording/domain/repositories/recording_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc is provided directly in main.dart

  // Repositories
  sl.registerLazySingleton<TranscriptionRepository>(
    () => TranscriptionRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<RecordingRepository>(
    () => RecordingRepositoryImpl(
      dataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<TranscriptionLocalDataSource>(
    () => TranscriptionLocalDataSourceImpl(
      transcriptionBox: sl(),
    ),
  );

  // Create and initialize the recording data source
  final recordingDataSource = RecordingDataSourceImpl(
    recorder: AudioRecorder(),
  );
  
  // Initialize the recording system immediately
  await recordingDataSource.initialize();
  
  sl.registerLazySingleton<RecordingDataSource>(
    () => recordingDataSource,
  );

  // External
  final transcriptionBox = await Hive.openBox<String>('transcriptions');
  sl.registerLazySingleton(() => transcriptionBox);
  sl.registerLazySingleton(() => AudioRecorder());
}
