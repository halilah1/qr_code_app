import 'dart:convert';

import 'package:http/browser_client.dart';

import '../models/qr_code.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8787',
  );

  static final BrowserClient _client = BrowserClient()..withCredentials = true;

  static Future<bool> isAuthenticated() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/auth/check'));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<void> createCode(String text) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/codes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save QR code');
    }
  }

  static Future<List<QrCode>> getCodes() async {
    final response = await _client.get(Uri.parse('$baseUrl/codes'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch QR codes');
    }

    final data = jsonDecode(response.body);

    return (data as List).map((json) => QrCode.fromJson(json)).toList();
  }

  static Future<void> deleteCode(int id) async {
    final response = await _client.delete(Uri.parse('$baseUrl/codes/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete QR code');
    }
  }
}
