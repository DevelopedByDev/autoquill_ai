import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../../../core/storage/app_storage.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<SaveApiKey>(_onSaveApiKey);
    on<DeleteApiKey>(_onDeleteApiKey);
    on<ToggleApiKeyVisibility>(_onToggleApiKeyVisibility);
    on<StartHotkeyRecording>(_onStartHotkeyRecording);
    on<SaveHotkey>(_onSaveHotkey);
    on<CancelHotkeyRecording>(_onCancelHotkeyRecording);
    on<UpdateRecordedHotkey>(_onUpdateRecordedHotkey);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    try {
      final apiKey = await AppStorage.getApiKey();
      final hotkeyData = AppStorage.getHotkey();

      HotKey? transcriptionHotkey;
      HotKey? assistantHotkey;

      if (hotkeyData != null) {
        if (hotkeyData['transcription'] != null) {
          transcriptionHotkey = HotKey.fromJson(hotkeyData['transcription']);
        }
        if (hotkeyData['assistant'] != null) {
          assistantHotkey = HotKey.fromJson(hotkeyData['assistant']);
        }
      }

      emit(state.copyWith(
        apiKey: apiKey,
        transcriptionHotkey: transcriptionHotkey,
        assistantHotkey: assistantHotkey,
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

  void _onStartHotkeyRecording(StartHotkeyRecording event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
      activeHotkeyMode: event.mode,
      recordedHotkey: null,
    ));
  }

  Future<void> _onSaveHotkey(SaveHotkey event, Emitter<SettingsState> emit) async {
    if (state.activeHotkeyMode == null) return;

    try {
      final hotkey = event.hotkey;
      final mode = state.activeHotkeyMode!;

      if (mode == 'Transcription Mode') {
        await AppStorage.saveHotkey({'transcription': hotkey.toJson()});
        emit(state.copyWith(
          transcriptionHotkey: hotkey,
          recordedHotkey: null,
          activeHotkeyMode: null,
        ));
      } else if (mode == 'Assistant Mode') {
        await AppStorage.saveHotkey({'assistant': hotkey.toJson()});
        emit(state.copyWith(
          assistantHotkey: hotkey,
          recordedHotkey: null,
          activeHotkeyMode: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onCancelHotkeyRecording(CancelHotkeyRecording event, Emitter<SettingsState> emit) {
    emit(state.copyWith(
      recordedHotkey: null,
      activeHotkeyMode: null,
    ));
  }

  void _onUpdateRecordedHotkey(UpdateRecordedHotkey event, Emitter<SettingsState> emit) {
    emit(state.copyWith(recordedHotkey: event.hotkey));
  }
}
