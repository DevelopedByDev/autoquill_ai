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
  List<Object?> get props => [apiKey];
}

class DeleteApiKey extends SettingsEvent {}

class ToggleApiKeyVisibility extends SettingsEvent {}

class StartHotkeyRecording extends SettingsEvent {
  final String mode;
  const StartHotkeyRecording(this.mode);

  @override
  List<Object?> get props => [mode];
}

class SaveHotkey extends SettingsEvent {
  final HotKey hotkey;
  const SaveHotkey(this.hotkey);

  @override
  List<Object?> get props => [hotkey];
}

class CancelHotkeyRecording extends SettingsEvent {}

class UpdateRecordedHotkey extends SettingsEvent {
  final HotKey hotkey;
  const UpdateRecordedHotkey(this.hotkey);

  @override
  List<Object?> get props => [hotkey];
}
