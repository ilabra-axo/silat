import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/silat_theme.dart';
import '../../providers/providers.dart';
import '../../models/member.dart';
import '../../models/relationship.dart';
import '../../models/life_event.dart';
import '../../services/event_store.dart';

// ---------------------------------------------------------------------------
// Role label helper — from the viewed member's perspective
// ---------------------------------------------------------------------------
String _roleLabel(String relType, bool viewedIsSource, Member other) {
  if (relType == 'partner') return 'partner';
  if (relType == 'parent-child') {
    if (viewedIsSource) {
      // viewed is parent → other is the child
      return switch (other.gender) {
        Gender.male => 'son',
        Gender.female => 'daughter',
        _ => 'child',
      };
    } else {
      // viewed is child → other is the parent
      return switch (other.gender) {
        Gender.male => 'father',
        Gender.female => 'mother',
        _ => 'parent',
      };
    }
  }
  return relType;
}

class MemberDetailScreen extends ConsumerWidget {
  const MemberDetailScreen({super.key, required this.memberId});
  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider);
    final relsAsync = ref.watch(relationshipsProvider);
    final egoId = ref.watch(egoPerspectiveIdProvider);
    final kinshipMap = ref.watch(kinshipMapProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return membersAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (members) {
        final member = members.where((m) => m.id == memberId).firstOrNull;
        if (member == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Member not found')),
          );
        }

        final kinship = kinshipMap[memberId];
        final isEgo = memberId == egoId;

        return Scaffold(
          appBar: AppBar(
            title: Text(member.displayName),
            actions: [
              IconButton(
                icon: const Icon(Icons.link),
                onPressed: () => context.push('/members/link?source=$memberId'),
                tooltip: 'Link to member',
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/members/$memberId/edit'),
                tooltip: 'Edit',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(SilatSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                _HeaderCard(
                  member: member,
                  kinshipLabel: isEgo ? 'you' : kinship?.displayLabel,
                  isEgo: isEgo,
                  isDark: isDark,
                  onSetEgo: () {
                    ref.read(egoPerspectiveIdProvider.notifier).state =
                        memberId;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Perspective set to ${member.displayName}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),

                const SizedBox(height: SilatSpacing.lg),

                // Details
                _Section(
                  title: 'details',
                  isDark: isDark,
                  child: Column(
                    children: [
                      if (member.birthDate != null)
                        _Row(
                          label: 'born',
                          value: DateFormat('d MMM yyyy').format(member.birthDate!),
                          isDark: isDark,
                        ),
                      if (member.birthLocationLabel != null)
                        _Row(label: 'birth place', value: member.birthLocationLabel!, isDark: isDark),
                      if (member.birthH3 != null)
                        _Row(label: 'birth hex', value: member.birthH3!, isDark: isDark, mono: true),
                      if (member.deathDate != null)
                        _Row(
                          label: 'died',
                          value: DateFormat('d MMM yyyy').format(member.deathDate!),
                          isDark: isDark,
                        ),
                      if (member.locationLabel != null)
                        _Row(label: 'residence', value: member.locationLabel!, isDark: isDark),
                      if (member.residenceH3 != null)
                        _Row(label: 'res. hex', value: member.residenceH3!, isDark: isDark, mono: true),
                      if (member.gender != Gender.unspecified)
                        _Row(
                          label: 'gender',
                          value: member.gender.displayLabel,
                          isDark: isDark,
                        ),
                      if (member.notes != null && member.notes!.isNotEmpty)
                        _Row(
                          label: 'notes',
                          value: member.notes!,
                          isDark: isDark,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: SilatSpacing.lg),

                // Contact
                if (member.phone != null || member.whatsapp != null)
                  _Section(
                    title: 'contact',
                    isDark: isDark,
                    child: Column(
                      children: [
                        if (member.phone != null)
                          _ContactRow(
                            icon: Icons.phone_outlined,
                            label: 'phone',
                            value: member.phone!,
                            isDark: isDark,
                            onTap: () => launchUrl(Uri.parse('tel:${member.phone}')),
                          ),
                        if (member.whatsapp != null)
                          _ContactRow(
                            icon: Icons.chat_outlined,
                            label: 'whatsapp',
                            value: member.whatsapp!,
                            isDark: isDark,
                            onTap: () => launchUrl(
                              Uri.parse('https://wa.me/${member.whatsapp!.replaceAll(RegExp(r'[^0-9]'), '')}'),
                            ),
                          ),
                      ],
                    ),
                  ),

                if (member.phone != null || member.whatsapp != null)
                  const SizedBox(height: SilatSpacing.lg),

                // Relationships
                relsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (rels) {
                    final connected = rels
                        .where((r) => r.sourceId == memberId || r.targetId == memberId)
                        .toList();
                    if (connected.isEmpty) return const SizedBox.shrink();

                    return _Section(
                      title: 'connections',
                      isDark: isDark,
                      child: Column(
                        children: connected.map((rel) {
                          final otherId = rel.sourceId == memberId ? rel.targetId : rel.sourceId;
                          final other = members.where((m) => m.id == otherId).firstOrNull;
                          if (other == null) return const SizedBox.shrink();

                          final role = _roleLabel(rel.relType.code, rel.sourceId == memberId, other);
                          final kinshipResult = kinshipMap[otherId];
                          final egoLabel = (kinshipResult != null && kinshipResult.displayLabel != role)
                              ? kinshipResult.displayLabel
                              : null;

                          return _ConnectionTile(
                            member: other,
                            role: role,
                            egoLabel: egoLabel,
                            isDark: isDark,
                            silenceGap: rel.silenceGapDays,
                            onTap: () => context.push('/members/$otherId'),
                            onLogContact: () async {
                              await ref.read(eventStoreProvider).updateRelationship(
                                actorId: ref.read(currentUserProvider)?.id ?? 'unknown',
                                current: rel,
                                lastContactAt: DateTime.now().toUtc(),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('contact logged'),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ));
                              }
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: SilatSpacing.lg),

                // Life events
                Builder(builder: (context) {
                  final eventsAsync = ref.watch(lifeEventsProvider(memberId));
                  return eventsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (events) => _Section(
                      title: 'life events',
                      isDark: isDark,
                      action: IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () => _showAddLifeEvent(context, ref, memberId, isDark),
                        color: SilatColors.slate,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      child: events.isEmpty
                          ? Text('no events recorded',
                              style: SilatTypography.label(dark: isDark))
                          : Column(
                              children: events
                                  .map((e) => _LifeEventTile(event: e, isDark: isDark))
                                  .toList(),
                            ),
                    ),
                  );
                }),

                const SizedBox(height: SilatSpacing.lg),

                // Claim / stewardship status
                _ClaimSection(
                  member: member,
                  isDark: isDark,
                  onSendIdentityInvite: () async {
                    final store = ref.read(eventStoreProvider);
                    final user = ref.read(currentUserProvider)!;
                    final updated = await store.sendClaimInvite(
                      actorId: user.id,
                      member: member,
                    );
                    final link =
                        'https://silat.ooo/#/claim?t=${updated.claimToken}';
                    await Clipboard.setData(ClipboardData(text: link));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Identity invite link copied'),
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                  onRevokeIdentity:
                      member.claimState == ClaimState.claimPending
                          ? () async {
                              final store = ref.read(eventStoreProvider);
                              final user = ref.read(currentUserProvider)!;
                              await store.revokeClaimInvite(
                                  actorId: user.id, member: member);
                            }
                          : null,
                  onSendStewardInvite: () async {
                    final store = ref.read(eventStoreProvider);
                    final user = ref.read(currentUserProvider)!;
                    final updated = await store.sendStewardshipInvite(
                      actorId: user.id,
                      member: member,
                    );
                    final link =
                        'https://silat.ooo/#/claim?t=${updated.stewardClaimToken}&type=steward';
                    await Clipboard.setData(ClipboardData(text: link));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Stewardship invite link copied'),
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                  onRevokeSteward:
                      member.stewardshipState != StewardshipState.none
                          ? () async {
                              final store = ref.read(eventStoreProvider);
                              final user = ref.read(currentUserProvider)!;
                              await store.revokeStewardship(
                                  actorId: user.id, member: member);
                            }
                          : null,
                ),

                const SizedBox(height: SilatSpacing.lg),

                // QR badge
                _Section(
                  title: 'ar badge',
                  isDark: isDark,
                  child: Column(
                    children: [
                      Text(
                        'Scan this at gatherings to identify ${member.firstName}.',
                        style: SilatTypography.label(dark: isDark),
                      ),
                      const SizedBox(height: SilatSpacing.md),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(SilatSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(SilatRadius.md),
                          ),
                          child: QrImageView(
                            data: 'silat://member/$memberId',
                            version: QrVersions.auto,
                            size: 160,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.member,
    required this.isDark,
    this.kinshipLabel,
    required this.isEgo,
    required this.onSetEgo,
  });

  final Member member;
  final String? kinshipLabel;
  final bool isEgo;
  final bool isDark;
  final VoidCallback onSetEgo;

  Color get _genderColor => switch (member.gender) {
        Gender.male => SilatColors.genderM,
        Gender.female => SilatColors.genderF,
        _ => SilatColors.genderX,
      };

  Widget _buildAvatar() {
    final url = member.photoUrl;
    if (url != null && url.startsWith('data:')) {
      final comma = url.indexOf(',');
      if (comma != -1) {
        final bytes = base64Decode(url.substring(comma + 1));
        return Image.memory(bytes, fit: BoxFit.cover, width: 64, height: 64);
      }
    }
    if (url != null && url.startsWith('http')) {
      return Image.network(url, fit: BoxFit.cover, width: 64, height: 64);
    }
    return Center(
      child: Text(
        member.initials,
        style: SilatTypography.title(
          color: _genderColor,
        ).copyWith(fontSize: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SilatSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? SilatColors.bg1 : SilatColors.lbg1,
        borderRadius: BorderRadius.circular(SilatRadius.lg),
        border: Border.all(
          color: isEgo
              ? SilatColors.terracotta
              : (isDark ? SilatColors.bg3 : SilatColors.lbg3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Large avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _genderColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(SilatRadius.md),
                  border: Border.all(color: _genderColor.withValues(alpha: 0.5)),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildAvatar(),
              ),
              const SizedBox(width: SilatSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.displayName,
                      style: SilatTypography.title(dark: isDark),
                    ),
                    if (kinshipLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        kinshipLabel!,
                        style: SilatTypography.label(
                          color: isEgo
                              ? SilatColors.terracotta
                              : SilatColors.slate,
                          dark: isDark,
                        ).copyWith(letterSpacing: 1),
                      ),
                    ],
                    if (member.isUrgent) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: SilatColors.terracotta.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: SilatColors.terracotta.withOpacity(0.4)),
                            ),
                            child: Text(
                              '⭐ transmission priority',
                              style: SilatTypography.label(
                                dark: isDark,
                                color: SilatColors.terracotta,
                              ).copyWith(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!isEgo) ...[
            const SizedBox(height: SilatSpacing.md),
            TextButton.icon(
              onPressed: onSetEgo,
              icon: const Icon(Icons.person_pin_outlined, size: 16),
              label: const Text('set as my perspective'),
              style: TextButton.styleFrom(
                foregroundColor: SilatColors.slate,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    required this.isDark,
    this.action,
  });

  final String title;
  final Widget child;
  final bool isDark;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: SilatTypography.label(dark: isDark).copyWith(
                color: SilatColors.terracotta,
                letterSpacing: 1.5,
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: SilatSpacing.sm),
              action!,
            ],
          ],
        ),
        const SizedBox(height: SilatSpacing.sm),
        child,
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.isDark,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool isDark;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SilatSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: SilatTypography.label(dark: isDark)),
          ),
          Expanded(
            child: Text(
              value,
              style: mono
                  ? SilatTypography.mono(dark: isDark)
                  : SilatTypography.body(dark: isDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SilatSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: SilatTypography.label(dark: isDark)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                value,
                style: SilatTypography.body(dark: isDark).copyWith(
                  color: SilatColors.slate,
                  decoration: TextDecoration.underline,
                  decorationColor: SilatColors.slate,
                ),
              ),
            ),
          ),
          Icon(icon, size: 14, color: SilatColors.slate),
        ],
      ),
    );
  }
}

class _ConnectionTile extends StatelessWidget {
  const _ConnectionTile({
    required this.member,
    required this.role,
    this.egoLabel,
    required this.isDark,
    required this.onTap,
    this.silenceGap,
    this.onLogContact,
  });

  final Member member;
  final String role;
  final String? egoLabel;
  final bool isDark;
  final VoidCallback onTap;
  final int? silenceGap;
  final VoidCallback? onLogContact;

  Color get _color => switch (member.gender) {
        Gender.male => SilatColors.genderM,
        Gender.female => SilatColors.genderF,
        _ => SilatColors.genderX,
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SilatRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SilatSpacing.sm),
        child: Row(
          children: [
            // Mini avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(SilatRadius.sm),
                border: Border.all(color: _color.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Text(
                  member.initials,
                  style: SilatTypography.label(color: _color)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: SilatSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.displayName,
                      style: SilatTypography.body(dark: isDark)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SilatSpacing.sm,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: SilatColors.terracotta.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(SilatRadius.sm),
                        ),
                        child: Text(
                          role,
                          style: SilatTypography.label(
                            dark: isDark,
                            color: SilatColors.terracotta,
                          ),
                        ),
                      ),
                      if (egoLabel != null) ...[
                        const SizedBox(width: SilatSpacing.sm),
                        Text(
                          'your $egoLabel',
                          style: SilatTypography.label(
                            dark: isDark,
                            color: SilatColors.slate,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (silenceGap != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: _SilenceBadge(days: silenceGap!, isDark: isDark),
                    ),
                  if (silenceGap == null)
                    Text('contact never logged',
                        style: SilatTypography.label(dark: isDark)
                            .copyWith(fontSize: 10, color: SilatColors.fg3)),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onLogContact != null)
                  GestureDetector(
                    onTap: onLogContact,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: SilatColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(Icons.check_circle_outline,
                          size: 14, color: SilatColors.success),
                    ),
                  ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 16, color: SilatColors.fg3),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Silence gap badge
// ---------------------------------------------------------------------------
class _SilenceBadge extends StatelessWidget {
  const _SilenceBadge({required this.days, required this.isDark});
  final int days;
  final bool isDark;

  Color get _color {
    if (days <= 30) return SilatColors.success;
    if (days <= 90) return SilatColors.slate;
    if (days <= 365) return SilatColors.terracotta;
    return SilatColors.error;
  }

  String get _label {
    if (days <= 7) return 'this week';
    if (days < 30) return '${(days / 7).round()}w ago';
    if (days < 365) return '${(days / 30).round()}mo ago';
    return '${(days / 365).round()}y ago';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: _color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'last contact: $_label',
          style: SilatTypography.label(dark: isDark)
              .copyWith(color: _color, fontSize: 10),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Life event tile
// ---------------------------------------------------------------------------
class _LifeEventTile extends StatelessWidget {
  const _LifeEventTile({required this.event, required this.isDark});
  final LifeEvent event;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SilatSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.eventType.icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: SilatSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      event.eventType.displayLabel,
                      style: SilatTypography.label(
                        dark: isDark,
                        color: SilatColors.terracotta,
                      ),
                    ),
                    const SizedBox(width: SilatSpacing.sm),
                    Text(
                      DateFormat('MMM yyyy').format(event.occurredAt),
                      style: SilatTypography.label(dark: isDark),
                    ),
                  ],
                ),
                if (event.notes != null)
                  Text(event.notes!,
                      style: SilatTypography.body(dark: isDark)
                          .copyWith(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add life event bottom sheet
// ---------------------------------------------------------------------------
void _showAddLifeEvent(
    BuildContext context, WidgetRef ref, String memberId, bool isDark) {
  LifeEventType selectedType = LifeEventType.milestone;
  DateTime selectedDate = DateTime.now();
  final notesCtrl = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => Padding(
        padding: EdgeInsets.fromLTRB(
          SilatSpacing.lg,
          SilatSpacing.lg,
          SilatSpacing.lg,
          SilatSpacing.lg + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? SilatColors.bg3 : SilatColors.lbg3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SilatSpacing.md),
            Text('add life event', style: SilatTypography.title(dark: isDark)),
            const SizedBox(height: SilatSpacing.md),
            // Type selector
            Wrap(
              spacing: SilatSpacing.sm,
              runSpacing: SilatSpacing.sm,
              children: LifeEventType.values
                  .map((t) => ChoiceChip(
                        label: Text('${t.icon} ${t.displayLabel}'),
                        selected: selectedType == t,
                        onSelected: (_) => setSheetState(() => selectedType = t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: SilatSpacing.md),
            // Date picker
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: selectedDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setSheetState(() => selectedDate = picked);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: SilatSpacing.md, vertical: SilatSpacing.sm + 2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? SilatColors.bg3 : SilatColors.lbg3,
                  ),
                  borderRadius: BorderRadius.circular(SilatRadius.md),
                ),
                child: Text(
                  DateFormat('d MMM yyyy').format(selectedDate),
                  style: SilatTypography.body(dark: isDark),
                ),
              ),
            ),
            const SizedBox(height: SilatSpacing.md),
            // Notes
            TextField(
              controller: notesCtrl,
              style: SilatTypography.body(dark: isDark),
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'notes (optional)'),
            ),
            const SizedBox(height: SilatSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await ref.read(eventStoreProvider).addLifeEvent(
                        actorId: ref.read(currentUserProvider)?.id ?? 'unknown',
                        memberId: memberId,
                        eventType: selectedType,
                        occurredAt: selectedDate,
                        notes: notesCtrl.text.trim().isEmpty
                            ? null
                            : notesCtrl.text.trim(),
                      );
                  notesCtrl.dispose();
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('save event'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Claim section — identity track + stewardship track side by side
// ---------------------------------------------------------------------------
class _ClaimSection extends StatelessWidget {
  const _ClaimSection({
    required this.member,
    required this.isDark,
    required this.onSendIdentityInvite,
    this.onRevokeIdentity,
    required this.onSendStewardInvite,
    this.onRevokeSteward,
  });

  final Member member;
  final bool isDark;
  final VoidCallback onSendIdentityInvite;
  final VoidCallback? onRevokeIdentity;
  final VoidCallback onSendStewardInvite;
  final VoidCallback? onRevokeSteward;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'account',
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IdentityTrack(
            member: member,
            isDark: isDark,
            onSendInvite: onSendIdentityInvite,
            onRevoke: onRevokeIdentity,
          ),
          const SizedBox(height: SilatSpacing.md),
          Divider(color: isDark ? SilatColors.bg3 : SilatColors.lbg3,
              height: 1),
          const SizedBox(height: SilatSpacing.md),
          _StewardshipTrack(
            member: member,
            isDark: isDark,
            onSendInvite: onSendStewardInvite,
            onRevoke: onRevokeSteward,
          ),
        ],
      ),
    );
  }
}

class _IdentityTrack extends StatelessWidget {
  const _IdentityTrack({
    required this.member,
    required this.isDark,
    required this.onSendInvite,
    this.onRevoke,
  });

  final Member member;
  final bool isDark;
  final VoidCallback onSendInvite;
  final VoidCallback? onRevoke;

  @override
  Widget build(BuildContext context) {
    final isClaimed = member.isClaimed;
    final isPending = member.claimState == ClaimState.claimPending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(
            isClaimed
                ? Icons.verified_outlined
                : isPending
                    ? Icons.hourglass_top_outlined
                    : Icons.person_add_outlined,
            size: 13,
            color: isClaimed
                ? SilatColors.success
                : isPending
                    ? SilatColors.slate
                    : SilatColors.terracotta,
          ),
          const SizedBox(width: 6),
          Text(
            isClaimed
                ? 'identity claimed'
                : isPending
                    ? 'identity invite sent'
                    : 'identity unclaimed',
            style: SilatTypography.label(dark: isDark).copyWith(
              fontWeight: FontWeight.w600,
              color: isClaimed
                  ? SilatColors.success
                  : isPending
                      ? SilatColors.slate
                      : SilatColors.fg2,
            ),
          ),
        ]),
        const SizedBox(height: SilatSpacing.xs),
        Text(
          isClaimed
              ? '${member.firstName} has claimed their own profile.'
              : isPending
                  ? 'Waiting for ${member.firstName} to sign in and claim.'
                  : 'Send ${member.firstName} a link to claim their own identity.',
          style: SilatTypography.label(dark: isDark),
        ),
        if (!isClaimed) ...[
          const SizedBox(height: SilatSpacing.sm),
          Row(children: [
            OutlinedButton.icon(
              onPressed: onSendInvite,
              icon: const Icon(Icons.link, size: 13),
              label: Text(isPending ? 'copy new link' : 'send identity link'),
              style: OutlinedButton.styleFrom(
                foregroundColor: SilatColors.terracotta,
                side: BorderSide(color: SilatColors.terracotta),
                textStyle: SilatTypography.label(dark: isDark),
                padding: const EdgeInsets.symmetric(
                    horizontal: SilatSpacing.md, vertical: SilatSpacing.xs),
              ),
            ),
            if (onRevoke != null) ...[
              const SizedBox(width: SilatSpacing.sm),
              TextButton(
                onPressed: onRevoke,
                child: Text('revoke',
                    style: SilatTypography.label(dark: isDark)
                        .copyWith(color: SilatColors.fg3)),
              ),
            ],
          ]),
        ],
      ],
    );
  }
}

class _StewardshipTrack extends StatelessWidget {
  const _StewardshipTrack({
    required this.member,
    required this.isDark,
    required this.onSendInvite,
    this.onRevoke,
  });

  final Member member;
  final bool isDark;
  final VoidCallback onSendInvite;
  final VoidCallback? onRevoke;

  @override
  Widget build(BuildContext context) {
    final isActive = member.hasSteward;
    final isPending =
        member.stewardshipState == StewardshipState.pending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(
            isActive
                ? Icons.manage_accounts_outlined
                : isPending
                    ? Icons.hourglass_top_outlined
                    : Icons.person_search_outlined,
            size: 13,
            color: isActive
                ? SilatColors.success
                : isPending
                    ? SilatColors.slate
                    : SilatColors.fg3,
          ),
          const SizedBox(width: 6),
          Text(
            isActive
                ? 'steward active'
                : isPending
                    ? 'steward invite sent'
                    : 'no steward',
            style: SilatTypography.label(dark: isDark).copyWith(
              fontWeight: FontWeight.w600,
              color: isActive
                  ? SilatColors.success
                  : isPending
                      ? SilatColors.slate
                      : SilatColors.fg3,
            ),
          ),
        ]),
        const SizedBox(height: SilatSpacing.xs),
        Text(
          isActive
              ? 'A delegate archivist is maintaining this profile. '
                '${member.firstName} can still claim their identity.'
              : isPending
                  ? 'Waiting for the delegate archivist to accept.'
                  : 'Delegate a trusted archivist to maintain this profile.',
          style: SilatTypography.label(dark: isDark),
        ),
        const SizedBox(height: SilatSpacing.sm),
        Row(children: [
          OutlinedButton.icon(
            onPressed: onSendInvite,
            icon: const Icon(Icons.group_add_outlined, size: 13),
            label: Text(
              isActive || isPending ? 'replace steward' : 'delegate steward',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: SilatColors.slate,
              side: BorderSide(color: SilatColors.slate),
              textStyle: SilatTypography.label(dark: isDark),
              padding: const EdgeInsets.symmetric(
                  horizontal: SilatSpacing.md, vertical: SilatSpacing.xs),
            ),
          ),
          if (onRevoke != null) ...[
            const SizedBox(width: SilatSpacing.sm),
            TextButton(
              onPressed: onRevoke,
              child: Text('revoke',
                  style: SilatTypography.label(dark: isDark)
                      .copyWith(color: SilatColors.fg3)),
            ),
          ],
        ]),
      ],
    );
  }
}
