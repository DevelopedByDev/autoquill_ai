import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:flutter/foundation.dart';

import '../storage/app_storage.dart';

/// A centralized service for managing application settings
/// This service provides ValueListenables that can be observed by both
/// the onboarding process and the main app settings
class SettingsService {
  // Singleton instance
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // Constants for settings keys
  static const String _themeKey = 'theme_mode';
  static const String _autoCopyKey = 'auto_copy';
  static const String _transcriptionModelKey = 'transcription-model';
  static const String _assistantModelKey = 'assistant-model';
  static const String _transcriptionHotkeyKey = 'transcription_hotkey';
  static const String _assistantHotkeyKey = 'assistant_hotkey';
  static const String _apiKeyKey = 'api_key';

  // Get the settings box
  Box<dynamic> get _settingsBox => AppStorage.settingsBox;

  // Theme mode listenable
  ValueListenable<Box<dynamic>> get themeListenable =>
      _settingsBox.listenable(keys: [_themeKey]);

  // Auto copy listenable
  ValueListenable<Box<dynamic>> get autoCopyListenable =>
      _settingsBox.listenable(keys: [_autoCopyKey]);

  // Transcription model listenable
  ValueListenable<Box<dynamic>> get transcriptionModelListenable =>
      _settingsBox.listenable(keys: [_transcriptionModelKey]);

  // Assistant model listenable
  ValueListenable<Box<dynamic>> get assistantModelListenable =>
      _settingsBox.listenable(keys: [_assistantModelKey]);

  // Hotkeys listenable
  ValueListenable<Box<dynamic>> get hotkeysListenable => _settingsBox
      .listenable(keys: [_transcriptionHotkeyKey, _assistantHotkeyKey]);

  // Get theme mode
  ThemeMode getThemeMode() {
    final themeValue = _settingsBox.get(_themeKey, defaultValue: 'dark');
    return themeValue == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    final value = mode == ThemeMode.light ? 'light' : 'dark';
    await _settingsBox.put(_themeKey, value);
  }

  // Get auto copy
  bool getAutoCopy() {
    return _settingsBox.get(_autoCopyKey, defaultValue: true) as bool;
  }

  // Set auto copy
  Future<void> setAutoCopy(bool value) async {
    await _settingsBox.put(_autoCopyKey, value);
  }

  // Get transcription model
  String getTranscriptionModel() {
    return _settingsBox.get(_transcriptionModelKey,
        defaultValue: 'distil-whisper-large-v3-en') as String;
  }

  // Set transcription model
  Future<void> setTranscriptionModel(String model) async {
    await _settingsBox.put(_transcriptionModelKey, model);
  }

  // Get assistant model
  String getAssistantModel() {
    return _settingsBox.get(_assistantModelKey, defaultValue: 'llama3-70b-8192')
        as String;
  }

  // Set assistant model
  Future<void> setAssistantModel(String model) async {
    await _settingsBox.put(_assistantModelKey, model);
  }

  // Get transcription hotkey
  Map<String, dynamic>? getTranscriptionHotkey() {
    return AppStorage.getHotkey(_transcriptionHotkeyKey);
  }

  // Set transcription hotkey
  Future<void> setTranscriptionHotkey(HotKey hotkey) async {
    await AppStorage.saveHotkey(_transcriptionHotkeyKey, hotkey.toJson());
  }

  // Get assistant hotkey
  Map<String, dynamic>? getAssistantHotkey() {
    return AppStorage.getHotkey(_assistantHotkeyKey);
  }

  // Set assistant hotkey
  Future<void> setAssistantHotkey(HotKey hotkey) async {
    await AppStorage.saveHotkey(_assistantHotkeyKey, hotkey.toJson());
  }

  // Get API key
  String? getApiKey() {
    return _settingsBox.get(_apiKeyKey) as String?;
  }

  // Set API key
  Future<void> setApiKey(String apiKey) async {
    await _settingsBox.put(_apiKeyKey, apiKey);
  }
}
