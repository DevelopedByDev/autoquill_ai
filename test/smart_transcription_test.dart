import 'package:flutter_test/flutter_test.dart';
import 'package:autoquill_ai/features/transcription/services/smart_transcription_service.dart';

void main() {
  group('SmartTranscriptionService', () {
    test('should return original text when API key is empty', () async {
      const originalText = 'Hello world';
      const apiKey = '';

      final result = await SmartTranscriptionService.enhanceTranscription(
          originalText, apiKey);

      expect(result, equals(originalText));
    });

    test('should return original text when input is empty', () async {
      const originalText = '';
      const apiKey = 'test-api-key';

      final result = await SmartTranscriptionService.enhanceTranscription(
          originalText, apiKey);

      expect(result, equals(originalText));
    });

    test('should handle whitespace-only input', () async {
      const originalText = '   ';
      const apiKey = 'test-api-key';

      final result = await SmartTranscriptionService.enhanceTranscription(
          originalText, apiKey);

      expect(result, equals(originalText));
    });
  });
}
