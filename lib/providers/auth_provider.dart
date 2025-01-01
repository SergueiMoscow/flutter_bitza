import 'package:flutter/foundation.dart';
import 'package:flutter_s3_app/api/auth_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final AuthApiService _authApiService = AuthApiService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  String? _errorMessage;
  String? _token;

  String? get errorMessage => _errorMessage;

  String? get token => _token;

  Future<void> login(String username, String password) async {
    try {
      _token =
          await _authApiService.login(username: username, password: password);
      await _storage.write(key: _accessTokenKey, value: _token);
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadToken() async {
    _token = await _storage.read(key: _accessTokenKey);
    if (_token != null && _token!.isNotEmpty) {
      bool loggedIn = await _authApiService.isLoggedIn();
      if (!loggedIn) {
        // Попытка обновления токена
        String? newToken = await _authApiService.refreshAccessToken();
        if (newToken != null) {
          _token = newToken;
          await _storage.write(key: _accessTokenKey, value: _token);
        } else {
          // Если обновить не удалось, сбросить токен
          _token = null;
          await _storage.delete(key: _accessTokenKey);
          await _storage.delete(key: _refreshTokenKey);
        }
      }
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _authApiService.logout();
    _token = null;
    notifyListeners();
  }

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
}
