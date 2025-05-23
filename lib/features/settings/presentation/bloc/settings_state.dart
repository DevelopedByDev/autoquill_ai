import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:autoquill_ai/core/constants/language_codes.dart';

class SettingsState extends Equatable {
  final String? apiKey;
  final bool isApiKeyVisible;
  final String? error;
  
  // Hotkey recording state
  final bool isRecordingHotkey;
  final String? recordingFor; // 'transcription_hotkey' or 'assistant_hotkey'
  final HotKey? currentRecordedHotkey;
  
  // Stored hotkeys
  final Map<String, dynamic> storedHotkeys;
  
  // Model selections
  final String? transcriptionModel; // whisper-large-v3, whisper-large-v3-turbo, or distil-whisper-large-v3-en
  final String? assistantModel; // llama-3.3-70b-versatile, gemma2-9b-it, or llama3-70b-8192
  
  // Theme mode
  final ThemeMode themeMode;
  
  // Dictionary of words that are harder for models to spell
  final List<String> dictionary;
  
  // Screenshot toggle for assistant mode
  final bool assistantScreenshotEnabled;
  final LanguageCode selectedLanguage;
  
  // Push-to-talk settings
  final bool pushToTalkEnabled;

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
    this.themeMode = ThemeMode.dark,
    this.dictionary = const [],
    this.assistantScreenshotEnabled = true,
    this.selectedLanguage = const LanguageCode(name: 'Auto-detect', code: ''),
    this.pushToTalkEnabled = true,
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
    ThemeMode? themeMode,
    List<String>? dictionary,
    bool? assistantScreenshotEnabled,
    LanguageCode? selectedLanguage,
    bool? pushToTalkEnabled,
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
      themeMode: themeMode ?? this.themeMode,
      dictionary: dictionary ?? this.dictionary,
      assistantScreenshotEnabled: assistantScreenshotEnabled ?? this.assistantScreenshotEnabled,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      pushToTalkEnabled: pushToTalkEnabled ?? this.pushToTalkEnabled,
    );
  }

  @override
  List<Object?> get props => [
        apiKey,
        isApiKeyVisible,
        error,
        transcriptionModel,
        assistantModel,
        themeMode,
        dictionary,
        isRecordingHotkey,
        recordingFor,
        currentRecordedHotkey,
        storedHotkeys,
        pushToTalkEnabled,
        assistantScreenshotEnabled,
        selectedLanguage,
      ];
}
