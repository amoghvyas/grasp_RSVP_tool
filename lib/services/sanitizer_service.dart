/// Text Sanitization Pipeline for RSVP Reader.
///
/// Cleans raw text extracted from files (especially PDFs which produce
/// messy output) through a strict 4-step RegEx pipeline, then tokenizes
/// the result into a [List<String>] ready for the RSVP engine.
class SanitizerService {
  /// Runs the full sanitization pipeline on [rawText] and returns
  /// a list of individual word tokens.
  ///
  /// Pipeline steps:
  /// 1. De-hyphenate words split across line breaks
  /// 2. Remove hard line breaks → single spaces
  /// 3. Normalize multiple spaces/tabs → single space
  /// 4. Tokenize by whitespace
  static List<String> sanitize(String rawText) {
    if (rawText.trim().isEmpty) return [];

    String text = rawText;

    // ── Step 1: De-hyphenation ──────────────────────────────────────────
    // Joins words broken across lines, e.g. "develop-\nment" → "development".
    // Handles optional whitespace around the line break.
    text = text.replaceAllMapped(
      RegExp(r'(\w+)-\s*[\r\n]+\s*(\w+)'),
      (match) => '${match.group(1)}${match.group(2)}',
    );

    // ── Step 2: Remove hard line breaks ─────────────────────────────────
    // Replace all \r\n, \r, and \n with a single space to produce a
    // continuous text string.
    text = text.replaceAll(RegExp(r'[\r\n]+'), ' ');

    // ── Step 3: Normalize whitespace ────────────────────────────────────
    // Collapse runs of spaces and tabs into a single space.
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');

    // ── Step 4: Tokenize ────────────────────────────────────────────────
    // Split on whitespace and filter out any empty strings that might
    // result from leading/trailing spaces.
    final tokens = text.trim().split(RegExp(r'\s+'));
    return tokens.where((t) => t.isNotEmpty).toList();
  }
}
