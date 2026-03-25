// Claim screen — handles both claim types arriving via deep link:
//   Identity:    https://silat.ooo/#/claim?t=<token>
//   Stewardship: https://silat.ooo/#/claim?t=<token>&type=steward
// User must be signed in. Looks up the member by token and applies the claim.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/silat_theme.dart';
import '../../providers/providers.dart';
import '../../models/member.dart';

enum _ClaimType { identity, stewardship }

class ClaimScreen extends ConsumerStatefulWidget {
  const ClaimScreen({super.key, required this.token, this.type});
  final String token;
  final String? type; // null or 'steward'

  @override
  ConsumerState<ClaimScreen> createState() => _ClaimScreenState();
}

class _ClaimScreenState extends ConsumerState<ClaimScreen> {
  bool _loading = true;
  bool _done = false;
  String? _error;
  Member? _claimedMember;
  _ClaimType _claimType = _ClaimType.identity;

  @override
  void initState() {
    super.initState();
    _claimType = widget.type == 'steward'
        ? _ClaimType.stewardship
        : _ClaimType.identity;
    _applyClaim();
  }

  Future<void> _applyClaim() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      _fail('Please sign in first to accept this invite.');
      return;
    }

    try {
      final api = ref.read(apiServiceProvider);
      final claimed = await api.claimProfile(
        widget.token,
        steward: _claimType == _ClaimType.stewardship,
      );
      // Refresh the data so the user sees the family tree
      ref.invalidate(familyDataProvider);
      _succeed(claimed);
    } catch (e) {
      _fail(e.toString());
    }
  }

  void _fail(String msg) =>
      setState(() { _loading = false; _error = msg; });

  void _succeed(Member m) =>
      setState(() { _loading = false; _done = true; _claimedMember = m; });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_claimType == _ClaimType.stewardship
            ? 'accept stewardship'
            : 'claim profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(SilatSpacing.xl),
          child: _loading
              ? const CircularProgressIndicator(color: SilatColors.terracotta)
              : _done
                  ? _SuccessView(
                      member: _claimedMember!,
                      claimType: _claimType,
                      isDark: isDark,
                      onContinue: () =>
                          context.go('/members/${_claimedMember!.id}'),
                    )
                  : _ErrorView(
                      message: _error ?? 'Unknown error',
                      isDark: isDark,
                      onBack: () => context.go('/home'),
                    ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    required this.member,
    required this.claimType,
    required this.isDark,
    required this.onContinue,
  });
  final Member member;
  final _ClaimType claimType;
  final bool isDark;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isSteward = claimType == _ClaimType.stewardship;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isSteward ? Icons.manage_accounts_outlined : Icons.verified_outlined,
          size: 64,
          color: SilatColors.success,
        ),
        const SizedBox(height: SilatSpacing.lg),
        Text(
          isSteward
              ? 'Stewardship accepted'
              : 'Welcome, ${member.firstName}!',
          style: SilatTypography.title(
              color: isDark ? SilatColors.fg1 : SilatColors.fg1),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SilatSpacing.md),
        Text(
          isSteward
              ? 'You are now the steward for ${member.displayName}\'s profile. '
                  'You can edit their details and invite connections. '
                  'The real ${member.firstName} can still claim their own identity later.'
              : 'You\'ve claimed your profile in the family tree. '
                  'You can now edit your details.',
          style: SilatTypography.body(dark: isDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SilatSpacing.xl),
        FilledButton(
          onPressed: onContinue,
          child: Text(isSteward ? 'view profile' : 'view my profile'),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.isDark,
    required this.onBack,
  });
  final String message;
  final bool isDark;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 64, color: SilatColors.error),
        const SizedBox(height: SilatSpacing.lg),
        Text(
          'Could not complete',
          style: SilatTypography.title(
              color: isDark ? SilatColors.fg1 : SilatColors.fg1),
        ),
        const SizedBox(height: SilatSpacing.md),
        Text(
          message,
          style: SilatTypography.body(dark: isDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SilatSpacing.xl),
        OutlinedButton(
          onPressed: onBack,
          child: const Text('go home'),
        ),
      ],
    );
  }
}
