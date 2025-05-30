import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/language_codes.dart';

import '../../../../core/settings/settings_service.dart';
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

      emit(state.copyWith(
        apiKey: apiKey,
        transcriptionModel: transcriptionModel,
        assistantModel: assistantModel,
        themeMode: themeMode,
        assistantScreenshotEnabled: assistantScreenshotEnabled,
        pushToTalkEnabled: pushToTalkEnabled,
        selectedLanguages: selectedLanguages,
        smartTranscriptionEnabled: smartTranscriptionEnabled,
      ));
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
}
