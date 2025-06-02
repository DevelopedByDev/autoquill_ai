import 'package:hive_flutter/hive_flutter.dart';

class MobileAppStorage {
  static const String _settingsBoxName = 'settings';
  static const String _groqKey = 'groq_api_key';
  static const String _apiKey =
      'api_key'; // Alternative key used by SettingsService
  static const String _isOnboardingCompletedKey = 'is_onboarding_completed';

  static late Box<dynamic> _settingsBox;

  static Box<dynamic> get settingsBox => _settingsBox;

  static Future<void> init() async {
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  static Future<void> saveApiKey(String apiKey) async {
    // Save to both keys for compatibility
    await _settingsBox.put(_groqKey, apiKey);
    await _settingsBox.put(_apiKey, apiKey);
  }

  static Future<String?> getApiKey() async {
    // Check the primary key first
    if (_settingsBox.containsKey(_groqKey)) {
      final value = _settingsBox.get(_groqKey) as String?;
      if (value?.isNotEmpty == true) return value;
    }

    // Fallback to the alternative key
    if (_settingsBox.containsKey(_apiKey)) {
      final value = _settingsBox.get(_apiKey) as String?;
      if (value?.isNotEmpty == true) return value;
    }

    return null;
  }

  static Future<void> deleteApiKey() async {
    await _settingsBox.delete(_groqKey);
    await _settingsBox.delete(_apiKey);
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    await _settingsBox.put(_isOnboardingCompletedKey, completed);
  }

  static bool isOnboardingCompleted() {
    return _settingsBox.get(_isOnboardingCompletedKey, defaultValue: false)
        as bool;
  }

  // Mobile-specific methods
  static Future<void> saveMobileSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static T? getMobileSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  static Future<void> deleteMobileSetting(String key) async {
    await _settingsBox.delete(key);
  }

  // Keyboard extension settings (for future use)
  static Future<void> saveKeyboardSettings(
      Map<String, dynamic> settings) async {
    await _settingsBox.put('keyboard_settings', settings);
  }

  static Map<String, dynamic>? getKeyboardSettings() {
    final data = _settingsBox.get('keyboard_settings');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }
}
