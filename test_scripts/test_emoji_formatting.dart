import 'dart:io';
import '../lib/features/transcription/services/smart_transcription_service.dart';

void main() async {
  print('Smart Transcription Emoji Formatting Test');
  print('==========================================');

  // Get API key from environment or user input
  String? apiKey = Platform.environment['GROQ_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('Please enter your Groq API key:');
    apiKey = stdin.readLineSync();
    if (apiKey == null || apiKey.isEmpty) {
      print('Error: API key is required');
      exit(1);
    }
  }

  // Test cases based on the user's problematic examples
  final testCases = [
    "I've been stealing cars. Car emoji since I was a little boy. Child emoji, tennis emoji and I was wondering if you'd want to understand this sometime. I love you so much. Heart emoji, bride emoji, sushi emoji And I would love to take you out on a date.",
    "I've been stealing cars. Car emoji for quite some time now. Clock emoji, building emoji And I was wondering if you'd want to get lunch with me. Sushi emoji, chicken emoji, egg emoji and I was just thinking how nice it would be to get off on A NEW START.",
    "I've been stealing cars for quite some time now. Clock emoji, building emoji, couch emoji And I was wondering if you'd want to get lunch with me sometime and look at the stars. Star emoji Would you like sushi, chicken or egg? Sushi, chicken. Egg emoji and I was just thinking how nice it would be to get off on a new start",
  ];

  for (int i = 0; i < testCases.length; i++) {
    print('\n--- Test Case ${i + 1} ---');
    print('Input: ${testCases[i]}');
    print('\nProcessing...');

    try {
      final result = await SmartTranscriptionService.enhanceTranscription(
          testCases[i], apiKey!);

      print('Output: $result');

      // Check for problematic patterns
      final hasPeriodsBeforeEmojis = RegExp(
              r'\.\s*[\u{1F000}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
              unicode: true)
          .hasMatch(result);
      final hasCommasBeforeEmojis = RegExp(
              r',\s*[\u{1F000}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
              unicode: true)
          .hasMatch(result);

      if (hasPeriodsBeforeEmojis || hasCommasBeforeEmojis) {
        print('⚠️  WARNING: Found punctuation before emojis!');
      } else {
        print('✅ GOOD: No punctuation found before emojis');
      }
    } catch (e) {
      print('❌ Error: $e');
    }

    print('\n' + '=' * 50);
  }

  print('\nTest completed! Review the outputs to verify emoji formatting.');
  print('Expected behavior:');
  print('- No periods or commas should appear immediately before emojis');
  print('- Consecutive emojis should be grouped together');
  print('- Proper spacing should exist around emoji groups');
}
