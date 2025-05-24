import 'package:autoquill_ai/core/settings/settings_service.dart';
import 'package:autoquill_ai/core/storage/app_storage.dart';
import 'package:autoquill_ai/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:autoquill_ai/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:autoquill_ai/core/permissions/permission_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:http/http.dart' as http;

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    on<InitializeOnboarding>(_onInitializeOnboarding);

    // Permission events
    on<CheckPermissions>(_onCheckPermissions);
    on<RequestPermission>(_onRequestPermission);
    on<OpenSystemPreferences>(_onOpenSystemPreferences);
    on<UpdatePermissionStatus>(_onUpdatePermissionStatus);

    // UpdateSelectedTools event removed as both tools are always enabled
    on<UpdateApiKey>(_onUpdateApiKey);
    on<ValidateApiKey>(_onValidateApiKey);
    on<UpdateTranscriptionHotkey>(_onUpdateTranscriptionHotkey);
    on<UpdateAssistantHotkey>(_onUpdateAssistantHotkey);
    on<UpdateThemePreference>(_onUpdateThemePreference);
    on<UpdateAutoCopyPreference>(_onUpdateAutoCopyPreference);
    on<UpdateTranscriptionModel>(_onUpdateTranscriptionModel);
    on<UpdateAssistantScreenshotPreference>(
        _onUpdateAssistantScreenshotPreference);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    on<NavigateToNextStep>(_onNavigateToNextStep);
    on<NavigateToPreviousStep>(_onNavigateToPreviousStep);
    // SkipOnboarding event removed as skipping is no longer allowed
  }

  void _onInitializeOnboarding(
    InitializeOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    // Set default hotkeys
    final defaultTranscriptionHotkey = HotKey(
      key: LogicalKeyboardKey.keyZ,
      modifiers: [HotKeyModifier.alt, HotKeyModifier.shift],
      scope: HotKeyScope.system,
    );

    final defaultAssistantHotkey = HotKey(
      key: LogicalKeyboardKey.keyS,
      modifiers: [HotKeyModifier.alt, HotKeyModifier.shift],
      scope: HotKeyScope.system,
    );

    emit(state.copyWith(
      transcriptionHotkey: defaultTranscriptionHotkey,
      assistantHotkey: defaultAssistantHotkey,
    ));

    // Check permissions on app startup
    try {
      final permissions = await PermissionService.checkAllPermissions();
      emit(state.copyWith(permissionStatuses: permissions));
      if (kDebugMode) {
        print('Startup permission check completed: $permissions');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking permissions on startup: $e');
      }
    }
  }

  Future<void> _onCheckPermissions(
    CheckPermissions event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      final permissions = await PermissionService.checkAllPermissions();
      emit(state.copyWith(permissionStatuses: permissions));
    } catch (e) {
      if (kDebugMode) {
        print('Error checking permissions: $e');
      }
    }
  }

  Future<void> _onRequestPermission(
    RequestPermission event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      final status =
          await PermissionService.requestPermission(event.permissionType);

      // Update the permission status in the state
      final updatedPermissions =
          Map<PermissionType, PermissionStatus>.from(state.permissionStatuses);
      updatedPermissions[event.permissionType] = status;

      emit(state.copyWith(permissionStatuses: updatedPermissions));
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting permission ${event.permissionType}: $e');
      }
    }
  }

  Future<void> _onOpenSystemPreferences(
    OpenSystemPreferences event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      await PermissionService.openSystemPreferences(event.permissionType);
    } catch (e) {
      if (kDebugMode) {
        print(
            'Error opening system preferences for ${event.permissionType}: $e');
      }
    }
  }

  void _onUpdatePermissionStatus(
    UpdatePermissionStatus event,
    Emitter<OnboardingState> emit,
  ) {
    final updatedPermissions =
        Map<PermissionType, PermissionStatus>.from(state.permissionStatuses);
    updatedPermissions[event.permissionType] = event.status;

    emit(state.copyWith(permissionStatuses: updatedPermissions));
  }

  // _onUpdateSelectedTools removed as both tools are always enabled

  void _onUpdateApiKey(
    UpdateApiKey event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      apiKey: event.apiKey,
      apiKeyStatus: ApiKeyValidationStatus.initial,
    ));
  }

  Future<void> _onValidateApiKey(
    ValidateApiKey event,
    Emitter<OnboardingState> emit,
  ) async {
    if (event.apiKey.isEmpty) {
      emit(state.copyWith(apiKeyStatus: ApiKeyValidationStatus.invalid));
      return;
    }

    emit(state.copyWith(apiKeyStatus: ApiKeyValidationStatus.validating));

    try {
      // Validate Groq API key by making a test request
      // Using a simpler endpoint with minimal data transfer
      final response = await http.get(
        Uri.parse('https://api.groq.com/openai/v1/models'),
        headers: {
          'Authorization': 'Bearer ${event.apiKey}',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Groq API validation response: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        emit(state.copyWith(
          apiKey: event.apiKey,
          apiKeyStatus: ApiKeyValidationStatus.valid,
        ));
      } else {
        // For debugging purposes, log the error details
        if (kDebugMode) {
          print('Invalid API key. Status code: ${response.statusCode}');
        }
        emit(state.copyWith(apiKeyStatus: ApiKeyValidationStatus.invalid));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error validating API key: $e');
      }
      // Handle network errors gracefully
      emit(state.copyWith(apiKeyStatus: ApiKeyValidationStatus.invalid));
    }
  }

  void _onUpdateTranscriptionHotkey(
    UpdateTranscriptionHotkey event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(transcriptionHotkey: event.hotkey));
  }

  void _onUpdateAssistantHotkey(
    UpdateAssistantHotkey event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(assistantHotkey: event.hotkey));
  }

  void _onUpdateThemePreference(
    UpdateThemePreference event,
    Emitter<OnboardingState> emit,
  ) async {
    // Use the settings service to update theme
    final settingsService = SettingsService();
    await settingsService.setThemeMode(event.themeMode);

    emit(state.copyWith(themeMode: event.themeMode));
  }

  void _onUpdateAutoCopyPreference(
    UpdateAutoCopyPreference event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(autoCopyEnabled: event.autoCopyEnabled));
  }

  void _onUpdateTranscriptionModel(
    UpdateTranscriptionModel event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(transcriptionModel: event.modelName));
  }

  void _onUpdateAssistantScreenshotPreference(
    UpdateAssistantScreenshotPreference event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(assistantScreenshotEnabled: event.enabled));
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      // Save all settings to persistent storage
      await _saveOnboardingSettings();

      // Mark onboarding as completed
      await AppStorage.setOnboardingCompleted(true);

      // Add a delay to ensure all settings are properly saved before navigation
      await Future.delayed(const Duration(milliseconds: 500));

      emit(state.copyWith(currentStep: OnboardingStep.completed));
    } catch (e) {
      if (kDebugMode) {
        print('Error completing onboarding: $e');
      }
      // Still try to complete onboarding even if there was an error
      emit(state.copyWith(currentStep: OnboardingStep.completed));
    }
  }

  void _onNavigateToNextStep(
    NavigateToNextStep event,
    Emitter<OnboardingState> emit,
  ) {
    final currentStep = state.currentStep;
    OnboardingStep nextStep;

    switch (currentStep) {
      case OnboardingStep.welcome:
        nextStep = OnboardingStep.permissions;
        break;
      case OnboardingStep.permissions:
        nextStep = OnboardingStep.apiKey;
        break;
      case OnboardingStep.apiKey:
        nextStep = OnboardingStep.hotkeys;
        break;
      case OnboardingStep.hotkeys:
        nextStep = OnboardingStep.preferences;
        break;
      case OnboardingStep.preferences:
        nextStep = OnboardingStep.completed;
        // Save settings when reaching the completed step
        _saveOnboardingSettings();
        AppStorage.setOnboardingCompleted(true);
        break;
      case OnboardingStep.completed:
        // Already at the last step
        return;
    }

    emit(state.copyWith(currentStep: nextStep));
  }

  void _onNavigateToPreviousStep(
    NavigateToPreviousStep event,
    Emitter<OnboardingState> emit,
  ) {
    final currentStep = state.currentStep;
    OnboardingStep previousStep;

    switch (currentStep) {
      case OnboardingStep.welcome:
        // Already at the first step
        return;
      case OnboardingStep.permissions:
        previousStep = OnboardingStep.welcome;
        break;
      case OnboardingStep.apiKey:
        previousStep = OnboardingStep.permissions;
        break;
      case OnboardingStep.hotkeys:
        previousStep = OnboardingStep.apiKey;
        break;
      case OnboardingStep.preferences:
        previousStep = OnboardingStep.hotkeys;
        break;
      case OnboardingStep.completed:
        previousStep = OnboardingStep.preferences;
        break;
    }

    emit(state.copyWith(currentStep: previousStep));
  }

  // _onSkipOnboarding method removed as skipping is no longer allowed

  Future<void> _saveOnboardingSettings() async {
    // Use the settings service for all settings
    final settingsService = SettingsService();

    // Save API key
    if (state.apiKey.isNotEmpty &&
        state.apiKeyStatus == ApiKeyValidationStatus.valid) {
      await AppStorage.saveApiKey(state.apiKey);
      // Also save to settings service
      await settingsService.setApiKey(state.apiKey);
    }

    // Save hotkeys - use direct Hive access to ensure they're saved correctly
    // Both transcription and assistant are always enabled now
    if (state.transcriptionHotkey != null) {
      // Save using both methods to ensure compatibility
      await settingsService.setTranscriptionHotkey(state.transcriptionHotkey!);

      // Save to Hive as a Map
      final hotkeyMap = state.transcriptionHotkey!.toJson();
      await AppStorage.settingsBox.put('transcription_hotkey', hotkeyMap);

      if (kDebugMode) {
        print('Saved transcription hotkey: $hotkeyMap');
      }
    }

    if (state.assistantHotkey != null) {
      // Save using both methods to ensure compatibility
      await settingsService.setAssistantHotkey(state.assistantHotkey!);

      // Save to Hive as a Map
      final hotkeyMap = state.assistantHotkey!.toJson();
      await AppStorage.settingsBox.put('assistant_hotkey', hotkeyMap);

      if (kDebugMode) {
        print('Saved assistant hotkey: $hotkeyMap');
      }
    }

    // Save theme preference
    await settingsService.setThemeMode(state.themeMode);
    await AppStorage.settingsBox.put(
        'theme_mode', state.themeMode == ThemeMode.light ? 'light' : 'dark');

    // Save auto-copy preference
    await settingsService.setAutoCopy(state.autoCopyEnabled);
    await AppStorage.settingsBox.put('auto_copy', state.autoCopyEnabled);

    // Save transcription model
    await settingsService.setTranscriptionModel(state.transcriptionModel);
    await AppStorage.settingsBox
        .put('transcription-model', state.transcriptionModel);

    // Save assistant screenshot preference
    await AppStorage.settingsBox
        .put('assistant_screenshot_enabled', state.assistantScreenshotEnabled);

    // Add a longer delay to ensure all settings are written before navigation
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
