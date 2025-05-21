import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class InitializeOnboarding extends OnboardingEvent {}

// UpdateSelectedTools event removed - both tools are always enabled

class UpdateApiKey extends OnboardingEvent {
  final String apiKey;

  const UpdateApiKey({required this.apiKey});

  @override
  List<Object?> get props => [apiKey];
}

class ValidateApiKey extends OnboardingEvent {
  final String apiKey;

  const ValidateApiKey({required this.apiKey});

  @override
  List<Object?> get props => [apiKey];
}

class UpdateTranscriptionHotkey extends OnboardingEvent {
  final HotKey hotkey;

  const UpdateTranscriptionHotkey({required this.hotkey});

  @override
  List<Object?> get props => [hotkey];
}

class UpdateAssistantHotkey extends OnboardingEvent {
  final HotKey hotkey;

  const UpdateAssistantHotkey({required this.hotkey});

  @override
  List<Object?> get props => [hotkey];
}

class UpdateThemePreference extends OnboardingEvent {
  final ThemeMode themeMode;

  const UpdateThemePreference({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}

class UpdateAutoCopyPreference extends OnboardingEvent {
  final bool autoCopyEnabled;

  const UpdateAutoCopyPreference({required this.autoCopyEnabled});

  @override
  List<Object?> get props => [autoCopyEnabled];
}

class UpdateTranscriptionModel extends OnboardingEvent {
  final String modelName;

  const UpdateTranscriptionModel({required this.modelName});

  @override
  List<Object?> get props => [modelName];
}

class CompleteOnboarding extends OnboardingEvent {}

class NavigateToNextStep extends OnboardingEvent {}

class NavigateToPreviousStep extends OnboardingEvent {}

class SkipOnboarding extends OnboardingEvent {}
