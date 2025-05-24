import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class SmartTranscriptionService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  static const String _systemPrompt = '''
      Transform the following text by interpreting and applying embedded formatting instructions. 

      **EMOJI FORMATTING RULES (MOST IMPORTANT):**
      1. Replace mentioned emojis with their actual emoji symbols (e.g., "heart emoji" → ❤️)
      2. **CRITICAL**: Remove ALL punctuation (periods, commas, exclamation marks, etc.) that appears immediately before or after emojis
      3. For consecutive emojis, place them together with NO punctuation between them
      4. Emojis should flow naturally in the sentence without disrupting punctuation rules for the rest of the text
      5. If a sentence ends with an emoji, do NOT add a period after the emoji
      6. If an emoji appears mid-sentence, ensure proper spacing but NO punctuation touching the emoji

      **OTHER FORMATTING RULES:**
      - Format enumerated items as proper numbered or bulleted lists
      - Convert text to uppercase, lowercase, or normal casing when cues like "in all caps," "in lowercase," or "in normal casing" are present
      - The default should be normal casing (first letter of sentence capitalized, correct punctuation, etc.)
      - Properly format email addresses (e.g., "john dot doe at email dot com" → john.doe@email.com)
      - Properly format websites (e.g., "youtube dot com" → youtube.com)
      - Remove all meta-instructions or formatting cues from the final output

      **EMOJI EXAMPLES:**
      ❌ WRONG: "I love cars. 🚗 And I was wondering"
      ✅ CORRECT: "I love cars 🚗 and I was wondering"

      ❌ WRONG: "quite some time now. ⏰🏢 And I was"
      ✅ CORRECT: "quite some time now ⏰🏢 and I was"

      ❌ WRONG: "get lunch with me. 🍣🍗🥚 and I was"
      ✅ CORRECT: "get lunch with me 🍣🍗🥚 and I was"

      ❌ WRONG: "look at the stars. ⭐ Would you like"
      ✅ CORRECT: "look at the stars ⭐ Would you like"

      ❌ WRONG: "chicken. 🥚 and I was"
      ✅ CORRECT: "chicken 🥚 and I was"

      **MORE EXAMPLES:**
      * "In all caps I'm so excited! In normal casing this is going to be awesome. Heart emoji. Muscle emoji." → "I'M SO EXCITED! This is going to be awesome ❤️💪"
      * "My grocery list: number 1 apples, number 2 bananas, number 3 milk." →
        1. Apples
        2. Bananas
        3. Milk
      * "Send the file to jane dot doe at example dot com." → "Send the file to jane.doe@example.com"
      * "In lowercase: THIS SHOULD BE QUIET." → "this should be quiet."
      * "In all caps: remember to stay strong! Star emoji, flex emoji." → "REMEMBER TO STAY STRONG! ⭐💪"
      * "I've been working hard. Clock emoji, building emoji. And I want to celebrate with sushi emoji, chicken emoji, egg emoji tonight." → "I've been working hard ⏰🏢 and I want to celebrate with 🍣🍗🥚 tonight"

      Use this logic to format the following input:

      """\${input}"""
      ''';

  /// Enhances transcription text using Groq API with smart formatting
  static Future<String> enhanceTranscription(
      String originalText, String apiKey) async {
    try {
      if (originalText.trim().isEmpty) {
        return originalText;
      }

      final prompt = _systemPrompt.replaceAll('\${input}', originalText);

      final requestBody = {
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'model': _model,
        'temperature': 1,
        'max_completion_tokens': 32768,
        'top_p': 1,
        'stream': false, // We'll use non-streaming for simplicity
        'stop': null,
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json; charset=utf-8',
        },
        body: utf8.encode(json.encode(requestBody)),
      );

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print(
              'Smart transcription API error: ${response.statusCode} - ${response.body}');
        }
        // Return original text if API fails
        return originalText;
      }

      // Explicitly decode the response body as UTF-8
      final responseString = utf8.decode(response.bodyBytes);
      final responseData = json.decode(responseString);
      final enhancedText =
          responseData['choices']?[0]?['message']?['content'] as String?;

      if (enhancedText != null && enhancedText.trim().isNotEmpty) {
        if (kDebugMode) {
          print('Smart transcription enhanced text: $enhancedText');
        }
        return enhancedText.trim();
      } else {
        if (kDebugMode) {
          print(
              'Smart transcription returned empty result, using original text');
        }
        return originalText;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in smart transcription: $e');
      }
      // Return original text if any error occurs
      return originalText;
    }
  }
}
