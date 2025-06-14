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
  final String?
      transcriptionModel; // whisper-large-v3, whisper-large-v3-turbo, or distil-whisper-large-v3-en
  final String?
      assistantModel; // llama-3.3-70b-versatile, gemma2-9b-it, or llama3-70b-8192

  // Theme mode
  final ThemeMode themeMode;

  // Dictionary of words that are harder for models to spell
  final List<String> dictionary;

  // Phrase replacements: Map of phrases to replace (key) with their replacements (value)
  final Map<String, String> phraseReplacements;

  // Screenshot toggle for assistant mode
  final bool assistantScreenshotEnabled;

  // Multiple language selection
  final List<LanguageCode> selectedLanguages;

  // Push-to-talk settings
  final bool pushToTalkEnabled;

  // Smart transcription setting
  final bool smartTranscriptionEnabled;

  // Sound settings
  final bool soundEnabled;

  // Local transcription settings
  final bool localTranscriptionEnabled;
  final String selectedLocalModel;
  final Map<String, double>
      modelDownloadProgress; // modelName -> progress (0.0 to 1.0)
  final List<String> downloadedModels;
  final Map<String, String> modelDownloadErrors; // modelName -> error message
  final Map<String, bool>
      modelInitializationStatus; // modelName -> isInitialized
  final bool isInitializingModel; // true when initializing any model

  const SettingsState({
    this.apiKey,
    this.isApiKeyVisible = false,
    this.error,
    this.isRecordingHotkey = false,
    this.recordingFor,
    this.currentRecordedHotkey,
    this.storedHotkeys = const {},
    this.transcriptionModel = 'distil-whisper-large-v3-en',
    this.assistantModel = 'llama3-70b-8192',
    this.themeMode = ThemeMode.dark,
    this.dictionary = const [],
    this.phraseReplacements = const {},
    this.assistantScreenshotEnabled = true,
    this.selectedLanguages = const [
      LanguageCode(name: 'Auto-detect', code: '')
    ],
    this.pushToTalkEnabled = true,
    this.smartTranscriptionEnabled = false,
    this.soundEnabled = true,
    this.localTranscriptionEnabled = false,
    this.selectedLocalModel = 'base',
    this.modelDownloadProgress = const {},
    this.downloadedModels = const [],
    this.modelDownloadErrors = const {},
    this.modelInitializationStatus = const {},
    this.isInitializingModel = false,
  });

  // Computed property to get the appropriate transcription model based on selected languages
  String get computedTranscriptionModel {
    // If only English is selected (and not auto-detect), use the English-only model
    if (selectedLanguages.length == 1 && selectedLanguages.first.code == 'en') {
      return 'distil-whisper-large-v3-en';
    }
    // For any other language combination, use the multilingual turbo model
    return 'whisper-large-v3-turbo';
  }

  // Get language codes as a list for API requests
  List<String> get languageCodes {
    return selectedLanguages
        .where((lang) => lang.code.isNotEmpty) // Filter out auto-detect
        .map((lang) => lang.code)
        .toList();
  }

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
    Map<String, String>? phraseReplacements,
    bool? assistantScreenshotEnabled,
    List<LanguageCode>? selectedLanguages,
    bool? pushToTalkEnabled,
    bool? smartTranscriptionEnabled,
    bool? soundEnabled,
    bool? localTranscriptionEnabled,
    String? selectedLocalModel,
    Map<String, double>? modelDownloadProgress,
    List<String>? downloadedModels,
    Map<String, String>? modelDownloadErrors,
    Map<String, bool>? modelInitializationStatus,
    bool? isInitializingModel,
  }) {
    return SettingsState(
      apiKey: apiKey ?? this.apiKey,
      isApiKeyVisible: isApiKeyVisible ?? this.isApiKeyVisible,
      error: error,
      isRecordingHotkey: isRecordingHotkey ?? this.isRecordingHotkey,
      recordingFor: recordingFor ?? this.recordingFor,
      currentRecordedHotkey:
          currentRecordedHotkey ?? this.currentRecordedHotkey,
      storedHotkeys: storedHotkeys ?? this.storedHotkeys,
      transcriptionModel: transcriptionModel ?? this.transcriptionModel,
      assistantModel: assistantModel ?? this.assistantModel,
      themeMode: themeMode ?? this.themeMode,
      dictionary: dictionary ?? this.dictionary,
      phraseReplacements: phraseReplacements ?? this.phraseReplacements,
      assistantScreenshotEnabled:
          assistantScreenshotEnabled ?? this.assistantScreenshotEnabled,
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      pushToTalkEnabled: pushToTalkEnabled ?? this.pushToTalkEnabled,
      smartTranscriptionEnabled:
          smartTranscriptionEnabled ?? this.smartTranscriptionEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      localTranscriptionEnabled:
          localTranscriptionEnabled ?? this.localTranscriptionEnabled,
      selectedLocalModel: selectedLocalModel ?? this.selectedLocalModel,
      modelDownloadProgress:
          modelDownloadProgress ?? this.modelDownloadProgress,
      downloadedModels: downloadedModels ?? this.downloadedModels,
      modelDownloadErrors: modelDownloadErrors ?? this.modelDownloadErrors,
      modelInitializationStatus:
          modelInitializationStatus ?? this.modelInitializationStatus,
      isInitializingModel: isInitializingModel ?? this.isInitializingModel,
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
        phraseReplacements,
        isRecordingHotkey,
        recordingFor,
        currentRecordedHotkey,
        storedHotkeys,
        pushToTalkEnabled,
        assistantScreenshotEnabled,
        selectedLanguages,
        smartTranscriptionEnabled,
        soundEnabled,
        localTranscriptionEnabled,
        selectedLocalModel,
        modelDownloadProgress,
        downloadedModels,
        modelDownloadErrors,
        modelInitializationStatus,
        isInitializingModel,
      ];
}
