import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/silat_theme.dart';
import 'providers/providers.dart';

// Claim deep-link token detected on startup (set before first render)
String? _pendingClaimToken;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: _AuthInitializer()));
}

// Initialises auth before rendering — prevents redirect flicker.
// Mirrors the rabble pattern: reads Uri.base.fragment for ABW callback.
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

    // ── ABW OAuth callback (web) ──────────────────────────────────────────
    // ABW redirects back to: https://silat.ooo/#/auth?token=X&user_id=Y
    // Claim links arrive as: https://silat.ooo/#/claim?t=<token>
    // Same fragment pattern as rabble.world
    if (kIsWeb) {
      final fragment = Uri.base.fragment; // everything after #

      // Claim / stewardship deep link: /#/claim?t=<token>[&type=steward]
      if (fragment.startsWith('/claim')) {
        final fragUri = Uri.tryParse('https://x$fragment');
        final claimToken = fragUri?.queryParameters['t'];
        if (claimToken != null && claimToken.isNotEmpty) {
          // Preserve the full query string so type=steward passes through
          _pendingClaimToken = fragUri!.query; // e.g. "t=TOKEN&type=steward"
        }
      }

      if (fragment.contains('token=')) {
        final fragUri = Uri.tryParse('https://x/$fragment');
        if (fragUri != null) {
          final token  = fragUri.queryParameters['token'];
          final userId = fragUri.queryParameters['user_id'];
          if (token != null && userId != null) {
            final user = await auth.handleAbwCallback(
              token: token,
              userId: userId,
            );
            if (user != null && mounted) {
              ref.read(currentUserProvider.notifier).state = user;
              // Restore a claim token that was saved before the OAuth redirect
              final prefs = await SharedPreferences.getInstance();
              final pendingToken = prefs.getString('pending_claim_token');
              if (pendingToken != null) {
                final pendingType = prefs.getString('pending_claim_type');
                await prefs.remove('pending_claim_token');
                await prefs.remove('pending_claim_type');
                _pendingClaimToken = 't=$pendingToken'
                    '${pendingType != null ? '&type=$pendingType' : ''}';
              }
            }
          }
        }
      }
    }

    // ── Restore persisted session ─────────────────────────────────────────
    await auth.initialize();
    if (auth.currentUser != null && mounted) {
      ref.read(currentUserProvider.notifier).state = auth.currentUser;
      ref.invalidate(familyDataProvider);
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
    final isDark  = ref.watch(themeModeProvider);
    final router  = ref.watch(routerProvider);

    // If a claim deep-link was parsed at startup, seed the initial location.
    // _pendingClaimToken holds the raw query string, e.g. "t=TOKEN&type=steward"
    final initialLocation = _pendingClaimToken != null
        ? '/claim?$_pendingClaimToken'
        : null;

    return MaterialApp.router(
      title: 'silat ar rahim',
      debugShowCheckedModeBanner: false,
      theme: silatLight(),
      darkTheme: silatDark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: initialLocation != null
          ? ref.watch(routerProviderWithInitial(initialLocation))
          : router,
    );
  }
}
