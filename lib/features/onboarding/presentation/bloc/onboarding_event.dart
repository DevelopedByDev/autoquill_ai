import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../../../../core/permissions/permission_service.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class InitializeOnboarding extends OnboardingEvent {}

// Permission events
class CheckPermissions extends OnboardingEvent {}

class RequestPermission extends OnboardingEvent {
  final PermissionType permissionType;

  const RequestPermission({required this.permissionType});

  @override
  List<Object?> get props => [permissionType];
}

class OpenSystemPreferences extends OnboardingEvent {
  final PermissionType permissionType;

  const OpenSystemPreferences({required this.permissionType});

  @override
  List<Object?> get props => [permissionType];
}

class UpdatePermissionStatus extends OnboardingEvent {
  final PermissionType permissionType;
  final PermissionStatus status;

  const UpdatePermissionStatus({
    required this.permissionType,
    required this.status,
  });

  @override
  List<Object?> get props => [permissionType, status];
}

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

class UpdatePushToTalkHotkey extends OnboardingEvent {
  final HotKey hotkey;

  const UpdatePushToTalkHotkey({required this.hotkey});

  @override
  List<Object?> get props => [hotkey];
}

class RegisterHotkeys extends OnboardingEvent {}

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

class UpdateAssistantScreenshotPreference extends OnboardingEvent {
  final bool enabled;

  const UpdateAssistantScreenshotPreference({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class CompleteOnboarding extends OnboardingEvent {}

class NavigateToNextStep extends OnboardingEvent {}

class NavigateToPreviousStep extends OnboardingEvent {}

// SkipOnboarding event removed as skipping is no longer allowed
