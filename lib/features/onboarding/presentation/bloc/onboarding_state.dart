import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../../../../core/permissions/permission_service.dart';

enum OnboardingStep {
  welcome,
  permissions,
  apiKey,
  hotkeys,
  testHotkeys,
  preferences,
  completed
}

enum ApiKeyValidationStatus { initial, validating, valid, invalid }

class OnboardingState extends Equatable {
  final OnboardingStep currentStep;
  final bool transcriptionEnabled;
  final bool assistantEnabled;
  final String apiKey;
  final ApiKeyValidationStatus apiKeyStatus;
  final HotKey? transcriptionHotkey;
  final HotKey? assistantHotkey;
  final HotKey? pushToTalkHotkey;
  final ThemeMode themeMode;
  final bool autoCopyEnabled;
  final String transcriptionModel;
  final bool assistantScreenshotEnabled;
  final bool smartTranscriptionEnabled;
  final Map<PermissionType, PermissionStatus> permissionStatuses;

  const OnboardingState({
    this.currentStep = OnboardingStep.welcome,
    this.transcriptionEnabled = true,
    this.assistantEnabled = true,
    this.apiKey = '',
    this.apiKeyStatus = ApiKeyValidationStatus.initial,
    this.transcriptionHotkey,
    this.assistantHotkey,
    this.pushToTalkHotkey,
    this.themeMode = ThemeMode.system,
    this.autoCopyEnabled = true,
    this.transcriptionModel = 'whisper-large-v3',
    this.assistantScreenshotEnabled = false,
    this.smartTranscriptionEnabled = false,
    this.permissionStatuses = const {},
  });

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    bool? transcriptionEnabled,
    bool? assistantEnabled,
    String? apiKey,
    ApiKeyValidationStatus? apiKeyStatus,
    HotKey? transcriptionHotkey,
    HotKey? assistantHotkey,
    HotKey? pushToTalkHotkey,
    ThemeMode? themeMode,
    bool? autoCopyEnabled,
    String? transcriptionModel,
    bool? assistantScreenshotEnabled,
    bool? smartTranscriptionEnabled,
    Map<PermissionType, PermissionStatus>? permissionStatuses,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      transcriptionEnabled: transcriptionEnabled ?? this.transcriptionEnabled,
      assistantEnabled: assistantEnabled ?? this.assistantEnabled,
      apiKey: apiKey ?? this.apiKey,
      apiKeyStatus: apiKeyStatus ?? this.apiKeyStatus,
      transcriptionHotkey: transcriptionHotkey ?? this.transcriptionHotkey,
      assistantHotkey: assistantHotkey ?? this.assistantHotkey,
      pushToTalkHotkey: pushToTalkHotkey ?? this.pushToTalkHotkey,
      themeMode: themeMode ?? this.themeMode,
      autoCopyEnabled: autoCopyEnabled ?? this.autoCopyEnabled,
      transcriptionModel: transcriptionModel ?? this.transcriptionModel,
      assistantScreenshotEnabled:
          assistantScreenshotEnabled ?? this.assistantScreenshotEnabled,
      smartTranscriptionEnabled:
          smartTranscriptionEnabled ?? this.smartTranscriptionEnabled,
      permissionStatuses: permissionStatuses ?? this.permissionStatuses,
    );
  }

  // Both tools are always enabled now
  // No need for tool selection validation

  bool get canProceedFromApiKey => apiKeyStatus == ApiKeyValidationStatus.valid;

  bool get canProceedFromHotkeys =>
      (transcriptionEnabled && transcriptionHotkey != null) &&
      (assistantEnabled ? assistantHotkey != null : true) &&
      pushToTalkHotkey != null;

  bool get canProceedFromPermissions {
    // Check if all required permissions are granted
    return permissionStatuses.values
        .every((status) => status == PermissionStatus.authorized);
  }

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
        pushToTalkHotkey,
        themeMode,
        autoCopyEnabled,
        transcriptionModel,
        assistantScreenshotEnabled,
        smartTranscriptionEnabled,
        permissionStatuses,
      ];
}
