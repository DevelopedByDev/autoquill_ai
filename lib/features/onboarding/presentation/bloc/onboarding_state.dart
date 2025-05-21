import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

enum OnboardingStep {
  welcome,
  apiKey,
  hotkeys,
  preferences,
  completed
}

enum ApiKeyValidationStatus {
  initial,
  validating,
  valid,
  invalid
}

class OnboardingState extends Equatable {
  final OnboardingStep currentStep;
  final bool transcriptionEnabled;
  final bool assistantEnabled;
  final String apiKey;
  final ApiKeyValidationStatus apiKeyStatus;
  final HotKey? transcriptionHotkey;
  final HotKey? assistantHotkey;
  final ThemeMode themeMode;
  final bool autoCopyEnabled;
  final String transcriptionModel;

  const OnboardingState({
    this.currentStep = OnboardingStep.welcome,
    this.transcriptionEnabled = true,
    this.assistantEnabled = true,
    this.apiKey = '',
    this.apiKeyStatus = ApiKeyValidationStatus.initial,
    this.transcriptionHotkey,
    this.assistantHotkey,
    this.themeMode = ThemeMode.system,
    this.autoCopyEnabled = true,
    this.transcriptionModel = 'whisper-large-v3',
  });

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    bool? transcriptionEnabled,
    bool? assistantEnabled,
    String? apiKey,
    ApiKeyValidationStatus? apiKeyStatus,
    HotKey? transcriptionHotkey,
    HotKey? assistantHotkey,
    ThemeMode? themeMode,
    bool? autoCopyEnabled,
    String? transcriptionModel,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      transcriptionEnabled: transcriptionEnabled ?? this.transcriptionEnabled,
      assistantEnabled: assistantEnabled ?? this.assistantEnabled,
      apiKey: apiKey ?? this.apiKey,
      apiKeyStatus: apiKeyStatus ?? this.apiKeyStatus,
      transcriptionHotkey: transcriptionHotkey ?? this.transcriptionHotkey,
      assistantHotkey: assistantHotkey ?? this.assistantHotkey,
      themeMode: themeMode ?? this.themeMode,
      autoCopyEnabled: autoCopyEnabled ?? this.autoCopyEnabled,
      transcriptionModel: transcriptionModel ?? this.transcriptionModel,
    );
  }

  // Both tools are always enabled now
  // No need for tool selection validation
  
  bool get canProceedFromApiKey => apiKeyStatus == ApiKeyValidationStatus.valid;
  
  bool get canProceedFromHotkeys => 
    (transcriptionEnabled && transcriptionHotkey != null) &&
    (assistantEnabled ? assistantHotkey != null : true);
  
  bool get isComplete => currentStep == OnboardingStep.completed;

  @override
  List<Object?> get props => [
    currentStep,
    transcriptionEnabled,
    assistantEnabled,
    apiKey,
    apiKeyStatus,
    transcriptionHotkey,
    assistantHotkey,
    themeMode,
    autoCopyEnabled,
    transcriptionModel,
  ];
}
