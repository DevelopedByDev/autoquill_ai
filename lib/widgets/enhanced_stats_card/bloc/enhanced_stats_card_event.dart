import 'package:equatable/equatable.dart';

abstract class EnhancedStatsCardEvent extends Equatable {
  const EnhancedStatsCardEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAnimation extends EnhancedStatsCardEvent {
  final bool showAnimation;
  
  const InitializeAnimation({required this.showAnimation});
  
  @override
  List<Object?> get props => [showAnimation];
}

class ResetAnimation extends EnhancedStatsCardEvent {
  const ResetAnimation();
}
