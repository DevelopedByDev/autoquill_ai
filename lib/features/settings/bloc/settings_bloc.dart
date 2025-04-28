import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/app_storage.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<SaveApiKey>(_onSaveApiKey);
    on<DeleteApiKey>(_onDeleteApiKey);
    on<ToggleApiKeyVisibility>(_onToggleApiKeyVisibility);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    try {
      final apiKey = await AppStorage.getApiKey();
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


}
