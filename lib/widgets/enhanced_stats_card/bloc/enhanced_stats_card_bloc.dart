import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/design_tokens.dart';
import 'enhanced_stats_card_event.dart';
import 'enhanced_stats_card_state.dart';

class EnhancedStatsCardBloc extends Bloc<EnhancedStatsCardEvent, EnhancedStatsCardState> {
  final AnimationController animationController;
  
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;
  
  EnhancedStatsCardBloc({required this.animationController}) 
      : super(const EnhancedStatsCardState()) {
    on<InitializeAnimation>(_onInitializeAnimation);
    on<ResetAnimation>(_onResetAnimation);
    
    // Initialize animations
    _setupAnimations();
  }
  
  void _setupAnimations() {
    animationController.duration = DesignTokens.durationLong;
    
    scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: DesignTokens.emphasizedCurve,
    ));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    ));
    
    // Listen to animation status
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        add(const ResetAnimation());
      }
    });
  }
  
  void _onInitializeAnimation(InitializeAnimation event, Emitter<EnhancedStatsCardState> emit) {
    if (event.showAnimation) {
      animationController.forward();
    } else {
      animationController.value = 1.0;
      emit(state.copyWith(scale: 1.0, opacity: 1.0, animationComplete: true));
    }
  }
  
  void _onResetAnimation(ResetAnimation event, Emitter<EnhancedStatsCardState> emit) {
    emit(state.copyWith(animationComplete: true));
  }
  
  @override
  Future<void> close() {
    animationController.dispose();
    return super.close();
  }
}
