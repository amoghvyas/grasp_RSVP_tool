import 'dart:convert';
import 'package:http/http.dart' as http;

class MessageService {
  static const String _serviceId = 'service_xxx'; // User should replace these
  static const String _templateId = 'template_xxx';
  static const String _userId = 'user_xxx';

  static Future<void> sendMessage(String message) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _userId,
        'template_params': {
          'message': message,
          'project': 'Grasp RSVP PWA',
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send message: ${response.body}');
    }
  }
}
