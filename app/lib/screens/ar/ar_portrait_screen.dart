// AR Portrait Screen — the moment-of-encounter overlay.
// Shown after scanning a member badge. Clean kinship data over camera feed.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/silat_theme.dart';
import '../../providers/providers.dart';
import '../../models/member.dart';
import '../../models/kinship.dart';

class ArPortraitScreen extends ConsumerWidget {
  const ArPortraitScreen({super.key, required this.memberId});
  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider);
    final kinshipMap = ref.watch(kinshipMapProvider);
    final egoId = ref.watch(egoPerspectiveIdProvider);

    return membersAsync.when(
      loading: () => const _ArScaffold(child: Center(
        child: CircularProgressIndicator(color: SilatColors.fg0),
      )),
      error: (e, _) => _ArScaffold(child: Center(
        child: Text('$e', style: SilatTypography.body(dark: true)),
      )),
      data: (members) {
        final member = members.where((m) => m.id == memberId).firstOrNull;
        if (member == null) {
          return _ArScaffold(
            child: Center(
              child: Text('Member not found',
                  style: SilatTypography.body(dark: true)),
            ),
          );
        }

        final kinship = kinshipMap[memberId];
        final isEgo = memberId == egoId;

        return _ArScaffold(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Dismiss tap on background
              GestureDetector(
                onTap: () => context.pop(),
                child: const ColoredBox(color: Colors.transparent),
              ),

              // Portrait card — anchored lower-centre
              Positioned(
                left: SilatSpacing.lg,
                right: SilatSpacing.lg,
                bottom: 120,
                child: _PortraitCard(
                  member: member,
                  kinship: kinship,
                  isEgo: isEgo,
                  onViewProfile: () => context.push('/members/$memberId'),
                  onSetEgo: () {
                    ref.read(egoPerspectiveIdProvider.notifier).state =
                        memberId;
                    context.pop();
                  },
                ),
              ),

              // Top controls
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SilatSpacing.md,
                    vertical: SilatSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      _IconBtn(
                        icon: Icons.close,
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                      _IconBtn(
                        icon: Icons.qr_code_scanner_outlined,
                        onPressed: () {
                          context.pop();
                          // Return to scan screen
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Full-screen near-black overlay (camera feed would replace this in v2)
class _ArScaffold extends StatelessWidget {
  const _ArScaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SilatColors.bg0.withValues(alpha: 0.92),
      body: child,
    );
  }
}

class _PortraitCard extends StatelessWidget {
  const _PortraitCard({
    required this.member,
    required this.kinship,
    required this.isEgo,
    required this.onViewProfile,
    required this.onSetEgo,
  });

  final Member member;
  final KinshipResult? kinship;
  final bool isEgo;
  final VoidCallback onViewProfile;
  final VoidCallback onSetEgo;

  Color get _genderColor => switch (member.gender) {
        Gender.male => SilatColors.genderM,
        Gender.female => SilatColors.genderF,
        _ => SilatColors.genderX,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SilatSpacing.lg),
      decoration: BoxDecoration(
        color: SilatColors.bg0.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(SilatRadius.lg),
        border: Border.all(
          color: kinship != null
              ? _generationColor(kinship!.degree)
              : SilatColors.bg3,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kinship label — most important data point, displayed first
          if (kinship != null || isEgo) ...[
            Text(
              isEgo ? 'you' : kinship!.displayLabel.toUpperCase(),
              style: SilatTypography.label(dark: true, color: isEgo
                  ? SilatColors.terracotta
                  : _generationColor(kinship?.degree ?? 0),
              ).copyWith(letterSpacing: 2),
            ),
            const SizedBox(height: SilatSpacing.sm),
          ],

          // Name
          Text(
            member.displayName,
            style: SilatTypography.display(dark: true).copyWith(
              fontSize: 32,
              letterSpacing: -0.8,
            ),
          ),

          // Key facts — only what's present
          const SizedBox(height: SilatSpacing.xs),
          _FactRow(member: member),

          const SizedBox(height: SilatSpacing.lg),

          // Degree indicator
          if (kinship != null && !isEgo)
            _DegreeBar(degree: kinship!.degree),

          const SizedBox(height: SilatSpacing.lg),

          // Actions
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onViewProfile,
                  child: const Text('view profile'),
                ),
              ),
              const SizedBox(width: SilatSpacing.sm),
              OutlinedButton(
                onPressed: onSetEgo,
                style: OutlinedButton.styleFrom(
                  foregroundColor: SilatColors.slate,
                  side: const BorderSide(color: SilatColors.bg3),
                ),
                child: const Text('my tree'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _generationColor(int degree) => switch (degree) {
        0 => SilatColors.gen0,
        1 => SilatColors.gen1,
        2 => SilatColors.gen2,
        _ => SilatColors.gen3,
      };
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.member});
  final Member member;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (member.birthYear != null) {
      parts.add(member.isLiving
          ? 'b. ${member.birthYear}'
          : '${member.birthYear}–${member.deathYear}');
    }
    if (member.locationLabel != null) parts.add(member.locationLabel!);
    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join('  ·  '),
      style: SilatTypography.body(dark: true, color: SilatColors.fg1),
    );
  }
}

// Minimal 6-degree bar — Tufte sparkline style
class _DegreeBar extends StatelessWidget {
  const _DegreeBar({required this.degree});
  final int degree;

  @override
  Widget build(BuildContext context) {
    const maxDegrees = 6;
    final clamped = degree.clamp(0, maxDegrees);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'degree $degree',
          style: SilatTypography.label(dark: true, color: SilatColors.fg2),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(maxDegrees, (i) {
            final filled = i < clamped;
            return Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: i < maxDegrees - 1 ? 3 : 0),
                decoration: BoxDecoration(
                  color: filled
                      ? SilatColors.terracotta
                      : SilatColors.bg3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: SilatColors.bg0.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(SilatRadius.md),
          border: Border.all(color: SilatColors.bg3),
        ),
        child: Icon(icon, color: SilatColors.fg0, size: 20),
      ),
    );
  }
}
