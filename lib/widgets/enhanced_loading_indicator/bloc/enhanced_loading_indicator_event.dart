import 'package:equatable/equatable.dart';

abstract class EnhancedLoadingIndicatorEvent extends Equatable {
  const EnhancedLoadingIndicatorEvent();

  @override
  List<Object?> get props => [];
}

class StartAnimations extends EnhancedLoadingIndicatorEvent {
  final LoadingType type;
  
  const StartAnimations({required this.type});
  
  @override
  List<Object?> get props => [type];
}

class StopAnimations extends EnhancedLoadingIndicatorEvent {
  const StopAnimations();
}

enum LoadingType {
  circular,
  dots,
  pulsing,
  gradient,
}
