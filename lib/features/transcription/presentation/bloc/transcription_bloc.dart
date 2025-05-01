import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/storage/app_storage.dart';
import '../../domain/repositories/transcription_repository.dart';

// Events
abstract class TranscriptionEvent extends Equatable {
  const TranscriptionEvent();

  @override
  List<Object?> get props => [];
}

class InitializeTranscription extends TranscriptionEvent {}

class UpdateApiKey extends TranscriptionEvent {
  final String? apiKey;
  const UpdateApiKey(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class StartTranscription extends TranscriptionEvent {
  final String audioPath;
  const StartTranscription(this.audioPath);

  @override
  List<Object?> get props => [audioPath];
}

class ClearTranscription extends TranscriptionEvent {}

// States
class TranscriptionState extends Equatable {
  final String? apiKey;
  final String? transcriptionText;
  final String? error;
  final bool isLoading;

  const TranscriptionState({
    this.apiKey,
    this.transcriptionText,
    this.error,
    this.isLoading = false,
  });

  TranscriptionState copyWith({
    String? apiKey,
    String? transcriptionText,
    String? error,
    bool? isLoading,
  }) {
    return TranscriptionState(
      apiKey: apiKey ?? this.apiKey,
      transcriptionText: transcriptionText ?? this.transcriptionText,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [apiKey, transcriptionText, error, isLoading];
}

class TranscriptionBloc extends Bloc<TranscriptionEvent, TranscriptionState> {
  final TranscriptionRepository repository;
  late final StreamSubscription<BoxEvent> _apiKeySubscription;

  TranscriptionBloc({required this.repository}) : super(const TranscriptionState()) {
    // Listen to API key changes
    _apiKeySubscription = Hive.box('settings').watch(key: 'groq_api_key').listen((event) async {
      final apiKey = await AppStorage.getApiKey();
      add(UpdateApiKey(apiKey));
    });
    on<InitializeTranscription>(_onInitializeTranscription);
    on<StartTranscription>(_onStartTranscription);
    on<ClearTranscription>(_onClearTranscription);
    on<UpdateApiKey>(_onUpdateApiKey);
  }

  Future<void> _onInitializeTranscription(InitializeTranscription event, Emitter<TranscriptionState> emit) async {
    final savedApiKey = await AppStorage.getApiKey();
    emit(state.copyWith(apiKey: savedApiKey));
  }

  Future<void> _onStartTranscription(StartTranscription event, Emitter<TranscriptionState> emit) async {
    final apiKey = await AppStorage.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      emit(state.copyWith(
        error: 'No API key found. Please add your Groq API key in Settings.',
        apiKey: null,
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final response = await repository.transcribeAudio(event.audioPath, apiKey);
      emit(state.copyWith(
        transcriptionText: response.text,
        isLoading: false,
        apiKey: apiKey,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Transcription failed: $e',
        isLoading: false,
      ));
    }
  }

  void _onClearTranscription(ClearTranscription event, Emitter<TranscriptionState> emit) {
    emit(state.copyWith(transcriptionText: null, error: null));
  }

  void _onUpdateApiKey(UpdateApiKey event, Emitter<TranscriptionState> emit) {
    // If API key is empty or null, treat it as null to disable the recording button
    final apiKey = event.apiKey?.isEmpty == true ? null : event.apiKey;
    emit(state.copyWith(apiKey: apiKey));
  }

  @override
  Future<void> close() {
    _apiKeySubscription.cancel();
    return super.close();
  }
}
