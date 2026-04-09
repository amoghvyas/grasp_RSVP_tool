import 'dart:convert';
import 'dart:typed_data';

import 'package:docx_to_text/docx_to_text.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Service for extracting raw text content from uploaded files.
///
/// Supports three formats:
/// - `.txt`  → UTF-8 decoded directly
/// - `.docx` → Extracted via `docx_to_text` package (reads Office Open XML)
/// - `.pdf`  → Extracted via Syncfusion's `PdfTextExtractor` (text layer only, no OCR)
///
/// All methods accept raw [Uint8List] bytes (from file_picker or dropzone)
/// and return the extracted text as a plain [String].
class FileParserService {
  /// Parses the given file [bytes] based on the [fileName] extension.
  ///
  /// Throws [UnsupportedError] if the file format is not supported.
  static String parseFile(Uint8List bytes, String fileName) {
    final extension = _getExtension(fileName);

    switch (extension) {
      case '.txt':
        return _parseTxt(bytes);
      case '.docx':
        return _parseDocx(bytes);
      case '.pdf':
        return _parsePdf(bytes);
      default:
        throw UnsupportedError(
          'Unsupported file format: "$extension". '
          'Please use .txt, .docx, or .pdf files.',
        );
    }
  }

  /// Extracts the lowercase file extension from [fileName].
  static String _getExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) return '';
    return fileName.substring(dotIndex).toLowerCase();
  }

  /// Plain text files: simply decode the bytes as UTF-8.
  static String _parseTxt(Uint8List bytes) {
    return utf8.decode(bytes, allowMalformed: true);
  }

  /// Word documents (.docx): extract text from the Office Open XML archive.
  /// The `docx_to_text` package handles unzipping and XML parsing internally.
  static String _parseDocx(Uint8List bytes) {
    return docxToText(bytes);
  }

  /// PDF files: extract the text layer using Syncfusion's PDF library.
  /// This does NOT perform OCR — it only reads embedded text data.
  /// Scanned PDFs without a text layer will return empty or minimal text.
  static String _parsePdf(Uint8List bytes) {
    // Load the PDF document from bytes
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    // Create a text extractor and extract text from all pages
    final PdfTextExtractor extractor = PdfTextExtractor(document);
    final String text = extractor.extractText();

    // Dispose the document to free resources
    document.dispose();

    return text;
  }
}
