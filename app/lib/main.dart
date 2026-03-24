import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/silat_theme.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: _AuthInitializer()));
}

// Initialise auth before rendering the app — prevents redirect flicker.
// On web, also handles the OAuth redirect callback (?silat_token=...).
class _AuthInitializer extends ConsumerStatefulWidget {
  const _AuthInitializer();

  @override
  ConsumerState<_AuthInitializer> createState() => _AuthInitializerState();
}

class _AuthInitializerState extends ConsumerState<_AuthInitializer> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final auth = ref.read(authServiceProvider);

    // ── OAuth redirect callback (web) ─────────────────────────────────────
    // After Google sign-in, the API redirects back to:
    //   https://silat.ooo?silat_token=...&silat_user=base64url(userJson)
    // We consume those params here, before the router's auth guard fires.
    if (kIsWeb) {
      final uri = Uri.base;
      final token = uri.queryParameters['silat_token'];
      final userB64 = uri.queryParameters['silat_user'];
      final error = uri.queryParameters['silat_error'];

      if (error != null) {
        debugPrint('[auth] OAuth error: $error');
        // Fall through to normal init — will land on sign-in screen
      } else if (token != null && userB64 != null) {
        try {
          final userBytes = base64Url.decode(base64Url.normalize(userB64));
          final userJson =
              jsonDecode(utf8.decode(userBytes)) as Map<String, dynamic>;
          await auth.handleOAuthCallback(userJson: userJson, token: token);
        } catch (e) {
          debugPrint('[auth] callback parse failed: $e');
        }
      }
    }

    // ── Restore persisted session ─────────────────────────────────────────
    await auth.initialize();
    if (auth.currentUser != null) {
      ref.read(currentUserProvider.notifier).state = auth.currentUser;
    }

    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: SilatColors.bg0,
          body: Center(
            child: CircularProgressIndicator(color: SilatColors.terracotta),
          ),
        ),
      );
    }
    return const SilatApp();
  }
}

class SilatApp extends ConsumerWidget {
  const SilatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'silat ar rahim',
      debugShowCheckedModeBanner: false,
      theme: silatLight(),
      darkTheme: silatDark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
