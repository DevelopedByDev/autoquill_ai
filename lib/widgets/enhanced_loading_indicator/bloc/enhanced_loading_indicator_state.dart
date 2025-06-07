import 'package:equatable/equatable.dart';
import 'enhanced_loading_indicator_event.dart';

class EnhancedLoadingIndicatorState extends Equatable {
  final LoadingType type;
  final bool isAnimating;
  
  const EnhancedLoadingIndicatorState({
    required this.type,
    this.isAnimating = false,
  });
  
  EnhancedLoadingIndicatorState copyWith({
    LoadingType? type,
    bool? isAnimating,
  }) {
    return EnhancedLoadingIndicatorState(
      type: type ?? this.type,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }
  
  @override
  List<Object> get props => [type, isAnimating];
}
