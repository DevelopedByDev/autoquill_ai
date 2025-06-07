import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/design_tokens.dart';
import 'enhanced_loading_indicator_event.dart';
import 'enhanced_loading_indicator_state.dart';

class EnhancedLoadingIndicatorBloc extends Bloc<EnhancedLoadingIndicatorEvent, EnhancedLoadingIndicatorState> {
  final AnimationController rotationController;
  final AnimationController pulseController;
  final AnimationController dotsController;
  
  late Animation<double> rotationAnimation;
  late Animation<double> pulseAnimation;
  late Animation<double> dotsAnimation;
  
  EnhancedLoadingIndicatorBloc({
    required this.rotationController,
    required this.pulseController,
    required this.dotsController,
    required LoadingType initialType,
  }) : super(EnhancedLoadingIndicatorState(type: initialType)) {
    on<StartAnimations>(_onStartAnimations);
    on<StopAnimations>(_onStopAnimations);
    
    // Initialize animations
    _setupAnimations();
    add(StartAnimations(type: initialType));
  }
  
  void _setupAnimations() {
    rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: rotationController,
      curve: Curves.linear,
    ));

    pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: pulseController,
      curve: Curves.easeInOut,
    ));

    dotsAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: dotsController,
      curve: Curves.easeInOut,
    ));
    
    // Set durations
    rotationController.duration = const Duration(seconds: 2);
    pulseController.duration = DesignTokens.durationLong;
    dotsController.duration = const Duration(milliseconds: 1200);
  }
  
  void _onStartAnimations(StartAnimations event, Emitter<EnhancedLoadingIndicatorState> emit) {
    emit(state.copyWith(type: event.type, isAnimating: true));
    
    switch (event.type) {
      case LoadingType.circular:
      case LoadingType.gradient:
        rotationController.repeat();
        break;
      case LoadingType.pulsing:
        pulseController.repeat(reverse: true);
        break;
      case LoadingType.dots:
        dotsController.repeat();
        break;
    }
  }
  
  void _onStopAnimations(StopAnimations event, Emitter<EnhancedLoadingIndicatorState> emit) {
    rotationController.stop();
    pulseController.stop();
    dotsController.stop();
    emit(state.copyWith(isAnimating: false));
  }
  
  @override
  Future<void> close() {
    rotationController.dispose();
    pulseController.dispose();
    dotsController.dispose();
    return super.close();
  }
}
