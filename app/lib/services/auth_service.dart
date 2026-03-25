// Auth — ABW (agent-bestiary.world) pattern, identical to rabble.
// Web:    signInWithGoogle() navigates to ABW → ABW redirects back to
//         https://silat.ooo/#/auth?token=X&user_id=Y
//         main.dart reads Uri.base.fragment to complete sign-in.
// Native: same redirect, handled via deep link silat://auth?token=X&user_id=Y

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
        id: j['id'] as String? ?? j['user_id'] as String? ?? '',
        email: j['email'] as String? ?? '',
        name: j['display_name'] as String? ??
            j['name'] as String? ??
            j['email'] as String? ??
            '',
        token: token,
      );
}

class AuthService {
  static const _tokenKey = 'silat_token';
  static const _userKey  = 'silat_user';
  static const _abwUrl   = 'https://agent-bestiary.world';
  static const _appUrl   = 'https://silat.ooo';

  SilatUser? _currentUser;
  SilatUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token    = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    if (token != null && userJson != null) {
      try {
        _currentUser = SilatUser.fromJson(
          jsonDecode(userJson) as Map<String, dynamic>,
          token,
        );
      } catch (_) {
        await signOut();
      }
    }
  }

  Future<void> signInWithGoogle() async {
    final redirect = kIsWeb ? _appUrl : 'silat://auth';
    final uri = Uri.parse(
        '$_abwUrl/auth/google?redirect=${Uri.encodeComponent('$redirect/')}');
    if (kIsWeb) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } else {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  // Called after ABW redirects back with token + user_id in the URL fragment.
  Future<SilatUser?> handleAbwCallback({
    required String token,
    required String userId,
  }) async {
    // Fetch full profile from ABW
    Map<String, dynamic> profile = {'id': userId};
    try {
      final res = await http.get(
        Uri.parse('$_abwUrl/api/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        profile = {...body, 'id': body['id'] ?? userId};
      }
    } catch (_) {
      // Network unavailable — continue with userId only
    }

    final user = SilatUser.fromJson(profile, token);
    await _persist(user);
    return user;
  }

  Future<void> _persist(SilatUser user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode({
      'id': user.id, 'email': user.email, 'name': user.name,
    }));
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

  String get token => _currentUser?.token ?? '';
}
