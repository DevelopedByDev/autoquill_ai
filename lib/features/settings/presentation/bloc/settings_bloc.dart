import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/language_codes.dart';

import '../../../../core/settings/settings_service.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/services/whisper_kit_service.dart';
import '../../../../core/storage/app_storage.dart';
import '../../../../widgets/hotkey_handler.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final _box = Hive.box('settings');
  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<SaveApiKey>(_onSaveApiKey);
    on<DeleteApiKey>(_onDeleteApiKey);
    on<ToggleApiKeyVisibility>(_onToggleApiKeyVisibility);

    // Hotkey events
    on<StartHotkeyRecording>(_onStartHotkeyRecording);
    on<UpdateRecordedHotkey>(_onUpdateRecordedHotkey);
    on<SaveHotkey>(_onSaveHotkey);
    on<CancelHotkeyRecording>(_onCancelHotkeyRecording);
    on<DeleteHotkey>(_onDeleteHotkey);
    on<LoadStoredHotkeys>(_onLoadStoredHotkeys);

    // Model selection events
    on<SaveTranscriptionModel>(_onSaveTranscriptionModel);
    on<SaveAssistantModel>(_onSaveAssistantModel);

    // Theme events
    on<ToggleThemeMode>(_onToggleThemeMode);

    // Assistant screenshot toggle event
    on<ToggleAssistantScreenshot>(_onToggleAssistantScreenshot);

    // Dictionary events
    on<LoadDictionary>(_onLoadDictionary);
    on<AddWordToDictionary>(_onAddWordToDictionary);
    on<RemoveWordFromDictionary>(_onRemoveWordFromDictionary);

    // Phrase replacement events
    on<LoadPhraseReplacements>(_onLoadPhraseReplacements);
    on<AddPhraseReplacement>(_onAddPhraseReplacement);
    on<RemovePhraseReplacement>(_onRemovePhraseReplacement);

    // Language selection event
    on<SaveLanguages>(_onSaveLanguages);
    on<AddLanguage>(_onAddLanguage);
    on<RemoveLanguage>(_onRemoveLanguage);

    // Push-to-talk events
    on<TogglePushToTalk>(_onTogglePushToTalk);
    on<StartPushToTalkHotkeyRecording>(_onStartPushToTalkHotkeyRecording);
    on<SavePushToTalkHotkey>(_onSavePushToTalkHotkey);
    on<DeletePushToTalkHotkey>(_onDeletePushToTalkHotkey);

    // Smart transcription events
    on<ToggleSmartTranscription>(_onToggleSmartTranscription);

    // Sound events
    on<ToggleSound>(_onToggleSound);

    // Local transcription events
    on<ToggleLocalTranscription>(_onToggleLocalTranscription);
    on<SelectLocalModel>(_onSelectLocalModel);
    on<DownloadModel>(_onDownloadModel);
    on<UpdateModelDownloadProgress>(_onUpdateModelDownloadProgress);
    on<ModelDownloadCompleted>(_onModelDownloadCompleted);
    on<ModelDownloadFailed>(_onModelDownloadFailed);
    on<LoadDownloadedModels>(_onLoadDownloadedModels);
    on<DeleteLocalModel>(_onDeleteLocalModel);
  }

  Future<void> _onLoadSettings(
      LoadSettings event, Emitter<SettingsState> emit) async {
    try {
      final settingsService = SettingsService();
      final apiKey = await AppStorage.getApiKey();

      // Load stored hotkeys
      add(LoadStoredHotkeys());

      // Load dictionary
      add(LoadDictionary());

      // Load phrase replacements
      add(LoadPhraseReplacements());

      // Load settings from the centralized service
      final transcriptionModel = settingsService.getTranscriptionModel();
      final assistantModel = settingsService.getAssistantModel();
      final themeMode = settingsService.getThemeMode();

      // Load assistant screenshot setting
      final assistantScreenshotEnabled =
          _box.get('assistant_screenshot_enabled', defaultValue: true) as bool;

      // Load push-to-talk setting
      final pushToTalkEnabled =
          _box.get('push_to_talk_enabled', defaultValue: true) as bool;

      // Load selected languages (support both old single language and new multiple languages)
      final List<dynamic>? savedLanguagesList = _box.get('selected_languages');
      List<LanguageCode> selectedLanguages;

      if (savedLanguagesList != null) {
        // New format: multiple languages
        selectedLanguages = savedLanguagesList.map((langData) {
          if (langData is Map) {
            return LanguageCode(
              name: langData['name'] ?? 'Auto-detect',
              code: langData['code'] ?? '',
            );
          }
          return const LanguageCode(name: 'Auto-detect', code: '');
        }).toList();
      } else {
        // Legacy format: single language - migrate to new format
        final savedLanguageCode =
            _box.get('selected_language_code', defaultValue: '') as String;
        final savedLanguageName = _box.get('selected_language_name',
            defaultValue: 'Auto-detect') as String;
        selectedLanguages = [
          LanguageCode(name: savedLanguageName, code: savedLanguageCode)
        ];

        // Save in new format
        await _saveLanguagesToStorage(selectedLanguages);
      }

      // Load smart transcription setting
      final smartTranscriptionEnabled =
          _box.get('smart_transcription_enabled', defaultValue: false) as bool;

      if (kDebugMode) {
        print(
            'Loading smart transcription setting: $smartTranscriptionEnabled');
      }

      // Load sound setting
      final soundEnabled =
          _box.get('sound_enabled', defaultValue: true) as bool;

      // Sync with platform-specific sound setting
      await SoundService.setSoundEnabled(soundEnabled);

      // Initialize WhisperKit service
      await WhisperKitService.initialize();

      // Load local transcription settings
      final localTranscriptionEnabled =
          _box.get('local_transcription_enabled', defaultValue: false) as bool;
      final selectedLocalModel =
          _box.get('selected_local_model', defaultValue: 'base') as String;

      // Load downloaded models
      final savedDownloadedModels =
          _box.get('downloaded_models') as List<dynamic>?;
      final downloadedModels =
          savedDownloadedModels?.cast<String>() ?? <String>[];

      emit(state.copyWith(
        apiKey: apiKey,
        transcriptionModel: transcriptionModel,
        assistantModel: assistantModel,
        themeMode: themeMode,
        assistantScreenshotEnabled: assistantScreenshotEnabled,
        pushToTalkEnabled: pushToTalkEnabled,
        selectedLanguages: selectedLanguages,
        smartTranscriptionEnabled: smartTranscriptionEnabled,
        soundEnabled: soundEnabled,
        localTranscriptionEnabled: localTranscriptionEnabled,
        selectedLocalModel: selectedLocalModel,
        downloadedModels: downloadedModels,
      ));

      // Load current downloaded models from WhisperKit
      add(LoadDownloadedModels());

      // If local transcription is enabled, preload the selected model
      if (localTranscriptionEnabled) {
        try {
          // Check if the selected model is downloaded
          final isDownloaded =
              await WhisperKitService.isModelDownloaded(selectedLocalModel);
          if (isDownloaded) {
            if (kDebugMode) {
              print('Preloading model on app startup: $selectedLocalModel');
            }
            await WhisperKitService.preloadModel(selectedLocalModel);
            if (kDebugMode) {
              print('Model preloaded on startup: $selectedLocalModel');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error preloading model on startup: $e');
          }
          // Don't fail app loading if preloading fails
        }
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onSaveApiKey(
      SaveApiKey event, Emitter<SettingsState> emit) async {
    try {
      await AppStorage.saveApiKey(event.apiKey);
      emit(state.copyWith(
        apiKey: event.apiKey,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDeleteApiKey(
      DeleteApiKey event, Emitter<SettingsState> emit) async {
    try {
      await AppStorage.deleteApiKey();
      emit(state.copyWith(
        apiKey: null,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onToggleApiKeyVisibility(
      ToggleApiKeyVisibility event, Emitter<SettingsState> emit) {
    emit(state.copyWith(isApiKeyVisible: !state.isApiKeyVisible));
  }

  Future<void> _onSaveLanguages(
      SaveLanguages event, Emitter<SettingsState> emit) async {
    try {
      await _saveLanguagesToStorage(event.languages);
      emit(state.copyWith(selectedLanguages: event.languages));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onAddLanguage(
      AddLanguage event, Emitter<SettingsState> emit) async {
    try {
      final currentLanguages = List<LanguageCode>.from(state.selectedLanguages);

      // Don't add if already selected
      if (currentLanguages.any((lang) => lang.code == event.language.code)) {
        return;
      }

      // If adding a specific language and auto-detect is selected, remove auto-detect
      if (event.language.code.isNotEmpty &&
          currentLanguages.any((lang) => lang.code.isEmpty)) {
        currentLanguages.removeWhere((lang) => lang.code.isEmpty);
      }

      // If adding auto-detect, clear all other languages
      if (event.language.code.isEmpty) {
        currentLanguages.clear();
      }

      currentLanguages.add(event.language);

      await _saveLanguagesToStorage(currentLanguages);
      emit(state.copyWith(selectedLanguages: currentLanguages));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onRemoveLanguage(
      RemoveLanguage event, Emitter<SettingsState> emit) async {
    try {
      final currentLanguages = List<LanguageCode>.from(state.selectedLanguages);
      currentLanguages.removeWhere((lang) => lang.code == event.language.code);

      // If no languages left, add auto-detect
      if (currentLanguages.isEmpty) {
        currentLanguages.add(const LanguageCode(name: 'Auto-detect', code: ''));
      }

      await _saveLanguagesToStorage(currentLanguages);
      emit(state.copyWith(selectedLanguages: currentLanguages));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _saveLanguagesToStorage(List<LanguageCode> languages) async {
    final languagesList = languages
        .map((lang) => {
              'name': lang.name,
              'code': lang.code,
            })
        .toList();
    await _box.put('selected_languages', languagesList);
  }

  // Hotkey management methods
  void _onStartHotkeyRecording(
      StartHotkeyRecording event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
      isRecordingHotkey: true,
      recordingFor: event.mode,
      currentRecordedHotkey: null,
    ));
  }

  void _onUpdateRecordedHotkey(
      UpdateRecordedHotkey event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
      currentRecordedHotkey: event.hotkey,
    ));
  }

  Future<void> _onSaveHotkey(
      SaveHotkey event, Emitter<SettingsState> emit) async {
    try {
      if (state.recordingFor == null) return;

      // Register the hotkey with the system
      await HotkeyHandler.registerHotKey(event.hotkey, state.recordingFor!);

      // Update the stored hotkeys in state
      final updatedHotkeys = Map<String, dynamic>.from(state.storedHotkeys);

      // Convert hotkey to storable format
      final keyData = {
        'identifier': event.hotkey.identifier,
        'key': {
          'keyId': event.hotkey.key is LogicalKeyboardKey
              ? (event.hotkey.key as LogicalKeyboardKey).keyId
              : null,
          'usageCode': event.hotkey.key is PhysicalKeyboardKey
              ? (event.hotkey.key as PhysicalKeyboardKey).usbHidUsage
              : null,
        },
        'modifiers':
            event.hotkey.modifiers?.map((m) => m.name).toList() ?? <String>[],
        'scope': event.hotkey.scope.name,
      };

      updatedHotkeys[state.recordingFor!] = keyData;

      // Reload all hotkeys to ensure the new hotkey is active immediately
      await HotkeyHandler.reloadHotkeys();

      emit(state.copyWith(
        isRecordingHotkey: false,
        recordingFor: null,
        currentRecordedHotkey: null,
        storedHotkeys: updatedHotkeys,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onCancelHotkeyRecording(
      CancelHotkeyRecording event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
      isRecordingHotkey: false,
      recordingFor: null,
      currentRecordedHotkey: null,
    ));
  }

  Future<void> _onDeleteHotkey(
      DeleteHotkey event, Emitter<SettingsState> emit) async {
    try {
      // Unregister the hotkey from the system
      await HotkeyHandler.unregisterHotKey(event.mode);

      // Update the stored hotkeys in state
      final updatedHotkeys = Map<String, dynamic>.from(state.storedHotkeys);
      updatedHotkeys.remove(event.mode);

      // Reload all hotkeys to ensure changes take effect immediately
      await HotkeyHandler.reloadHotkeys();

      emit(state.copyWith(
        storedHotkeys: updatedHotkeys,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onLoadStoredHotkeys(
      LoadStoredHotkeys event, Emitter<SettingsState> emit) async {
    try {
      final settingsBox = Hive.box('settings');
      final Map<String, dynamic> hotkeys = {};

      // Load transcription hotkey
      final transcriptionHotkey = settingsBox.get('transcription_hotkey');
      if (transcriptionHotkey != null) {
        hotkeys['transcription_hotkey'] = transcriptionHotkey;
      }

      // Load assistant hotkey
      final assistantHotkey = settingsBox.get('assistant_hotkey');
      if (assistantHotkey != null) {
        hotkeys['assistant_hotkey'] = assistantHotkey;
      }

      // Load push-to-talk hotkey
      final pushToTalkHotkey = settingsBox.get('push_to_talk_hotkey');
      if (pushToTalkHotkey != null) {
        hotkeys['push_to_talk_hotkey'] = pushToTalkHotkey;
      }

      emit(state.copyWith(storedHotkeys: hotkeys));

      // Register all hotkeys with the system
      await HotkeyHandler.loadAndRegisterStoredHotkeys();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Model selection handlers
  Future<void> _onSaveTranscriptionModel(
      SaveTranscriptionModel event, Emitter<SettingsState> emit) async {
    try {
      final settingsBox = Hive.box('settings');
      await settingsBox.put('transcription-model', event.model);
      emit(state.copyWith(transcriptionModel: event.model));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onSaveAssistantModel(
      SaveAssistantModel event, Emitter<SettingsState> emit) async {
    try {
      final settingsBox = Hive.box('settings');
      await settingsBox.put('assistant-model', event.model);
      emit(state.copyWith(assistantModel: event.model));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Dictionary management methods
  Future<void> _onLoadDictionary(
      LoadDictionary event, Emitter<SettingsState> emit) async {
    try {
      final settingsBox = Hive.box('settings');
      final List<dynamic>? storedDictionary = settingsBox.get('dictionary');

      if (storedDictionary != null) {
        final List<String> dictionary =
            storedDictionary.cast<String>().toList();
        emit(state.copyWith(dictionary: dictionary));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onAddWordToDictionary(
      AddWordToDictionary event, Emitter<SettingsState> emit) async {
    try {
      final word = event.word.trim();

      // Don't add empty words or duplicates
      if (word.isEmpty || state.dictionary.contains(word)) {
        return;
      }

      final List<String> updatedDictionary = List.from(state.dictionary)
        ..add(word);

      // Save to Hive
      final settingsBox = Hive.box('settings');
      await settingsBox.put('dictionary', updatedDictionary);

      // Update state
      emit(state.copyWith(dictionary: updatedDictionary));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onRemoveWordFromDictionary(
      RemoveWordFromDictionary event, Emitter<SettingsState> emit) async {
    try {
      final word = event.word;

      // Create a new list without the word to remove
      final List<String> updatedDictionary = List.from(state.dictionary)
        ..remove(word);

      // Save to Hive
      final settingsBox = Hive.box('settings');
      await settingsBox.put('dictionary', updatedDictionary);

      // Update state
      emit(state.copyWith(dictionary: updatedDictionary));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Phrase replacement management methods
  Future<void> _onLoadPhraseReplacements(
      LoadPhraseReplacements event, Emitter<SettingsState> emit) async {
    try {
      final settingsBox = Hive.box('settings');
      final Map<dynamic, dynamic>? storedReplacements =
          settingsBox.get('phrase_replacements');

      if (storedReplacements != null) {
        final Map<String, String> phraseReplacements =
            Map<String, String>.from(storedReplacements);
        emit(state.copyWith(phraseReplacements: phraseReplacements));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onAddPhraseReplacement(
      AddPhraseReplacement event, Emitter<SettingsState> emit) async {
    try {
      final fromPhrase = event.fromPhrase.trim();
      final toPhrase = event.toPhrase.trim();

      // Don't add empty phrases
      if (fromPhrase.isEmpty || toPhrase.isEmpty) {
        return;
      }

      final Map<String, String> updatedReplacements =
          Map.from(state.phraseReplacements);
      updatedReplacements[fromPhrase] = toPhrase;

      // Save to Hive
      final settingsBox = Hive.box('settings');
      await settingsBox.put('phrase_replacements', updatedReplacements);

      // Update state
      emit(state.copyWith(phraseReplacements: updatedReplacements));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onRemovePhraseReplacement(
      RemovePhraseReplacement event, Emitter<SettingsState> emit) async {
    try {
      final fromPhrase = event.fromPhrase;

      final Map<String, String> updatedReplacements =
          Map.from(state.phraseReplacements);
      updatedReplacements.remove(fromPhrase);

      // Save to Hive
      final settingsBox = Hive.box('settings');
      await settingsBox.put('phrase_replacements', updatedReplacements);

      // Update state
      emit(state.copyWith(phraseReplacements: updatedReplacements));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Theme toggle handler
  Future<void> _onToggleThemeMode(
      ToggleThemeMode event, Emitter<SettingsState> emit) async {
    try {
      final settingsService = SettingsService();
      final newThemeMode =
          state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

      // Save theme preference using the centralized service
      await settingsService.setThemeMode(newThemeMode);

      emit(state.copyWith(
        themeMode: newThemeMode,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Toggle assistant screenshot handler
  Future<void> _onToggleAssistantScreenshot(
      ToggleAssistantScreenshot event, Emitter<SettingsState> emit) async {
    try {
      final newValue = !state.assistantScreenshotEnabled;

      // Save the setting to Hive
      final settingsBox = Hive.box('settings');
      await settingsBox.put('assistant_screenshot_enabled', newValue);

      emit(state.copyWith(
        assistantScreenshotEnabled: newValue,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Push-to-talk handlers
  Future<void> _onTogglePushToTalk(
      TogglePushToTalk event, Emitter<SettingsState> emit) async {
    try {
      final newValue = !state.pushToTalkEnabled;

      // Save the setting to Hive
      final settingsBox = Hive.box('settings');
      await settingsBox.put('push_to_talk_enabled', newValue);

      emit(state.copyWith(
        pushToTalkEnabled: newValue,
        error: null,
      ));

      // Reload all hotkeys to ensure changes take effect immediately
      await HotkeyHandler.reloadHotkeys();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onStartPushToTalkHotkeyRecording(
      StartPushToTalkHotkeyRecording event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
      isRecordingHotkey: true,
      recordingFor: 'push_to_talk_hotkey',
      currentRecordedHotkey: null,
    ));
  }

  Future<void> _onSavePushToTalkHotkey(
      SavePushToTalkHotkey event, Emitter<SettingsState> emit) async {
    try {
      // Register the hotkey with the system
      await HotkeyHandler.registerHotKey(event.hotkey, 'push_to_talk_hotkey');

      // Update the stored hotkeys in state
      final updatedHotkeys = Map<String, dynamic>.from(state.storedHotkeys);

      // Convert hotkey to storable format
      final keyData = {
        'identifier': event.hotkey.identifier,
        'key': {
          'keyId': event.hotkey.key is LogicalKeyboardKey
              ? (event.hotkey.key as LogicalKeyboardKey).keyId
              : null,
          'usageCode': event.hotkey.key is PhysicalKeyboardKey
              ? (event.hotkey.key as PhysicalKeyboardKey).usbHidUsage
              : null,
        },
        'modifiers':
            event.hotkey.modifiers?.map((m) => m.name).toList() ?? <String>[],
        'scope': event.hotkey.scope.name,
      };

      updatedHotkeys['push_to_talk_hotkey'] = keyData;

      // Reload all hotkeys to ensure the new hotkey is active immediately
      await HotkeyHandler.reloadHotkeys();

      emit(state.copyWith(
        isRecordingHotkey: false,
        recordingFor: null,
        currentRecordedHotkey: null,
        storedHotkeys: updatedHotkeys,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDeletePushToTalkHotkey(
      DeletePushToTalkHotkey event, Emitter<SettingsState> emit) async {
    try {
      // Unregister the hotkey from the system
      await HotkeyHandler.unregisterHotKey('push_to_talk_hotkey');

      // Update the stored hotkeys in state
      final updatedHotkeys = Map<String, dynamic>.from(state.storedHotkeys);
      updatedHotkeys.remove('push_to_talk_hotkey');

      // Reload all hotkeys to ensure changes take effect immediately
      await HotkeyHandler.reloadHotkeys();

      emit(state.copyWith(
        storedHotkeys: updatedHotkeys,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Smart transcription handler
  Future<void> _onToggleSmartTranscription(
      ToggleSmartTranscription event, Emitter<SettingsState> emit) async {
    try {
      final newValue = !state.smartTranscriptionEnabled;

      if (kDebugMode) {
        print(
            'Toggling smart transcription from ${state.smartTranscriptionEnabled} to $newValue');
      }

      // Save the setting to Hive
      final settingsBox = Hive.box('settings');
      await settingsBox.put('smart_transcription_enabled', newValue);

      if (kDebugMode) {
        print('Saved smart transcription setting to Hive: $newValue');
      }

      emit(state.copyWith(
        smartTranscriptionEnabled: newValue,
        error: null,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling smart transcription: $e');
      }
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Sound toggle handler
  Future<void> _onToggleSound(
      ToggleSound event, Emitter<SettingsState> emit) async {
    try {
      final newValue = !state.soundEnabled;

      if (kDebugMode) {
        print('Toggling sound from ${state.soundEnabled} to $newValue');
      }

      // Save the setting to Hive
      final settingsBox = Hive.box('settings');
      await settingsBox.put('sound_enabled', newValue);

      if (kDebugMode) {
        print('Saved sound setting to Hive: $newValue');
      }

      emit(state.copyWith(
        soundEnabled: newValue,
        error: null,
      ));

      // Update the platform-specific sound setting
      await SoundService.setSoundEnabled(newValue);
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling sound: $e');
      }
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Local transcription toggle handler
  Future<void> _onToggleLocalTranscription(
      ToggleLocalTranscription event, Emitter<SettingsState> emit) async {
    try {
      final newValue = !state.localTranscriptionEnabled;

      if (kDebugMode) {
        print(
            'Toggling local transcription from ${state.localTranscriptionEnabled} to $newValue');
      }

      // Save the setting to Hive
      final settingsBox = Hive.box('settings');
      await settingsBox.put('local_transcription_enabled', newValue);

      if (kDebugMode) {
        print('Saved local transcription setting to Hive: $newValue');
      }

      // If enabling local transcription, preload the selected model
      if (newValue) {
        try {
          // Check if the selected model is downloaded
          final isDownloaded = await WhisperKitService.isModelDownloaded(
              state.selectedLocalModel);
          if (isDownloaded) {
            if (kDebugMode) {
              print('Preloading model: ${state.selectedLocalModel}');
            }
            await WhisperKitService.preloadModel(state.selectedLocalModel);
            if (kDebugMode) {
              print(
                  'Model preloaded successfully: ${state.selectedLocalModel}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error preloading model: $e');
          }
          // Don't fail the toggle if preloading fails
        }
      }

      emit(state.copyWith(
        localTranscriptionEnabled: newValue,
        error: null,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling local transcription: $e');
      }
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Local model selection handler
  Future<void> _onSelectLocalModel(
      SelectLocalModel event, Emitter<SettingsState> emit) async {
    try {
      if (kDebugMode) {
        print('Selecting local model: ${event.model}');
      }

      // Save the setting to Hive
      final settingsBox = Hive.box('settings');
      await settingsBox.put('selected_local_model', event.model);

      if (kDebugMode) {
        print('Saved selected local model to Hive: ${event.model}');
      }

      emit(state.copyWith(
        selectedLocalModel: event.model,
        error: null,
      ));

      // If local transcription is enabled, preload the new model
      if (state.localTranscriptionEnabled) {
        try {
          // Check if the selected model is downloaded
          final isDownloaded =
              await WhisperKitService.isModelDownloaded(event.model);
          if (isDownloaded) {
            if (kDebugMode) {
              print('Preloading new selected model: ${event.model}');
            }
            await WhisperKitService.preloadModel(event.model);
            if (kDebugMode) {
              print('New model preloaded successfully: ${event.model}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error preloading new model: $e');
          }
          // Don't fail the selection if preloading fails
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error selecting local model: $e');
      }
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Model download handler
  Future<void> _onDownloadModel(
      DownloadModel event, Emitter<SettingsState> emit) async {
    try {
      if (kDebugMode) {
        print('Starting download for model: ${event.modelName}');
      }

      // Clear any previous errors for this model
      final updatedErrors = Map<String, String>.from(state.modelDownloadErrors);
      updatedErrors.remove(event.modelName);

      emit(state.copyWith(
        modelDownloadErrors: updatedErrors,
        error: null,
      ));

      // Start the download and listen to progress
      await for (final progress
          in WhisperKitService.downloadModel(event.modelName)) {
        add(UpdateModelDownloadProgress(event.modelName, progress));

        if (progress >= 1.0) {
          add(ModelDownloadCompleted(event.modelName));
          break;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading model ${event.modelName}: $e');
      }
      add(ModelDownloadFailed(event.modelName, e.toString()));
    }
  }

  // Model download progress update handler
  void _onUpdateModelDownloadProgress(
      UpdateModelDownloadProgress event, Emitter<SettingsState> emit) {
    final updatedProgress =
        Map<String, double>.from(state.modelDownloadProgress);
    updatedProgress[event.modelName] = event.progress;

    if (kDebugMode) {
      print(
          'Download progress for ${event.modelName}: ${(event.progress * 100).toStringAsFixed(1)}%');
    }

    emit(state.copyWith(
      modelDownloadProgress: updatedProgress,
      error: null,
    ));
  }

  // Model download completed handler
  Future<void> _onModelDownloadCompleted(
      ModelDownloadCompleted event, Emitter<SettingsState> emit) async {
    try {
      if (kDebugMode) {
        print('Model download completed: ${event.modelName}');
      }

      // Remove from progress tracking
      final updatedProgress =
          Map<String, double>.from(state.modelDownloadProgress);
      updatedProgress.remove(event.modelName);

      // Add to downloaded models
      final updatedDownloaded = List<String>.from(state.downloadedModels);
      if (!updatedDownloaded.contains(event.modelName)) {
        updatedDownloaded.add(event.modelName);
      }

      // Save to Hive
      final settingsBox = Hive.box('settings');
      await settingsBox.put('downloaded_models', updatedDownloaded);

      emit(state.copyWith(
        modelDownloadProgress: updatedProgress,
        downloadedModels: updatedDownloaded,
        error: null,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error handling model download completion: $e');
      }
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Model download failed handler
  void _onModelDownloadFailed(
      ModelDownloadFailed event, Emitter<SettingsState> emit) {
    if (kDebugMode) {
      print('Model download failed: ${event.modelName} - ${event.error}');
    }

    // Remove from progress tracking
    final updatedProgress =
        Map<String, double>.from(state.modelDownloadProgress);
    updatedProgress.remove(event.modelName);

    // Add error
    final updatedErrors = Map<String, String>.from(state.modelDownloadErrors);
    updatedErrors[event.modelName] = event.error;

    emit(state.copyWith(
      modelDownloadProgress: updatedProgress,
      modelDownloadErrors: updatedErrors,
      error: 'Failed to download ${event.modelName}: ${event.error}',
    ));
  }

  // Load downloaded models handler
  Future<void> _onLoadDownloadedModels(
      LoadDownloadedModels event, Emitter<SettingsState> emit) async {
    try {
      if (kDebugMode) {
        print('Loading downloaded models');
      }

      // Get models from WhisperKit service
      final downloadedModels = await WhisperKitService.getDownloadedModels();

      // Load from Hive as fallback
      final settingsBox = Hive.box('settings');
      final savedModels =
          settingsBox.get('downloaded_models') as List<dynamic>?;
      final fallbackModels = savedModels?.cast<String>() ?? <String>[];

      // Combine and deduplicate
      final allModels =
          <String>{...downloadedModels, ...fallbackModels}.toList();

      // Save updated list to Hive
      await settingsBox.put('downloaded_models', allModels);

      emit(state.copyWith(
        downloadedModels: allModels,
        error: null,
      ));

      if (kDebugMode) {
        print('Loaded downloaded models: $allModels');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading downloaded models: $e');
      }
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Delete local model handler
  Future<void> _onDeleteLocalModel(
      DeleteLocalModel event, Emitter<SettingsState> emit) async {
    try {
      if (kDebugMode) {
        print('Deleting model: ${event.modelName}');
      }

      // Delete via WhisperKit service
      final success = await WhisperKitService.deleteModel(event.modelName);

      if (success) {
        // Remove from downloaded models list
        final updatedDownloaded = List<String>.from(state.downloadedModels);
        updatedDownloaded.remove(event.modelName);

        // Save to Hive
        final settingsBox = Hive.box('settings');
        await settingsBox.put('downloaded_models', updatedDownloaded);

        // If this was the selected model, reset to default
        String newSelectedModel = state.selectedLocalModel;
        if (state.selectedLocalModel == event.modelName) {
          newSelectedModel = 'base';
          await settingsBox.put('selected_local_model', newSelectedModel);
        }

        emit(state.copyWith(
          downloadedModels: updatedDownloaded,
          selectedLocalModel: newSelectedModel,
          error: null,
        ));

        if (kDebugMode) {
          print('Successfully deleted model: ${event.modelName}');
        }
      } else {
        throw Exception('Failed to delete model');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting model ${event.modelName}: $e');
      }
      emit(state.copyWith(error: 'Failed to delete ${event.modelName}: $e'));
    }
  }
}
