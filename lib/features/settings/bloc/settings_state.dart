import 'package:equatable/equatable.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class SettingsState extends Equatable {
  final String? apiKey;
  final bool isApiKeyVisible;
  final String? error;
  final HotKey? transcriptionHotkey;
  final HotKey? assistantHotkey;
  final HotKey? recordedHotkey; // Temporary hotkey being recorded
  final String? activeHotkeyMode; // Which mode is being configured

  const SettingsState({
    this.apiKey,
    this.isApiKeyVisible = false,
    this.error,
    this.transcriptionHotkey,
    this.assistantHotkey,
    this.recordedHotkey,
    this.activeHotkeyMode,
  });

  SettingsState copyWith({
    String? apiKey,
    bool? isApiKeyVisible,
    String? error,
    HotKey? transcriptionHotkey,
    HotKey? assistantHotkey,
    HotKey? recordedHotkey,
    String? activeHotkeyMode,
  }) {
    return SettingsState(
      apiKey: apiKey ?? this.apiKey,
      isApiKeyVisible: isApiKeyVisible ?? this.isApiKeyVisible,
      error: error,
      transcriptionHotkey: transcriptionHotkey ?? this.transcriptionHotkey,
      assistantHotkey: assistantHotkey ?? this.assistantHotkey,
      recordedHotkey: recordedHotkey,
      activeHotkeyMode: activeHotkeyMode,
    );
  }

  @override
  List<Object?> get props => [
        apiKey,
        isApiKeyVisible,
        error,
        transcriptionHotkey,
        assistantHotkey,
        recordedHotkey,
        activeHotkeyMode,
      ];
}
