import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/recording_repository.dart';

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
  const RecordingInProgress({required bool isPaused}) 
      : super(isRecording: true, isPaused: isPaused);
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

  RecordingBloc({required this.repository}) : super(const RecordingInitial()) {
    on<StartRecording>(_onStartRecording);
    on<StopRecording>(_onStopRecording);
    on<PauseRecording>(_onPauseRecording);
    on<ResumeRecording>(_onResumeRecording);
    on<CancelRecording>(_onCancelRecording);
  }

  Future<void> _onStartRecording(StartRecording event, Emitter<RecordingState> emit) async {
    try {
      await repository.startRecording();
      emit(const RecordingInProgress(isPaused: false));
    } catch (e) {
      emit(RecordingError(message: e.toString()));
    }
  }

  Future<void> _onStopRecording(StopRecording event, Emitter<RecordingState> emit) async {
    try {
      final filePath = await repository.stopRecording();
      emit(RecordingComplete(filePath: filePath));
    } catch (e) {
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
}
