import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/storage/app_storage.dart';
import '../../../../widgets/hotkey_handler.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
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
    on<SaveAgentModel>(_onSaveAgentModel);
    
    // Dictionary events
    on<LoadDictionary>(_onLoadDictionary);
    on<AddWordToDictionary>(_onAddWordToDictionary);
    on<RemoveWordFromDictionary>(_onRemoveWordFromDictionary);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    try {
      final apiKey = await AppStorage.getApiKey();
      
      // Load stored hotkeys
      add(LoadStoredHotkeys());
      
      // Load dictionary
      add(LoadDictionary());
      
      // Load model selections from Hive
      final settingsBox = Hive.box('settings');
      final transcriptionModel = settingsBox.get('transcription-model') ?? 'whisper-large-v3';
      final assistantModel = settingsBox.get('assistant-model') ?? 'llama3-70b-8192';
      final agentModel = settingsBox.get('agent-model') ?? 'compound-beta-mini';
      
      emit(state.copyWith(
        apiKey: apiKey,
        transcriptionModel: transcriptionModel,
        assistantModel: assistantModel,
        agentModel: agentModel,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onSaveApiKey(SaveApiKey event, Emitter<SettingsState> emit) async {
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

  Future<void> _onDeleteApiKey(DeleteApiKey event, Emitter<SettingsState> emit) async {
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

  void _onToggleApiKeyVisibility(ToggleApiKeyVisibility event, Emitter<SettingsState> emit) {
    emit(state.copyWith(isApiKeyVisible: !state.isApiKeyVisible));
  }
  
  // Hotkey management methods
  void _onStartHotkeyRecording(StartHotkeyRecording event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
      isRecordingHotkey: true,
      recordingFor: event.mode,
      currentRecordedHotkey: null,
    ));
  }
  
  void _onUpdateRecordedHotkey(UpdateRecordedHotkey event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
      currentRecordedHotkey: event.hotkey,
    ));
  }
  
  Future<void> _onSaveHotkey(SaveHotkey event, Emitter<SettingsState> emit) async {
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
        'modifiers': event.hotkey.modifiers?.map((m) => m.name).toList() ?? <String>[],
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
  
  void _onCancelHotkeyRecording(CancelHotkeyRecording event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
      isRecordingHotkey: false,
      recordingFor: null,
      currentRecordedHotkey: null,
    ));
  }
  
  Future<void> _onDeleteHotkey(DeleteHotkey event, Emitter<SettingsState> emit) async {
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
  
  Future<void> _onLoadStoredHotkeys(LoadStoredHotkeys event, Emitter<SettingsState> emit) async {
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
      
      // Load agent hotkey
      final agentHotkey = settingsBox.get('agent_hotkey');
      if (agentHotkey != null) {
        hotkeys['agent_hotkey'] = agentHotkey;
      }
      
      // Load text hotkey
      final textHotkey = settingsBox.get('text_hotkey');
      if (textHotkey != null) {
        hotkeys['text_hotkey'] = textHotkey;
      }
      
      emit(state.copyWith(storedHotkeys: hotkeys));
      
      // Register all hotkeys with the system
      await HotkeyHandler.loadAndRegisterStoredHotkeys();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
  
  // Model selection handlers
  Future<void> _onSaveTranscriptionModel(SaveTranscriptionModel event, Emitter<SettingsState> emit) async {
    try {
      final settingsBox = Hive.box('settings');
      await settingsBox.put('transcription-model', event.model);
      emit(state.copyWith(transcriptionModel: event.model));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
  
  Future<void> _onSaveAssistantModel(SaveAssistantModel event, Emitter<SettingsState> emit) async {
    try {
      final settingsBox = Hive.box('settings');
      await settingsBox.put('assistant-model', event.model);
      emit(state.copyWith(assistantModel: event.model));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
  
  Future<void> _onSaveAgentModel(SaveAgentModel event, Emitter<SettingsState> emit) async {
    try {
      final settingsBox = Hive.box('settings');
      await settingsBox.put('agent-model', event.model);
      emit(state.copyWith(agentModel: event.model));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
  
  // Dictionary management methods
  Future<void> _onLoadDictionary(LoadDictionary event, Emitter<SettingsState> emit) async {
    try {
      final settingsBox = Hive.box('settings');
      final List<dynamic>? storedDictionary = settingsBox.get('dictionary');
      
      if (storedDictionary != null) {
        final List<String> dictionary = storedDictionary.cast<String>().toList();
        emit(state.copyWith(dictionary: dictionary));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
  
  Future<void> _onAddWordToDictionary(AddWordToDictionary event, Emitter<SettingsState> emit) async {
    try {
      final word = event.word.trim();
      
      // Don't add empty words or duplicates
      if (word.isEmpty || state.dictionary.contains(word)) {
        return;
      }
      
      final List<String> updatedDictionary = List.from(state.dictionary)..add(word);
      
      // Save to Hive
      final settingsBox = Hive.box('settings');
      await settingsBox.put('dictionary', updatedDictionary);
      
      // Update state
      emit(state.copyWith(dictionary: updatedDictionary));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
  
  Future<void> _onRemoveWordFromDictionary(RemoveWordFromDictionary event, Emitter<SettingsState> emit) async {
    try {
      final word = event.word;
      
      // Create a new list without the word to remove
      final List<String> updatedDictionary = List.from(state.dictionary)..remove(word);
      
      // Save to Hive
      final settingsBox = Hive.box('settings');
      await settingsBox.put('dictionary', updatedDictionary);
      
      // Update state
      emit(state.copyWith(dictionary: updatedDictionary));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
