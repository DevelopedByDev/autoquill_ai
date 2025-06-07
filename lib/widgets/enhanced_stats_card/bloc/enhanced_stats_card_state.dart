import 'package:equatable/equatable.dart';

class EnhancedStatsCardState extends Equatable {
  final double scale;
  final double opacity;
  final bool animationComplete;
  
  const EnhancedStatsCardState({
    this.scale = 0.8,
    this.opacity = 0.0,
    this.animationComplete = false,
  });
  
  EnhancedStatsCardState copyWith({
    double? scale,
    double? opacity,
    bool? animationComplete,
  }) {
    return EnhancedStatsCardState(
      scale: scale ?? this.scale,
      opacity: opacity ?? this.opacity,
      animationComplete: animationComplete ?? this.animationComplete,
    );
  }
  
  @override
  List<Object> get props => [scale, opacity, animationComplete];
}
