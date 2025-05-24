import 'package:flutter/foundation.dart';

class PhraseReplacementService {
  /// Applies phrase replacements to the given text
  /// Returns the text with all phrase replacements applied
  static String applyReplacements(
      String text, Map<String, String> replacements) {
    if (text.isEmpty || replacements.isEmpty) {
      return text;
    }

    String resultText = text;

    // Sort replacements by length (longest first) to handle overlapping phrases correctly
    final sortedEntries = replacements.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

    // Keep track of already replaced positions to avoid overlapping replacements
    final List<MapEntry<int, int>> replacedRanges = [];

    for (final entry in sortedEntries) {
      final fromPhrase = entry.key;
      final toPhrase = entry.value;

      if (fromPhrase.isNotEmpty && toPhrase.isNotEmpty) {
        final regex = RegExp(RegExp.escape(fromPhrase), caseSensitive: false);
        final matches = regex.allMatches(resultText).toList();

        // Process matches in reverse order to maintain correct indices
        for (final match in matches.reversed) {
          // Check if this match overlaps with any already replaced range
          bool overlaps = false;
          for (final range in replacedRanges) {
            if ((match.start >= range.key && match.start < range.value) ||
                (match.end > range.key && match.end <= range.value) ||
                (match.start <= range.key && match.end >= range.value)) {
              overlaps = true;
              break;
            }
          }

          if (!overlaps) {
            // Replace the text
            resultText =
                resultText.replaceRange(match.start, match.end, toPhrase);
            // Add the new range (adjusted for the replacement)
            replacedRanges
                .add(MapEntry(match.start, match.start + toPhrase.length));
          }
        }
      }
    }

    if (kDebugMode && resultText != text) {
      print('Applied phrase replacements:');
      print('Original: $text');
      print('Result: $resultText');
    }

    return resultText;
  }
}
