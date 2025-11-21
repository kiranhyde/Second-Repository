import 'dart:convert';

import 'package:http/http.dart' as http;

/// Client that triggers Gmail ingestion on the backend.
class GmailService {
  GmailService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<void> ingestMessages({
    required String oauthToken,
    int maxMessages = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/ingest/gmail');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'oauthToken': oauthToken,
        'maxMessages': maxMessages,
      }),
    );
    if (response.statusCode != 202) {
      throw Exception('Failed to ingest Gmail messages');
    }
  }
}
