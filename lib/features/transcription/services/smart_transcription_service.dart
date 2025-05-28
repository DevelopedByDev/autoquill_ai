import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class SmartTranscriptionService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama3-8b-8192';

  // Optimized HTTP client for reuse
  static final http.Client _httpClient = http.Client();

  static const String _systemPrompt =
      '''Transform the text by applying formatting instructions:

EMOJI RULES:
- Replace emoji mentions with symbols (e.g., "heart emoji" → ❤️)
- Remove punctuation before/after emojis
- Keep emojis together without punctuation

FORMATTING:
- Apply casing instructions ("in all caps" → UPPERCASE)
- Format numbered lists properly
- Format emails (john dot doe at email dot com → john.doe@email.com)
- Format websites (youtube dot com → youtube.com)
- Remove meta-instructions from output

Input: "\${input}"''';

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
        'temperature': 0.3, // Lower temperature for more consistent output
        'max_tokens':
            originalText.length * 2, // Dynamic token limit based on input
        'top_p': 0.9,
        'stream': false,
      };

      final response = await _httpClient
          .post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json; charset=utf-8',
        },
        body: utf8.encode(json.encode(requestBody)),
      )
          .timeout(
        const Duration(seconds: 4), // Strict timeout for smart transcription
        onTimeout: () {
          if (kDebugMode) {
            print('Smart transcription request timed out');
          }
          throw Exception('Smart transcription timeout');
        },
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

  /// Cleanup method to close the HTTP client when done
  static void dispose() {
    _httpClient.close();
  }
}
