import 'package:equatable/equatable.dart';

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
