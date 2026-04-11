import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

/// Service to fetch and clean text from external URLs.
class UrlImportService {
  /// Fetches the HTML from [url] (via CORS proxy) and extracts main content.
  Future<String> fetchUrlContent(String url) async {
    // Use a public CORS proxy for web compatibility
    final proxyUrl = 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
    
    final response = await http.get(Uri.parse(proxyUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch URL: ${response.statusCode}');
    }

    return _extractMainText(response.body);
  }

  String _extractMainText(String html) {
    final document = html_parser.parse(html);
    
    // Remove scripts, styles, and navs
    document.querySelectorAll('script, style, nav, footer, header, aside, .ads, .sidebar').forEach((e) => e.remove());

    // Try to find the "main" article content
    final mainContent = document.querySelector('article') ?? 
                         document.querySelector('[role="main"]') ?? 
                         document.querySelector('.content') ?? 
                         document.querySelector('.post-content') ?? 
                         document.body;

    if (mainContent == null) return '';

    // Extract text from paragraphs
    final paragraphs = mainContent.querySelectorAll('p, h1, h2, h3, li');
    final text = paragraphs.map((p) => p.text.trim()).where((t) => t.isNotEmpty).join('\n\n');

    if (text.isEmpty) {
      // Fallback: just return body text if extraction failed
      return document.body?.text.trim() ?? '';
    }

    return text;
  }
}
