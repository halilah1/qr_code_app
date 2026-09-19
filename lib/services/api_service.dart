import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8787';

  static Future<void> createCode(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/codes'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': text,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save QR code');
    }
  }
}