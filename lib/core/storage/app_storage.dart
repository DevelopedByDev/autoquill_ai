import 'package:hive_flutter/hive_flutter.dart';

class AppStorage {
  static const String _settingsBoxName = 'settings';
  static const String _apiKeyKey = 'groq_api_key';
  static const String _hotkeyKey = 'transcription_hotkey';

  static late Box _settingsBox;

  static Future<void> init() async {
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  static Future<void> saveApiKey(String apiKey) async {
    await _settingsBox.put(_apiKeyKey, apiKey);
  }

  static Future<String?> getApiKey() async {
    if (!_settingsBox.containsKey(_apiKeyKey)) return null;
    final value = _settingsBox.get(_apiKeyKey) as String?;
    return value?.isEmpty == true ? null : value;
  }

  static Future<void> deleteApiKey() async {
    await _settingsBox.delete(_apiKeyKey);
  }

  static Future<void> saveHotkey(Map<String, dynamic> hotkeyData) async {
    await _settingsBox.put(_hotkeyKey, hotkeyData);
  }

  static Map<String, dynamic>? getHotkey() {
    final data = _settingsBox.get(_hotkeyKey);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  static Future<void> deleteHotkey() async {
    await _settingsBox.delete(_hotkeyKey);
  }
}
