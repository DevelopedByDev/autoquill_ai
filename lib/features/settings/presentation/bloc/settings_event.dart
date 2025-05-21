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

class DeleteHotkey extends SettingsEvent {
  final String mode;
  const DeleteHotkey(this.mode);

  @override
  List<Object?> get props => [mode];
}

class LoadStoredHotkeys extends SettingsEvent {}

class SaveTranscriptionModel extends SettingsEvent {
  final String model;
  const SaveTranscriptionModel(this.model);

  @override
  List<Object?> get props => [model];
}

class SaveAssistantModel extends SettingsEvent {
  final String model;
  const SaveAssistantModel(this.model);

  @override
  List<Object?> get props => [model];
}



class LoadDictionary extends SettingsEvent {}

class AddWordToDictionary extends SettingsEvent {
  final String word;
  const AddWordToDictionary(this.word);

  @override
  List<Object?> get props => [word];
}

class RemoveWordFromDictionary extends SettingsEvent {
  final String word;
  const RemoveWordFromDictionary(this.word);

  @override
  List<Object?> get props => [word];
}

class ToggleThemeMode extends SettingsEvent {}

class ToggleAssistantScreenshot extends SettingsEvent {}

