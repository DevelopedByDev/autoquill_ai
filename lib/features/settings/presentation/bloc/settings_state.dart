import 'package:equatable/equatable.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class SettingsState extends Equatable {
  final String? apiKey;
  final bool isApiKeyVisible;
  final String? error;
  
  // Hotkey recording state
  final bool isRecordingHotkey;
  final String? recordingFor; // 'transcription_hotkey', 'assistant_hotkey', 'agent_hotkey', or 'text_hotkey'
  final HotKey? currentRecordedHotkey;
  
  // Stored hotkeys
  final Map<String, dynamic> storedHotkeys;
  
  // Model selections
  final String? transcriptionModel; // whisper-large-v3, whisper-large-v3-turbo, or distil-whisper-large-v3-en
  final String? assistantModel; // llama-3.3-70b-versatile, gemma2-9b-it, or llama3-70b-8192
  final String? agentModel; // compound-beta-mini

  const SettingsState({
    this.apiKey,
    this.isApiKeyVisible = false,
    this.error,
    this.isRecordingHotkey = false,
    this.recordingFor,
    this.currentRecordedHotkey,
    this.storedHotkeys = const {},
    this.transcriptionModel = 'whisper-large-v3',
    this.assistantModel = 'llama3-70b-8192',
    this.agentModel = 'compound-beta-mini',
  });

  SettingsState copyWith({
    String? apiKey,
    bool? isApiKeyVisible,
    String? error,
    bool? isRecordingHotkey,
    String? recordingFor,
    HotKey? currentRecordedHotkey,
    Map<String, dynamic>? storedHotkeys,
    String? transcriptionModel,
    String? assistantModel,
    String? agentModel,
  }) {
    return SettingsState(
      apiKey: apiKey ?? this.apiKey,
      isApiKeyVisible: isApiKeyVisible ?? this.isApiKeyVisible,
      error: error,
      isRecordingHotkey: isRecordingHotkey ?? this.isRecordingHotkey,
      recordingFor: recordingFor ?? this.recordingFor,
      currentRecordedHotkey: currentRecordedHotkey ?? this.currentRecordedHotkey,
      storedHotkeys: storedHotkeys ?? this.storedHotkeys,
      transcriptionModel: transcriptionModel ?? this.transcriptionModel,
      assistantModel: assistantModel ?? this.assistantModel,
      agentModel: agentModel ?? this.agentModel,
    );
  }

  @override
  List<Object?> get props => [
        apiKey,
        isApiKeyVisible,
        error,
        transcriptionModel,
        assistantModel,
        agentModel,
        isRecordingHotkey,
        recordingFor,
        currentRecordedHotkey,
        storedHotkeys,
      ];
}
