import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../../../core/storage/app_storage.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<SaveApiKey>(_onSaveApiKey);
    on<ToggleApiKeyVisibility>(_onToggleApiKeyVisibility);
    on<StartRecordingHotkey>(_onStartRecordingHotkey);
    on<StopRecordingHotkey>(_onStopRecordingHotkey);
    on<SaveHotkey>(_onSaveHotkey);
    on<DeleteHotkey>(_onDeleteHotkey);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    // Load saved API key
    final savedApiKey = AppStorage.getApiKey() ?? '';
    
    // Load saved hotkey
    final savedHotkey = AppStorage.getHotkey();
    HotKey? hotKey;
    
    if (savedHotkey != null) {
      final keyCode = savedHotkey['keyCode'] as int;
      final modifiers = (savedHotkey['modifiers'] as List<dynamic>)
          .map((m) => KeyModifier.values[m as int])
          .toList();

      hotKey = HotKey(
        KeyCode.values[keyCode],
        modifiers: modifiers,
      );
      
      await _registerHotkey(hotKey);
    }

    emit(state.copyWith(
      apiKey: savedApiKey,
      transcriptionHotKey: hotKey,
    ));
  }

  Future<void> _onSaveApiKey(SaveApiKey event, Emitter<SettingsState> emit) async {
    try {
      final apiKey = event.apiKey.trim();
      if (apiKey.isNotEmpty) {
        await AppStorage.saveApiKey(apiKey);
        emit(state.copyWith(
          apiKey: apiKey,
          error: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to save API key: $e'));
    }
  }

  void _onToggleApiKeyVisibility(ToggleApiKeyVisibility event, Emitter<SettingsState> emit) {
    emit(state.copyWith(isApiKeyVisible: !state.isApiKeyVisible));
  }

  void _onStartRecordingHotkey(StartRecordingHotkey event, Emitter<SettingsState> emit) {
    emit(state.copyWith(isRecordingHotkey: true));
  }

  void _onStopRecordingHotkey(StopRecordingHotkey event, Emitter<SettingsState> emit) {
    emit(state.copyWith(isRecordingHotkey: false));
  }

  Future<void> _onSaveHotkey(SaveHotkey event, Emitter<SettingsState> emit) async {
    try {
      await _registerHotkey(event.hotkey);
      
      // Save hotkey to storage
      await AppStorage.saveHotkey({
        'keyCode': event.hotkey.keyCode.index,
        'modifiers': event.hotkey.modifiers?.map((m) => m.index).toList() ?? [],
      });

      emit(state.copyWith(
        transcriptionHotKey: event.hotkey,
        isRecordingHotkey: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to save hotkey: $e',
        isRecordingHotkey: false,
      ));
    }
  }

  Future<void> _onDeleteHotkey(DeleteHotkey event, Emitter<SettingsState> emit) async {
    try {
      if (state.transcriptionHotKey != null) {
        try {
          await hotKeyManager.unregister(state.transcriptionHotKey!);
        } catch (e) {
          // Previous hotkey might not be registered, that's ok
          print('Warning: Could not unregister previous hotkey: $e');
        }
      }

      await AppStorage.deleteHotkey();
      emit(state.copyWith(
        transcriptionHotKey: null,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to delete hotkey: $e'));
    }
  }

  Future<void> _registerHotkey(HotKey hotKey) async {
    try {
      if (state.transcriptionHotKey != null) {
        try {
          await hotKeyManager.unregister(state.transcriptionHotKey!);
        } catch (e) {
          // Previous hotkey might not be registered, that's ok
          print('Warning: Could not unregister previous hotkey: $e');
        }
      }

      // Make sure the hotkey isn't already registered before trying to register it
      try {
        await hotKeyManager.unregister(hotKey);
      } catch (e) {
        // Hotkey wasn't registered, that's ok
        print('Info: Hotkey was not previously registered: $e');
      }

      await hotKeyManager.register(
        hotKey,
        keyDownHandler: (hotKey) {
          print("${hotKey.modifiers?.map((m) => m.toString().split('.').last).join('+')}+${hotKey.keyCode.toString().split('.').last}");
        },
      );
    } catch (e) {
      print('Error registering hotkey: $e');
      rethrow;
    }
  }
}
