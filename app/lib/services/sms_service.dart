import 'dart:convert';

import 'package:http/http.dart' as http;

/// Client that triggers SMS ingestion via the backend.
class SmsService {
  SmsService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<void> ingestMessages({
    String? accountSid,
    String? authToken,
    String? fromNumber,
  }) async {
    final uri = Uri.parse('$baseUrl/ingest/sms');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'accountSid': accountSid,
        'authToken': authToken,
        'fromNumber': fromNumber,
      }),
    );
    if (response.statusCode != 202) {
      throw Exception('Failed to ingest SMS messages');
    }
  }
}
