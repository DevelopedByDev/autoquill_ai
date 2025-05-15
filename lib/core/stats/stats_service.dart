import 'package:hive_flutter/hive_flutter.dart';

/// Service to track and store usage statistics
class StatsService {
  static final StatsService _instance = StatsService._internal();
  
  factory StatsService() {
    return _instance;
  }
  
  StatsService._internal();
  
  // Hive box keys
  static const String _settingsBoxName = 'settings';
  static const String _transcriptionWordsKey = 'transcription_words_count';
  static const String _generationWordsKey = 'generation_words_count';
  
  /// Initialize the stats service
  Future<void> init() async {
    // Ensure the settings box is open
    if (!Hive.isBoxOpen(_settingsBoxName)) {
      await Hive.openBox(_settingsBoxName);
    }
    
    // Initialize counters if they don't exist
    final box = Hive.box(_settingsBoxName);
    if (!box.containsKey(_transcriptionWordsKey)) {
      await box.put(_transcriptionWordsKey, 0);
    }
    if (!box.containsKey(_generationWordsKey)) {
      await box.put(_generationWordsKey, 0);
    }
  }
  
  /// Get the total number of transcribed words
  int getTranscriptionWordsCount() {
    final box = Hive.box(_settingsBoxName);
    return box.get(_transcriptionWordsKey, defaultValue: 0);
  }
  
  /// Get the total number of generated words
  int getGenerationWordsCount() {
    final box = Hive.box(_settingsBoxName);
    return box.get(_generationWordsKey, defaultValue: 0);
  }
  
  /// Add transcribed words to the count
  Future<void> addTranscriptionWords(String text) async {
    if (text.isEmpty) return;
    
    // Count words by splitting on whitespace
    final wordCount = text.trim().split(RegExp(r'\s+')).length;
    
    // Update the count in Hive
    final box = Hive.box(_settingsBoxName);
    final currentCount = box.get(_transcriptionWordsKey, defaultValue: 0);
    final newCount = currentCount + wordCount;
    
    // Use put instead of putAsync to ensure immediate UI update
    box.put(_transcriptionWordsKey, newCount);
  }
  
  /// Add generated words to the count
  Future<void> addGenerationWords(String text) async {
    if (text.isEmpty) return;
    
    // Count words by splitting on whitespace
    final wordCount = text.trim().split(RegExp(r'\s+')).length;
    
    // Update the count in Hive
    final box = Hive.box(_settingsBoxName);
    final currentCount = box.get(_generationWordsKey, defaultValue: 0);
    final newCount = currentCount + wordCount;
    
    // Use put instead of putAsync to ensure immediate UI update
    box.put(_generationWordsKey, newCount);
  }
  
  /// Reset all stats
  Future<void> resetStats() async {
    final box = Hive.box(_settingsBoxName);
    await box.put(_transcriptionWordsKey, 0);
    await box.put(_generationWordsKey, 0);
  }
}
