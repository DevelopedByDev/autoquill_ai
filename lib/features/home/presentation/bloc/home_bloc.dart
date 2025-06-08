import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/stats/stats_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final StatsService _statsService = StatsService();
  ValueListenable<Box<dynamic>>? _statsListenable;
  VoidCallback? _statsListener;

  HomeBloc() : super(const HomeState()) {
    on<LoadHomeStats>(_onLoadHomeStats);
    on<UpdateHomeStats>(_onUpdateHomeStats);
    on<StartHeaderAnimation>(_onStartHeaderAnimation);
    on<StartCardsAnimation>(_onStartCardsAnimation);
  }

  Future<void> _onLoadHomeStats(
    LoadHomeStats event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      // Initialize stats service first
      await _statsService.init();

      // Ensure the stats box is open
      if (!Hive.isBoxOpen('stats')) {
        await Hive.openBox('stats');
      }

      // Also ensure the settings box is open for API keys
      if (!Hive.isBoxOpen('settings')) {
        await Hive.openBox('settings');
      }

      final box = Hive.box('stats');
      final transcriptionWordsCount =
          box.get('transcription_words_count', defaultValue: 0);
      final generationWordsCount =
          box.get('generation_words_count', defaultValue: 0);
      final transcriptionTimeSeconds =
          box.get('transcription_time_seconds', defaultValue: 0);

      // Calculate WPM
      final wordsPerMinute = _calculateWPM(
        transcriptionWordsCount + generationWordsCount,
        transcriptionTimeSeconds,
      );

      emit(state.copyWith(
        transcriptionWordsCount: transcriptionWordsCount,
        generationWordsCount: generationWordsCount,
        transcriptionTimeSeconds: transcriptionTimeSeconds,
        wordsPerMinute: wordsPerMinute,
        isLoading: false,
      ));

      // Set up a listener for changes to the stats box
      _statsListenable?.removeListener(_statsListener ?? () {});
      _statsListenable = _statsService.getStatsBoxListenable(keys: [
        'transcription_words_count',
        'generation_words_count',
        'transcription_time_seconds'
      ]);

      _statsListener = () {
        final updatedTranscriptionWords =
            box.get('transcription_words_count', defaultValue: 0);
        final updatedGenerationWords =
            box.get('generation_words_count', defaultValue: 0);
        final updatedTranscriptionTime =
            box.get('transcription_time_seconds', defaultValue: 0);

        add(UpdateHomeStats(
          transcriptionWordsCount: updatedTranscriptionWords,
          generationWordsCount: updatedGenerationWords,
          transcriptionTimeSeconds: updatedTranscriptionTime,
        ));
      };

      _statsListenable?.addListener(_statsListener!);
    } catch (e) {
      // Handle errors gracefully
      if (kDebugMode) {
        print('Error loading home stats: $e');
      }
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load statistics',
      ));
    }
  }

  void _onUpdateHomeStats(
    UpdateHomeStats event,
    Emitter<HomeState> emit,
  ) {
    final wordsPerMinute = _calculateWPM(
      event.transcriptionWordsCount + event.generationWordsCount,
      event.transcriptionTimeSeconds,
    );

    emit(state.copyWith(
      transcriptionWordsCount: event.transcriptionWordsCount,
      generationWordsCount: event.generationWordsCount,
      transcriptionTimeSeconds: event.transcriptionTimeSeconds,
      wordsPerMinute: wordsPerMinute,
    ));
  }

  void _onStartHeaderAnimation(
    StartHeaderAnimation event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(headerAnimationStarted: true));
  }

  void _onStartCardsAnimation(
    StartCardsAnimation event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(cardsAnimationStarted: true));
  }

  double _calculateWPM(int totalWords, int timeSeconds) {
    if (timeSeconds > 0) {
      final timeMinutes = timeSeconds / 60.0;
      return totalWords / timeMinutes;
    }
    return 0.0;
  }

  @override
  Future<void> close() {
    _statsListenable?.removeListener(_statsListener ?? () {});
    return super.close();
  }
}
