import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
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
  
  // Theme mode
  final ThemeMode themeMode;
  
  // Dictionary of words that are harder for models to spell
  final List<String> dictionary;

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
    this.themeMode = ThemeMode.dark,
    this.dictionary = const [],
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
    ThemeMode? themeMode,
    List<String>? dictionary,
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
      themeMode: themeMode ?? this.themeMode,
      dictionary: dictionary ?? this.dictionary,
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
        themeMode,
        dictionary,
        isRecordingHotkey,
        recordingFor,
        currentRecordedHotkey,
        storedHotkeys,
      ];
}
