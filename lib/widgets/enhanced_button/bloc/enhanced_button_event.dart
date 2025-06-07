import 'package:equatable/equatable.dart';

abstract class EnhancedButtonEvent extends Equatable {
  const EnhancedButtonEvent();

  @override
  List<Object?> get props => [];
}

class EnhancedButtonPressed extends EnhancedButtonEvent {
  const EnhancedButtonPressed();
}

class EnhancedButtonReleased extends EnhancedButtonEvent {
  const EnhancedButtonReleased();
}

class EnhancedButtonCancelled extends EnhancedButtonEvent {
  const EnhancedButtonCancelled();
}
