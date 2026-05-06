// ─────────────────────────────────────────────────────────────────────────────
// ApiClient – Centralized HTTP client for the Ducky Library API
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiClient {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // ── Base URL ──────────────────────────────────────────────────────────────
  // Android emulator → 10.0.2.2 (host loopback alias)
  // iOS simulator   → localhost
  // Web / Desktop   → localhost
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    return 'http://localhost:5000';
  }

  // ── Token storage ─────────────────────────────────────────────────────────
  String? _token;

  String? get token => _token;
  set token(String? value) => _token = value;

  void clearToken() => _token = null;

  // ── Headers ───────────────────────────────────────────────────────────────
  Map<String, String> get _headers {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (_token != null) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  // ── HTTP helpers ──────────────────────────────────────────────────────────

  /// GET request.  Returns decoded JSON body.
  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  /// POST request.  [body] is a Map that will be JSON-encoded.
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// PUT request.
  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.put(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// DELETE request.
  Future<dynamic> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.delete(uri, headers: _headers);
    return _handleResponse(response);
  }

  // ── Response handling ─────────────────────────────────────────────────────
  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Extract error message from API's { "error": "..." } shape
    final message = body is Map ? body['error'] ?? 'Unknown error' : 'Unknown error';
    throw ApiException(response.statusCode, message.toString());
  }
}

// ── Exception type ──────────────────────────────────────────────────────────
class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
