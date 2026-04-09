/// Optimal Recognition Point (ORP) calculator for RSVP reading.
///
/// In speed reading, the ORP is the character within a word that the
/// eye should fixate on for fastest recognition. This service calculates
/// the ORP index based on word length, following established RSVP research
/// (similar to Spritz technology).
class OrpService {
  /// Returns the 0-based index of the ORP character for a word
  /// of the given [wordLength].
  ///
  /// Mapping:
  /// - Length 1:     Index 0
  /// - Length 2-3:   Index 1
  /// - Length 4-5:   Index 2
  /// - Length 6-9:   Index 3
  /// - Length 10+:   Index 4
  static int getOrpIndex(int wordLength) {
    if (wordLength <= 1) return 0;
    if (wordLength <= 3) return 1;
    if (wordLength <= 5) return 2;
    if (wordLength <= 9) return 3;
    return 4; // 10+ characters
  }

  /// Splits a [word] into three segments based on its ORP:
  /// - [0]: Characters before the ORP (to be rendered white, left of center)
  /// - [1]: The ORP character itself (to be rendered red, at dead center)
  /// - [2]: Characters after the ORP (to be rendered white, right of center)
  ///
  /// Returns a [WordSegments] record for convenient destructuring.
  static WordSegments splitWord(String word) {
    if (word.isEmpty) {
      return const WordSegments(before: '', orp: '', after: '');
    }

    final orpIndex = getOrpIndex(word.length);
    // Clamp the ORP index to valid range in case of unexpected input
    final safeIndex = orpIndex.clamp(0, word.length - 1);

    return WordSegments(
      before: word.substring(0, safeIndex),
      orp: word[safeIndex],
      after: safeIndex + 1 < word.length ? word.substring(safeIndex + 1) : '',
    );
  }
}

/// A simple record holding the three segments of an ORP-split word.
class WordSegments {
  final String before;
  final String orp;
  final String after;

  const WordSegments({
    required this.before,
    required this.orp,
    required this.after,
  });
}
