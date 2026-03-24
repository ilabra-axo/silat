import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/silat_theme.dart';
import '../../providers/providers.dart';
import '../../services/auth_service.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _loading = false;

  Future<void> _devSignIn() async {
    setState(() => _loading = true);
    // Mock user — no API needed. Stored locally.
    final auth = ref.read(authServiceProvider);
    final user = await auth.handleOAuthCallback(
      userJson: {
        'id': 'dev-user-001',
        'email': 'dev@silat.local',
        'name': 'Dev User',
      },
      token: _fakeToken('dev-user-001'),
    );
    if (user != null && mounted) {
      ref.read(currentUserProvider.notifier).state = user;
    }
    if (mounted) setState(() => _loading = false);
  }

  String _fakeToken(String userId) {
    // Simple base64 token that auth_service can decode — 30 day expiry
    final payload = '{"userId":"$userId","email":"dev@silat.local",'
        '"exp":${DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch}}';
    return Uri.encodeComponent(payload);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SilatSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Wordmark
              Text(
                'silat',
                style: SilatTypography.display().copyWith(
                  fontSize: 48,
                  letterSpacing: -1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: SilatSpacing.xs),
              Text(
                'ar rahim',
                style: SilatTypography.label().copyWith(
                  color: SilatColors.terracotta,
                  letterSpacing: 3,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: SilatSpacing.lg),
              Text(
                'Family network registry.\nKnow who you\'re talking to.',
                style: SilatTypography.body(),
              ),

              const Spacer(flex: 3),

              // Google sign-in
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : () => auth.signInWithGoogle(),
                  icon: const Icon(Icons.g_mobiledata, size: 20),
                  label: const Text('Continue with Google'),
                ),
              ),

              // Dev bypass — hidden in production via --dart-define=SILAT_PROD=true
              if (!bool.fromEnvironment('SILAT_PROD')) ...[
                const SizedBox(height: SilatSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _loading ? null : _devSignIn,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SilatColors.fg2,
                      side: const BorderSide(color: SilatColors.bg3),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('dev sign-in (local only)'),
                  ),
                ),
              ],

              const SizedBox(height: SilatSpacing.md),
              Text(
                'A Google account is required for cloud sync.\nAll data is stored locally on your device.',
                style: SilatTypography.label(),
                textAlign: TextAlign.center,
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
