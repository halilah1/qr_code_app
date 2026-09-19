import 'dart:convert';
import '../models/qr_code.dart';

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

  static Future<List<QrCode>> getCodes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/codes'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch QR codes');
    }

    final data = jsonDecode(response.body);

    return (data as List)
        .map((json) => QrCode.fromJson(json))
        .toList();
  }
}