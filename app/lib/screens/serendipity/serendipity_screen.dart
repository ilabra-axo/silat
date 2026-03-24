// SerendipityScreen — ranked "reach out" list.
// S(a,b) = w1·R + w2·P + w3·T + w4·U
// Shows ego's connections ranked by serendipity score with reason tags.

import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../models/relationship.dart';
import '../../theme/silat_theme.dart';
import '../../widgets/common/member_tile.dart';

class SerendipityScreen extends ConsumerWidget {
  const SerendipityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final egoId = ref.watch(egoPerspectiveIdProvider);
    final suggestions = ref.watch(serendipityProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('reach'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 18),
            tooltip: 'About serendipity scores',
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: egoId == null
          ? _NoPerspective()
          : suggestions.isEmpty
              ? _Empty()
              : ListView.separated(
                  padding: const EdgeInsets.only(
                    top: SilatSpacing.sm,
                    bottom: SilatSpacing.xl,
                  ),
                  itemCount: suggestions.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (_, i) {
                    final s = suggestions[i];
                    return _SuggestionTile(
                      suggestion: s,
                      isDark: isDark,
                      onTap: () => context.push('/members/${s.member.id}'),
                      onModeChanged: (mode) {
                        ref.read(eventStoreProvider).updateRelationship(
                              actorId: egoId,
                              current: s.relationship,
                              interventionMode: mode,
                            );
                      },
                    );
                  },
                ),
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SilatSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('serendipity score', style: SilatTypography.title()),
              const SizedBox(height: SilatSpacing.md),
              Text(
                'S = 0.30·R + 0.15·P + 0.35·T + 0.20·U\n\n'
                'R  relational salience — how close this bond is\n'
                'P  proximity — how physically near you are\n'
                'T  silence gap — time since last contact\n'
                'U  urgency — transmission-priority flag',
                style: SilatTypography.body().copyWith(
                  color: SilatColors.fg2,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: SilatSpacing.lg),
              Text(
                'intervention modes',
                style: SilatTypography.label(dark: true),
              ),
              const SizedBox(height: SilatSpacing.sm),
              for (final mode in InterventionMode.values) ...[
                RichText(
                  text: TextSpan(
                    style: SilatTypography.body()
                        .copyWith(color: SilatColors.fg2),
                    children: [
                      TextSpan(
                        text: '${mode.displayLabel}  ',
                        style: const TextStyle(color: SilatColors.fg1),
                      ),
                      TextSpan(text: mode.description),
                    ],
                  ),
                ),
                const SizedBox(height: SilatSpacing.xs),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.suggestion,
    required this.isDark,
    required this.onTap,
    required this.onModeChanged,
  });

  final SerendipitySuggestion suggestion;
  final bool isDark;
  final VoidCallback onTap;
  final void Function(InterventionMode) onModeChanged;

  @override
  Widget build(BuildContext context) {
    final s = suggestion;
    final pct = (s.score * 100).round();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SilatSpacing.md,
          vertical: SilatSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with urgency dot reused from MemberTile internals
            _ScoreAvatar(
              initials: s.member.initials,
              score: s.score,
              photoUrl: s.member.photoUrl,
              isUrgent: s.member.isUrgent,
            ),
            const SizedBox(width: SilatSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + score bar row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.member.displayName,
                          style: SilatTypography.body(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: SilatSpacing.sm),
                      Text(
                        '$pct',
                        style: SilatTypography.label(dark: isDark).copyWith(
                          color: _scoreColor(s.score),
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Score bar
                  _ScoreBar(score: s.score),
                  const SizedBox(height: SilatSpacing.xs),
                  // Reason tags + intervention mode chip
                  Wrap(
                    spacing: SilatSpacing.xs,
                    runSpacing: SilatSpacing.xs,
                    children: [
                      for (final r in s.reasons) _Tag(label: r),
                      _ModeChip(
                        mode: s.relationship.interventionMode,
                        onChanged: onModeChanged,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 0.7) return SilatColors.terracotta;
    if (score >= 0.4) return SilatColors.fg1;
    return SilatColors.fg3;
  }
}

// ---------------------------------------------------------------------------

class _ScoreAvatar extends StatelessWidget {
  const _ScoreAvatar({
    required this.initials,
    required this.score,
    this.photoUrl,
    this.isUrgent = false,
  });

  final String initials;
  final double score;
  final String? photoUrl;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    final ring = _ringColor(score);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ring, width: 2),
          ),
          child: ClipOval(
            child: photoUrl != null && photoUrl!.startsWith('http')
                ? Image.network(photoUrl!, fit: BoxFit.cover)
                : Container(
                    color: SilatColors.bg2,
                    alignment: Alignment.center,
                    child: Text(initials,
                        style: SilatTypography.label(dark: true)
                            .copyWith(color: SilatColors.fg1)),
                  ),
          ),
        ),
        if (isUrgent)
          Positioned(
            top: -1,
            right: -1,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: SilatColors.terracotta,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Color _ringColor(double score) {
    if (score >= 0.7) return SilatColors.terracotta;
    if (score >= 0.4) return SilatColors.slate;
    return SilatColors.bg3;
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => Container(
        height: 3,
        width: constraints.maxWidth,
        decoration: BoxDecoration(
          color: SilatColors.bg2,
          borderRadius: BorderRadius.circular(2),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: score.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: score >= 0.7
                  ? SilatColors.terracotta
                  : score >= 0.4
                      ? SilatColors.slate
                      : SilatColors.bg3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SilatSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: SilatColors.bg2,
        borderRadius: BorderRadius.circular(SilatRadius.pill),
        border: Border.all(color: SilatColors.bg3),
      ),
      child: Text(label,
          style: SilatTypography.label(dark: true)
              .copyWith(color: SilatColors.fg3, fontSize: 10)),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.mode, required this.onChanged});
  final InterventionMode mode;
  final void Function(InterventionMode) onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _cycle(),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SilatSpacing.sm, vertical: 2),
        decoration: BoxDecoration(
          color: _bg(),
          borderRadius: BorderRadius.circular(SilatRadius.pill),
          border: Border.all(color: _border()),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon(), size: 10, color: _fg()),
            const SizedBox(width: 3),
            Text(mode.displayLabel,
                style: SilatTypography.label(dark: true)
                    .copyWith(color: _fg(), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _cycle() {
    final next = InterventionMode
        .values[(mode.index + 1) % InterventionMode.values.length];
    onChanged(next);
  }

  Color _bg() => switch (mode) {
        InterventionMode.passive => SilatColors.bg1,
        InterventionMode.ambient => SilatColors.bg2,
        InterventionMode.active => SilatColors.terracotta.withOpacity(0.15),
      };

  Color _border() => switch (mode) {
        InterventionMode.passive => SilatColors.bg3,
        InterventionMode.ambient => SilatColors.slate,
        InterventionMode.active => SilatColors.terracotta,
      };

  Color _fg() => switch (mode) {
        InterventionMode.passive => SilatColors.fg3,
        InterventionMode.ambient => SilatColors.slate,
        InterventionMode.active => SilatColors.terracotta,
      };

  IconData _icon() => switch (mode) {
        InterventionMode.passive => Icons.visibility_outlined,
        InterventionMode.ambient => Icons.notifications_none,
        InterventionMode.active => Icons.bolt_outlined,
      };
}

// ---------------------------------------------------------------------------

class _NoPerspective extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_search_outlined,
              size: 48, color: SilatColors.fg3),
          const SizedBox(height: SilatSpacing.md),
          Text(
            'long-press a member to set perspective',
            style: SilatTypography.body(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hub_outlined, size: 48, color: SilatColors.fg3),
          const SizedBox(height: SilatSpacing.md),
          Text('no connections yet',
              style: SilatTypography.body(), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
