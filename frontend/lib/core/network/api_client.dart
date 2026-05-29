import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // ─── اختر الـ baseUrl حسب المنصة ──────────────────────────────────────
  // Flutter Web  → localhost:8081
  // Android Emu  → 10.0.2.2:8081  (غيّر السطر أدناه عند التشغيل على المحاكي)
  static const String baseUrl = 'http://localhost:8081/api';

  String? _token;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;
  String? get currentToken => _token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      decoded = {};
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    final msg = decoded['message'] as String?
        ?? decoded['error'] as String?
        ?? 'حدث خطأ غير متوقع';
    throw ApiException(statusCode: response.statusCode, message: msg);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// Singleton
final apiClient = ApiClient();
