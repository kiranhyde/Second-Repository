import 'dart:convert';

import 'package:http/http.dart' as http;

/// Client that triggers WhatsApp ingestion on the backend.
class WhatsAppService {
  WhatsAppService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<void> ingestMessages({
    required String businessAccountId,
    required String accessToken,
    DateTime? since,
  }) async {
    final uri = Uri.parse('$baseUrl/ingest/whatsapp');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'businessAccountId': businessAccountId,
        'accessToken': accessToken,
        'since': since?.toIso8601String(),
      }),
    );
    if (response.statusCode != 202) {
      throw Exception('Failed to ingest WhatsApp messages');
    }
  }
}
