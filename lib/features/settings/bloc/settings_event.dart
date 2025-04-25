import 'package:equatable/equatable.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class SaveApiKey extends SettingsEvent {
  final String apiKey;

  const SaveApiKey(this.apiKey);

  @override
  List<Object> get props => [apiKey];
}

class ToggleApiKeyVisibility extends SettingsEvent {}

class StartRecordingHotkey extends SettingsEvent {}

class StopRecordingHotkey extends SettingsEvent {}

class SaveHotkey extends SettingsEvent {
  final HotKey hotkey;

  const SaveHotkey(this.hotkey);

  @override
  List<Object> get props => [hotkey];
}

class DeleteHotkey extends SettingsEvent {}
