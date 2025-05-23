import 'package:hive_flutter/hive_flutter.dart';

class AppStorage {
  static const String _settingsBoxName = 'settings';
  static const String _groqKey = 'groq_api_key';
  static const String _isOnboardingCompletedKey = 'is_onboarding_completed';

  static late Box<dynamic> _settingsBox;

  static Box<dynamic> get settingsBox => _settingsBox;

  static Future<void> init() async {
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  static Future<void> saveApiKey(String apiKey) async {
    await _settingsBox.put(_groqKey, apiKey);
  }

  static Future<String?> getApiKey() async {
    if (!_settingsBox.containsKey(_groqKey)) return null;
    final value = _settingsBox.get(_groqKey) as String?;
    return value?.isEmpty == true ? null : value;
  }

  static Future<void> deleteApiKey() async {
    await _settingsBox.delete(_groqKey);
  }

  static Future<void> saveHotkey(String setting, Map<String, dynamic> hotkeyData) async {
    await _settingsBox.put(setting, hotkeyData);
  }

  static Map<String, dynamic>? getHotkey(String setting) {
    final data = _settingsBox.get(setting);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  static Future<void> deleteHotkey(String setting) async {
    await _settingsBox.delete(setting);
  }
  
  static Future<void> setOnboardingCompleted(bool completed) async {
    await _settingsBox.put(_isOnboardingCompletedKey, completed);
  }
  
  static bool isOnboardingCompleted() {
    return _settingsBox.get(_isOnboardingCompletedKey, defaultValue: false) as bool;
  }
}
