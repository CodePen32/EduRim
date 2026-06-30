import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../models/user.dart';
import 'push_service.dart';

class AuthService {
  static const _tokenKey = 'auth_token';

  // ─── Token persistence ────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    apiClient.setToken(token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    apiClient.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// يُحمّل token المحفوظ في apiClient عند بدء التطبيق
  Future<void> loadSavedToken() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      apiClient.setToken(token);
    }
  }

  // ─── API calls ────────────────────────────────────────────────────────────

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String gender,
    String city = '',
    int? learningPathId,
    int? bacBranchId,
  }) async {
    final body = <String, dynamic>{
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'gender': gender,
      'city': city,
      'learning_path_id': learningPathId,
      'bac_branch_id': bacBranchId,
    };
    final res = await apiClient.post('/auth/register', body);
    final token = res['token'] as String;
    await saveToken(token);
    _registerPush();
    return UserModel.fromJson(res['user'] as Map<String, dynamic>);
  }

  Future<UserModel> login({
    required String identifier,
    required String password,
  }) async {
    final res = await apiClient.post('/auth/login', {
      'identifier': identifier,
      'password': password,
    });
    final token = res['token'] as String;
    await saveToken(token);
    _registerPush();
    return UserModel.fromJson(res['user'] as Map<String, dynamic>);
  }

  /// Best-effort: send the FCM token after authentication. Never throws.
  void _registerPush() {
    if (kIsWeb) return;
    // ignore: unawaited_futures
    pushService.registerToken();
  }

  Future<UserModel> me() async {
    final res = await apiClient.get('/auth/me');
    return UserModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> updateProfile({
    int? learningPathId,
    int? bacBranchId,
  }) async {
    final body = <String, dynamic>{};
    if (learningPathId != null) body['learning_path_id'] = learningPathId;
    if (bacBranchId != null) body['bac_branch_id'] = bacBranchId;
    await apiClient.put('/auth/profile', body);
  }

  Future<void> logout() async {
    await clearToken();
  }
}

// Singleton
final authService = AuthService();
