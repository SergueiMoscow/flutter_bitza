import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthApiService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  final _storage = const FlutterSecureStorage();

  // await dotenv.load();
  final String _host = dotenv.env['API_HOST'] ?? '';

  Future<String> login(
      {required String username, required String password}) async {
    if (_host.isEmpty) {
      throw Exception('API_HOST не установлен в переменных окружения.');
    }
    try {
      final url = Uri.parse('$_host/api/login/');
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': '*/*',
              'Connection': 'keep-alive',
            },
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = response.body;
        final data = jsonDecode(response.body);
        await _storage.write(key: _accessTokenKey, value: data['access']);
        await _storage.write(key: _refreshTokenKey, value: data['refresh']);
        return data['access'];
      } else if (response.statusCode == 401) {
        final body = utf8.decode(response.bodyBytes);
        final responseBody = json.decode(body);
        if (responseBody.containsKey('detail')) {
          throw Exception(responseBody['detail']);
        }
      } else {
        throw Exception('Failed to login');
      }
    } on TimeoutException {
      throw Exception('Connection timeout. Please try again.');
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error has occurred $e');
    }
    return '';
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) return null;

    final url = Uri.parse('$_host/api/token/refresh/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccessToken = data['access'];
      final newRefreshToken = data['refresh'];
      await _storage.write(key: _accessTokenKey, value: newAccessToken);
      await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
      return newAccessToken;
    }
    return null;
  }

  Future<http.Response> authenticatedRequest(
      {required String endpoint,
      required String method,
      Map<String, String>? headers,
      dynamic body}) async {
    String? accessToken = await _storage.read(key: _accessTokenKey);
    if (accessToken == null) {
      accessToken = await _refreshAccessToken();
      if (accessToken == null) {
        throw Exception('Unauthorized');
      }
    }

    final url = Uri.parse('$_host$endpoint');
    final combinedHeader = {
      'Authorization': 'Bearer $accessToken',
      if (headers != null) ...headers,
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(url, headers: combinedHeader);
      case 'POST':
        return await http.post(url,
            headers: combinedHeader, body: jsonEncode(body));
      case 'PUT':
        return await http.put(url,
            headers: combinedHeader, body: jsonEncode(body));
      case 'PATCH':
        return await http.patch(url,
            headers: combinedHeader, body: jsonEncode(body));
      case 'DELETE':
        return await http.delete(url,
            headers: combinedHeader, body: jsonEncode(body));
      default:
        throw Exception('Unsupported HTTP method');
    }
  }

  Future<bool> isLoggedIn() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    if (accessToken == null) return false;

    final payload = _parseJwtPayload(accessToken);
    final expiryTime =
        DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
    if (expiryTime.isBefore(DateTime.now())) {
      final newToken = await _refreshAccessToken();
      return newToken != null;
    }
    return true;
  }

  Map<String, dynamic> _parseJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length < 2) {
      throw Exception('Invalid JWT');
    }
    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }

  Future<void> logout() async {
    _storage.delete(key: _accessTokenKey);
    _storage.delete(key: _refreshTokenKey);
  }

  Future<String?> refreshAccessToken() async {
    return await _refreshAccessToken();
  }
}
