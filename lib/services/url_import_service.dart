import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

/// Service to fetch and clean text from external URLs.
class UrlImportService {
  /// Fetches the cleaned Markdown content from [url] using Jina Reader AI.
  Future<String> fetchUrlContent(String url) async {
    final jinaUrl = 'https://r.jina.ai/$url';
    
    try {
      final response = await http.get(
        Uri.parse(jinaUrl),
        headers: {
          'Accept': 'text/plain',
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Scholarly Import failed (${response.statusCode}). The site might be protected.');
      }
  
      return response.body;
    } catch (e) {
      throw Exception('Could not reach Scholarly Import service: $e');
    }
  }
}
