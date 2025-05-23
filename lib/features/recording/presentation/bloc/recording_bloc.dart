import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/recording_repository.dart';
import '../../../../core/stats/stats_service.dart';

// Events
abstract class RecordingEvent extends Equatable {
  const RecordingEvent();

  @override
  List<Object?> get props => [];
}

class StartRecording extends RecordingEvent {}
class StopRecording extends RecordingEvent {}
class PauseRecording extends RecordingEvent {}
class ResumeRecording extends RecordingEvent {}
class CancelRecording extends RecordingEvent {}
class RestartRecording extends RecordingEvent {}

// States
abstract class RecordingState extends Equatable {
  final bool isRecording;
  final bool isPaused;
  final String? recordedFilePath;

  const RecordingState({
    required this.isRecording,
    required this.isPaused,
    this.recordedFilePath,
  });

  @override
  List<Object?> get props => [isRecording, isPaused, recordedFilePath];
}

class RecordingInitial extends RecordingState {
  const RecordingInitial() : super(isRecording: false, isPaused: false);
}

class RecordingInProgress extends RecordingState {
  const RecordingInProgress({required super.isPaused}) 
      : super(isRecording: true);
}

class RecordingComplete extends RecordingState {
  const RecordingComplete({required String filePath}) 
      : super(isRecording: false, isPaused: false, recordedFilePath: filePath);
}

class RecordingError extends RecordingState {
  final String message;

  const RecordingError({required this.message}) 
      : super(isRecording: false, isPaused: false);

  @override
  List<Object?> get props => [...super.props, message];
}

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final RecordingRepository repository;
  final StatsService _statsService = StatsService();
  DateTime? _recordingStartTime;

  RecordingBloc({required this.repository}) : super(const RecordingInitial()) {
    // Initialize stats service
    _initStats();
    on<StartRecording>(_onStartRecording);
    on<StopRecording>(_onStopRecording);
    on<PauseRecording>(_onPauseRecording);
    on<ResumeRecording>(_onResumeRecording);
    on<CancelRecording>(_onCancelRecording);
    on<RestartRecording>(_onRestartRecording);
  }

  // Initialize stats service asynchronously
  Future<void> _initStats() async {
    try {
      await _statsService.init();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing stats service: $e');
      }
    }
  }

  Future<void> _onStartRecording(StartRecording event, Emitter<RecordingState> emit) async {
    try {
      await repository.startRecording();
      _recordingStartTime = DateTime.now();
      emit(const RecordingInProgress(isPaused: false));
    } catch (e) {
      emit(RecordingError(message: e.toString()));
    }
  }

  Future<void> _onStopRecording(StopRecording event, Emitter<RecordingState> emit) async {
    try {
      final filePath = await repository.stopRecording();
      
      // Calculate recording duration
      if (_recordingStartTime != null) {
        final recordingDuration = DateTime.now().difference(_recordingStartTime!);
        await _statsService.addTranscriptionTime(recordingDuration.inSeconds);
        _recordingStartTime = null;
      }
      
      emit(RecordingComplete(filePath: filePath));
    } catch (e) {
      _recordingStartTime = null;
      emit(RecordingError(message: e.toString()));
    }
  }

  Future<void> _onPauseRecording(PauseRecording event, Emitter<RecordingState> emit) async {
    try {
      await repository.pauseRecording();
      emit(const RecordingInProgress(isPaused: true));
    } catch (e) {
      emit(RecordingError(message: e.toString()));
    }
  }

  Future<void> _onResumeRecording(ResumeRecording event, Emitter<RecordingState> emit) async {
    try {
      await repository.resumeRecording();
      emit(const RecordingInProgress(isPaused: false));
    } catch (e) {
      emit(RecordingError(message: e.toString()));
    }
  }

  Future<void> _onCancelRecording(CancelRecording event, Emitter<RecordingState> emit) async {
    try {
      await repository.cancelRecording();
      emit(const RecordingInitial());
    } catch (e) {
      emit(RecordingError(message: e.toString()));
    }
  }
  
  Future<void> _onRestartRecording(RestartRecording event, Emitter<RecordingState> emit) async {
    try {
      await repository.restartRecording();
      emit(const RecordingInProgress(isPaused: false));
    } catch (e) {
      emit(RecordingError(message: e.toString()));
    }
  }
}
