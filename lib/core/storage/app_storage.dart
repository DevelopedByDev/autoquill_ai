import 'package:hive_flutter/hive_flutter.dart';

class AppStorage {
  static const String _settingsBoxName = 'settings';
  static const String _apiKeyKey = 'groq_api_key';

  static late Box _settingsBox;

  static Future<void> init() async {
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  static Future<void> saveApiKey(String apiKey) async {
    await _settingsBox.put(_apiKeyKey, apiKey);
  }

  static String? getApiKey() {
    return _settingsBox.get(_apiKeyKey) as String?;
  }
}
