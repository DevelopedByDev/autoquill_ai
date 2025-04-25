import 'package:equatable/equatable.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class SettingsState extends Equatable {
  final HotKey? transcriptionHotKey;
  final bool isRecordingHotkey;
  final bool isApiKeyVisible;
  final String apiKey;
  final String? error;

  const SettingsState({
    this.transcriptionHotKey,
    this.isRecordingHotkey = false,
    this.isApiKeyVisible = false,
    this.apiKey = '',
    this.error,
  });

  SettingsState copyWith({
    HotKey? transcriptionHotKey,
    bool? isRecordingHotkey,
    bool? isApiKeyVisible,
    String? apiKey,
    String? error,
  }) {
    return SettingsState(
      transcriptionHotKey: transcriptionHotKey ?? this.transcriptionHotKey,
      isRecordingHotkey: isRecordingHotkey ?? this.isRecordingHotkey,
      isApiKeyVisible: isApiKeyVisible ?? this.isApiKeyVisible,
      apiKey: apiKey ?? this.apiKey,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        transcriptionHotKey,
        isRecordingHotkey,
        isApiKeyVisible,
        apiKey,
        error,
      ];
}
