import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service to track and store usage statistics
class StatsService {
  static final StatsService _instance = StatsService._internal();
  
  factory StatsService() {
    return _instance;
  }
  
  StatsService._internal();
  
  // Hive box name
  static const String _statsBoxName = 'stats';
  
  // Hive box keys
  static const String _transcriptionWordsKey = 'transcription_words_count';
  static const String _generationWordsKey = 'generation_words_count';
  static const String _transcriptionTimeKey = 'transcription_time_seconds';
  
  /// Initialize the stats service
  Future<void> init() async {
    try {
      // Ensure the stats box is open
      if (!Hive.isBoxOpen(_statsBoxName)) {
        await Hive.openBox(_statsBoxName);
      }
      
      // Initialize counters if they don't exist
      final box = Hive.box(_statsBoxName);
      if (!box.containsKey(_transcriptionWordsKey)) {
        box.put(_transcriptionWordsKey, 0);
      }
      if (!box.containsKey(_generationWordsKey)) {
        box.put(_generationWordsKey, 0);
      }
      if (!box.containsKey(_transcriptionTimeKey)) {
        box.put(_transcriptionTimeKey, 0);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing stats service: $e');
      }
      // Don't throw the error - allow the app to continue even if stats can't be initialized
    }
  }
  

  
  /// Get the total number of transcribed words
  int getTranscriptionWordsCount() {
    final box = Hive.box(_statsBoxName);
    return box.get(_transcriptionWordsKey, defaultValue: 0);
  }
  
  /// Get the total number of generated words
  int getGenerationWordsCount() {
    final box = Hive.box(_statsBoxName);
    return box.get(_generationWordsKey, defaultValue: 0);
  }
  
  /// Get the total transcription time in seconds
  int getTranscriptionTimeSeconds() {
    final box = Hive.box(_statsBoxName);
    return box.get(_transcriptionTimeKey, defaultValue: 0);
  }
  
  /// Get the words per minute (WPM) based on total words and transcription time
  double getWordsPerMinute() {
    final box = Hive.box(_statsBoxName);
    final totalWords = box.get(_transcriptionWordsKey, defaultValue: 0) + 
                       box.get(_generationWordsKey, defaultValue: 0);
    final timeSeconds = box.get(_transcriptionTimeKey, defaultValue: 0);
    
    // Avoid division by zero
    if (timeSeconds == 0) return 0.0;
    
    // Convert seconds to minutes and calculate WPM
    final timeMinutes = timeSeconds / 60.0;
    return totalWords / timeMinutes;
  }
  
  /// Format seconds into a readable time string (MM:SS or HH:MM:SS)
  String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }
  
  /// Add transcribed words to the count
  Future<void> addTranscriptionWords(String text) async {
    if (text.isEmpty) return;
    
    // Count words by splitting on whitespace
    final wordCount = text.trim().split(RegExp(r'\s+')).length;
    
    // Update the count in Hive
    final box = Hive.box(_statsBoxName);
    final currentCount = box.get(_transcriptionWordsKey, defaultValue: 0);
    final newCount = currentCount + wordCount;
    
    // Use synchronous put for immediate update
    box.put(_transcriptionWordsKey, newCount);
  }
  
  /// Add generated words to the count
  Future<void> addGenerationWords(String text) async {
    if (text.isEmpty) return;
    
    // Count words by splitting on whitespace
    final wordCount = text.trim().split(RegExp(r'\s+')).length;
    
    // Update the count in Hive
    final box = Hive.box(_statsBoxName);
    final currentCount = box.get(_generationWordsKey, defaultValue: 0);
    final newCount = currentCount + wordCount;
    
    // Use synchronous put for immediate update
    box.put(_generationWordsKey, newCount);
  }
  
  /// Add recording time to the total transcription time
  Future<void> addTranscriptionTime(int seconds) async {
    if (seconds <= 0) return;
    
    final box = Hive.box(_statsBoxName);
    final currentTime = box.get(_transcriptionTimeKey, defaultValue: 0);
    box.put(_transcriptionTimeKey, currentTime + seconds);
  }
  
  /// Reset all stats
  Future<void> resetStats() async {
    final box = Hive.box(_statsBoxName);
    await box.put(_transcriptionWordsKey, 0);
    await box.put(_generationWordsKey, 0);
    await box.put(_transcriptionTimeKey, 0);
  }
  
  /// Get a listenable for the stats box
  ValueListenable<Box<dynamic>> getStatsBoxListenable({List<String>? keys}) {
    return Hive.box(_statsBoxName).listenable(keys: keys);
  }
}
