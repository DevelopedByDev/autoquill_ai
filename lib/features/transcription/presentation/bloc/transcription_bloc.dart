import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:keypress_simulator/keypress_simulator.dart';
import '../../../../core/storage/app_storage.dart';

import '../../domain/repositories/transcription_repository.dart';
import '../../../recording/data/platform/recording_overlay_platform.dart';

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
  final bool previouslyLoading; // Track if the previous state was loading

  const TranscriptionState({
    this.apiKey,
    this.transcriptionText,
    this.error,
    this.isLoading = false,
    this.previouslyLoading = false,
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
      previouslyLoading: this.isLoading, // Store current loading state as previous
    );
  }

  @override
  List<Object?> get props => [apiKey, transcriptionText, error, isLoading, previouslyLoading];
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
      // Hide the overlay since we can't proceed
      await RecordingOverlayPlatform.hideOverlay();
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));
    
    // Update overlay to show we're processing the audio
    await RecordingOverlayPlatform.setProcessingAudio();

    try {
      final response = await repository.transcribeAudio(event.audioPath, apiKey);
      // Trim any leading/trailing whitespace from the transcription text
      final transcriptionText = response.text.trim();
      
      // Update overlay to show transcription is complete
      await RecordingOverlayPlatform.setTranscriptionCompleted();
      
      // Copy the transcription text to clipboard
      await _copyToClipboard(transcriptionText);
      
      emit(state.copyWith(
        transcriptionText: transcriptionText,
        isLoading: false,
        apiKey: apiKey,
      ));
    } catch (e) {
      // Hide the overlay on error
      await RecordingOverlayPlatform.hideOverlay();
      
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

  /// Copy text to clipboard using pasteboard and then simulate paste command
  Future<void> _copyToClipboard(String text) async {
    try {
      // Copy plain text to clipboard
      Pasteboard.writeText(text);
      
      if (kDebugMode) {
        print('Transcription copied to clipboard');
      }
      
      // Simulate paste command (Meta + V) after a short delay
      await Future.delayed(const Duration(milliseconds: 200));
      await _simulatePasteCommand();
      
      // After pasting, save as a file in the app documents directory for backup
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${appDir.path}/transcription_$timestamp.txt';
        final file = File(filePath);
        await file.writeAsString(text);
        
        if (kDebugMode) {
          print('Transcription saved to file: $filePath');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error saving transcription to file: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error copying to clipboard: $e');
      }
    }
  }
  
  /// Simulate paste command (Meta + V)
  Future<void> _simulatePasteCommand() async {
    try {

      
      // Simulate key down for Meta + V
      await keyPressSimulator.simulateKeyDown(
        PhysicalKeyboardKey.keyV,
        [ModifierKey.metaModifier],
      );
      
      // Simulate key up for Meta + V
      await keyPressSimulator.simulateKeyUp(
        PhysicalKeyboardKey.keyV,
        [ModifierKey.metaModifier],
      );
      
      if (kDebugMode) {
        print('Paste command simulated');
      }
      
      // Now that we've pasted the text, hide the overlay
      await RecordingOverlayPlatform.hideOverlay();
    } catch (e) {
      if (kDebugMode) {
        print('Error simulating paste command: $e');
      }
      // Hide the overlay even if there's an error
      await RecordingOverlayPlatform.hideOverlay();
    }
  }

  @override
  Future<void> close() {
    _apiKeySubscription.cancel();
    return super.close();
  }
}
