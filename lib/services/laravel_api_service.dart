import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaravelApiService {
  static final LaravelApiService _instance = LaravelApiService._internal();
  factory LaravelApiService() => _instance;
  LaravelApiService._internal();

  /// Obtém a base URL da API (do .env ou padrão local)
  String get _baseUrl {
    try {
      return dotenv.env['LARAVEL_API_URL'] ?? 'http://127.0.0.1:8000/api';
    } catch (_) {
      // Se o dotenv não estiver inicializado, retorna o fallback padrão
      return 'http://127.0.0.1:8000/api';
    }
  }

  /// Recupera o token Sanctum armazenado no SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('laravel_token');
  }

  /// Constrói os Headers HTTP mapeando Content-Type, Accept e Authorization (se token existir)
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// GET Request
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();

    return await http.get(url, headers: headers);
  }

  /// POST Request
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();

    return await http.post(url, headers: headers, body: jsonEncode(body));
  }

  /// PUT Request
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();

    return await http.put(url, headers: headers, body: jsonEncode(body));
  }

  /// DELETE Request
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();

    return await http.delete(url, headers: headers);
  }
}
