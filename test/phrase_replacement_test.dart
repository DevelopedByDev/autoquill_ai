import 'package:flutter_test/flutter_test.dart';
import 'package:autoquill_ai/features/transcription/services/phrase_replacement_service.dart';

void main() {
  group('PhraseReplacementService', () {
    test('should replace simple phrases correctly', () {
      const text = 'Please send the link to calendar to my email.';
      final replacements = {
        'link to calendar': 'https://calendar.google.com/calendar/u/0/r',
      };

      final result =
          PhraseReplacementService.applyReplacements(text, replacements);

      expect(result,
          'Please send the https://calendar.google.com/calendar/u/0/r to my email.');
    });

    test('should handle case-insensitive replacements', () {
      const text = 'Send me the LINK TO CALENDAR please.';
      final replacements = {
        'link to calendar': 'https://calendar.google.com',
      };

      final result =
          PhraseReplacementService.applyReplacements(text, replacements);

      expect(result, 'Send me the https://calendar.google.com please.');
    });

    test('should handle multiple replacements', () {
      const text = 'Check my calendar and send the github link.';
      final replacements = {
        'calendar': 'https://calendar.google.com',
        'github link': 'https://github.com/myrepo',
      };

      final result =
          PhraseReplacementService.applyReplacements(text, replacements);

      expect(result,
          'Check my https://calendar.google.com and send the https://github.com/myrepo.');
    });

    test(
        'should handle overlapping phrases correctly by prioritizing longer phrases',
        () {
      const text = 'Send me the calendar link.';
      final replacements = {
        'calendar': 'https://calendar.google.com',
        'calendar link': 'https://calendar.google.com/calendar/u/0/r',
      };

      final result =
          PhraseReplacementService.applyReplacements(text, replacements);

      // Should use the longer phrase replacement
      expect(result, 'Send me the https://calendar.google.com/calendar/u/0/r.');
    });

    test('should return original text when no replacements provided', () {
      const text = 'This is a test message.';
      final replacements = <String, String>{};

      final result =
          PhraseReplacementService.applyReplacements(text, replacements);

      expect(result, text);
    });

    test('should return original text when text is empty', () {
      const text = '';
      final replacements = {
        'test': 'replacement',
      };

      final result =
          PhraseReplacementService.applyReplacements(text, replacements);

      expect(result, text);
    });

    test('should handle special characters in phrases', () {
      const text = 'My email is john dot doe at example dot com.';
      final replacements = {
        'john dot doe at example dot com': 'john.doe@example.com',
      };

      final result =
          PhraseReplacementService.applyReplacements(text, replacements);

      expect(result, 'My email is john.doe@example.com.');
    });

    test('should not replace when phrase is not found', () {
      const text = 'This is a test message.';
      final replacements = {
        'nonexistent phrase': 'replacement',
      };

      final result =
          PhraseReplacementService.applyReplacements(text, replacements);

      expect(result, text);
    });
  });
}
