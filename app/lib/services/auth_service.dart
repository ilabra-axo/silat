// Google OAuth via ABW pattern (Vercel redirect flow)
// Stores session token in SharedPreferences.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SilatUser {
  const SilatUser({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  });

  final String id;
  final String email;
  final String name;
  final String token;

  factory SilatUser.fromJson(Map<String, dynamic> j, String token) =>
      SilatUser(
        id: j['id'] as String,
        email: j['email'] as String,
        name: j['name'] as String? ?? j['email'] as String,
        token: token,
      );
}

class AuthService {
  static const _tokenKey = 'silat_token';
  static const _userKey = 'silat_user';

  // Set at app startup — override in dev via env
  static String baseUrl = 'https://silat-api.vercel.app';

  SilatUser? _currentUser;
  SilatUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);

    if (token != null && userJson != null) {
      try {
        final user = SilatUser.fromJson(
          jsonDecode(userJson) as Map<String, dynamic>,
          token,
        );
        // Validate token expiry — supports both base64url JWT and URL-encoded JSON
        final exp = _extractExp(token);
        if (exp == null || exp > DateTime.now().millisecondsSinceEpoch) {
          _currentUser = user;
        } else {
          await signOut();
        }
      } catch (_) {
        await signOut();
      }
    }
  }

  // Extracts exp from either a JWT (base64url.payload.sig) or URL-encoded JSON
  int? _extractExp(String token) {
    try {
      // Try URL-encoded JSON (dev token)
      final decoded = jsonDecode(Uri.decodeComponent(token)) as Map<String, dynamic>;
      return decoded['exp'] as int?;
    } catch (_) {}
    try {
      // Try JWT base64url format
      final parts = token.split('.');
      if (parts.length >= 2) {
        final payload = jsonDecode(
          utf8.decode(base64.decode(base64.normalize(parts[1]))),
        ) as Map<String, dynamic>;
        return payload['exp'] as int?;
      }
    } catch (_) {}
    return null;
  }

  Future<void> signInWithGoogle() async {
    final uri = Uri.parse('$baseUrl/api/auth/oauth?provider=google');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Called from deep link handler after OAuth callback
  Future<SilatUser?> handleOAuthCallback({
    required Map<String, dynamic> userJson,
    required String token,
  }) async {
    final user = SilatUser.fromJson(userJson, token);
    _currentUser = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode({
      'id': user.id,
      'email': user.email,
      'name': user.name,
    }));

    return user;
  }

  Future<void> signOut() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Map<String, String> get authHeaders => {
        if (_currentUser != null)
          'Authorization': 'Bearer ${_currentUser!.token}',
        'Content-Type': 'application/json',
      };
}
