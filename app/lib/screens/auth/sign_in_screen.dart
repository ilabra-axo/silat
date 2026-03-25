import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/silat_theme.dart';
import '../../providers/providers.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => auth.signInWithGoogle(),
                  icon: const Icon(Icons.g_mobiledata, size: 20),
                  label: const Text('Continue with Google'),
                ),
              ),

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
