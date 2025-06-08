import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final int transcriptionWordsCount;
  final int generationWordsCount;
  final int transcriptionTimeSeconds;
  final double wordsPerMinute;
  final bool isLoading;
  final String? error;
  final bool headerAnimationStarted;
  final bool cardsAnimationStarted;

  const HomeState({
    this.transcriptionWordsCount = 0,
    this.generationWordsCount = 0,
    this.transcriptionTimeSeconds = 0,
    this.wordsPerMinute = 0.0,
    this.isLoading = false,
    this.error,
    this.headerAnimationStarted = false,
    this.cardsAnimationStarted = false,
  });

  HomeState copyWith({
    int? transcriptionWordsCount,
    int? generationWordsCount,
    int? transcriptionTimeSeconds,
    double? wordsPerMinute,
    bool? isLoading,
    String? error,
    bool? headerAnimationStarted,
    bool? cardsAnimationStarted,
  }) {
    return HomeState(
      transcriptionWordsCount:
          transcriptionWordsCount ?? this.transcriptionWordsCount,
      generationWordsCount: generationWordsCount ?? this.generationWordsCount,
      transcriptionTimeSeconds:
          transcriptionTimeSeconds ?? this.transcriptionTimeSeconds,
      wordsPerMinute: wordsPerMinute ?? this.wordsPerMinute,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      headerAnimationStarted:
          headerAnimationStarted ?? this.headerAnimationStarted,
      cardsAnimationStarted:
          cardsAnimationStarted ?? this.cardsAnimationStarted,
    );
  }

  @override
  List<Object?> get props => [
        transcriptionWordsCount,
        generationWordsCount,
        transcriptionTimeSeconds,
        wordsPerMinute,
        isLoading,
        error,
        headerAnimationStarted,
        cardsAnimationStarted,
      ];
}
