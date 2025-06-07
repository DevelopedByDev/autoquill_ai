import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/design_tokens.dart';
import 'enhanced_button_event.dart';
import 'enhanced_button_state.dart';

class EnhancedButtonBloc extends Bloc<EnhancedButtonEvent, EnhancedButtonState> {
  final AnimationController animationController;
  
  EnhancedButtonBloc({required this.animationController}) 
      : super(const EnhancedButtonState()) {
    on<EnhancedButtonPressed>(_onPressed);
    on<EnhancedButtonReleased>(_onReleased);
    on<EnhancedButtonCancelled>(_onCancelled);
    
    // Initialize animation
    animationController.duration = DesignTokens.durationShort;
  }

  void _onPressed(EnhancedButtonPressed event, Emitter<EnhancedButtonState> emit) {
    animationController.forward();
    emit(state.copyWith(isPressed: true, scale: 0.95));
  }

  void _onReleased(EnhancedButtonReleased event, Emitter<EnhancedButtonState> emit) {
    animationController.reverse();
    emit(state.copyWith(isPressed: false, scale: 1.0));
  }

  void _onCancelled(EnhancedButtonCancelled event, Emitter<EnhancedButtonState> emit) {
    animationController.reverse();
    emit(state.copyWith(isPressed: false, scale: 1.0));
  }
  
  @override
  Future<void> close() {
    animationController.dispose();
    return super.close();
  }
}
