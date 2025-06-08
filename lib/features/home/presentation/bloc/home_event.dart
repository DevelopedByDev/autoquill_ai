import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeStats extends HomeEvent {
  const LoadHomeStats();
}

class UpdateHomeStats extends HomeEvent {
  final int transcriptionWordsCount;
  final int generationWordsCount;
  final int transcriptionTimeSeconds;

  const UpdateHomeStats({
    required this.transcriptionWordsCount,
    required this.generationWordsCount,
    required this.transcriptionTimeSeconds,
  });

  @override
  List<Object?> get props => [
        transcriptionWordsCount,
        generationWordsCount,
        transcriptionTimeSeconds,
      ];
}

class StartHeaderAnimation extends HomeEvent {
  const StartHeaderAnimation();
}

class StartCardsAnimation extends HomeEvent {
  const StartCardsAnimation();
}
