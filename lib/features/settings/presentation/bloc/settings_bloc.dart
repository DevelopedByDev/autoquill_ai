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
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    try {
      final apiKey = await AppStorage.getApiKey();
      
      // Load stored hotkeys
      add(LoadStoredHotkeys());
      
      emit(state.copyWith(
        apiKey: apiKey,
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
      
      emit(state.copyWith(storedHotkeys: hotkeys));
      
      // Register all hotkeys with the system
      await HotkeyHandler.loadAndRegisterStoredHotkeys();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
