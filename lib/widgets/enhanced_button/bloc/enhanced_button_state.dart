import 'package:equatable/equatable.dart';

class EnhancedButtonState extends Equatable {
  final bool isPressed;
  final double scale;

  const EnhancedButtonState({
    this.isPressed = false,
    this.scale = 1.0,
  });

  EnhancedButtonState copyWith({
    bool? isPressed,
    double? scale,
  }) {
    return EnhancedButtonState(
      isPressed: isPressed ?? this.isPressed,
      scale: scale ?? this.scale,
    );
  }

  @override
  List<Object> get props => [isPressed, scale];
}
