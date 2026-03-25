import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/silat_theme.dart';
import '../../providers/providers.dart';
import '../../models/member.dart';
import '../../models/attachment.dart';
import '../../models/kinship.dart';
import '../../models/life_event.dart';


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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete member?'),
                        content: Text(
                            'Remove ${member.displayName} and all their connections. This cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      await ref.read(eventStoreProvider).deleteMember(
                            actorId:
                                ref.read(currentUserProvider)?.id ?? 'unknown',
                            memberId: memberId,
                          );
                      if (context.mounted) context.pop();
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete member',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: SilatSpacing.xs),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('bio',
                                  style: SilatTypography.label(
                                      dark: isDark,
                                      color: SilatColors.fg3)),
                              const SizedBox(height: SilatSpacing.xs),
                              MarkdownBody(
                                data: member.notes!,
                                styleSheet: MarkdownStyleSheet(
                                  p: SilatTypography.body(dark: isDark),
                                  h1: SilatTypography.title(dark: isDark),
                                  h2: SilatTypography.title(dark: isDark)
                                      .copyWith(fontSize: 15),
                                  h3: SilatTypography.label(dark: isDark)
                                      .copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13),
                                  strong: SilatTypography.body(dark: isDark)
                                      .copyWith(fontWeight: FontWeight.w600),
                                  em: SilatTypography.body(dark: isDark)
                                      .copyWith(
                                          fontStyle: FontStyle.italic),
                                  blockquote:
                                      SilatTypography.body(dark: isDark)
                                          .copyWith(
                                              color: SilatColors.fg3),
                                  code: SilatTypography.mono(dark: isDark),
                                ),
                              ),
                            ],
                          ),
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

                // Connections — all kinship from this member's perspective
                Builder(builder: (ctx) {
                  final memberKin = ref.watch(memberKinshipProvider(memberId));
                  final connections = memberKin.entries
                      .where((e) =>
                          e.value.degree <= 4 &&
                          e.value.label != KinshipLabel.extendedFamily &&
                          e.value.label != KinshipLabel.unrelated)
                      .toList()
                    ..sort((a, b) => a.value.degree.compareTo(b.value.degree));

                  if (connections.isEmpty) return const SizedBox.shrink();

                  return relsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (rels) => _Section(
                      title: 'connections',
                      isDark: isDark,
                      child: Column(
                        children: connections.map((entry) {
                          final otherId = entry.key;
                          final kinResult = entry.value;
                          final other = members
                              .where((m) => m.id == otherId)
                              .firstOrNull;
                          if (other == null) return const SizedBox.shrink();

                          final directRel = rels
                              .where((r) =>
                                  (r.sourceId == memberId &&
                                      r.targetId == otherId) ||
                                  (r.targetId == memberId &&
                                      r.sourceId == otherId))
                              .firstOrNull;

                          return _ConnectionTile(
                            member: other,
                            role: kinResult.displayLabel,
                            isDark: isDark,
                            silenceGap: directRel?.silenceGapDays,
                            hasDirectEdge: directRel != null,
                            onTap: () => context.push('/members/$otherId'),
                            onLogContact: directRel != null
                                ? () async {
                                    await ref
                                        .read(eventStoreProvider)
                                        .updateRelationship(
                                          actorId:
                                              ref.read(currentUserProvider)?.id ??
                                                  'unknown',
                                          current: directRel,
                                          lastContactAt:
                                              DateTime.now().toUtc(),
                                        );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text('contact logged'),
                                        duration: Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                      ));
                                    }
                                  }
                                : null,
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }),

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
                  currentUserId: ref.read(currentUserProvider)?.id,
                  onClaimSelf: member.claimState != ClaimState.claimed
                      ? () async {
                          final store = ref.read(eventStoreProvider);
                          final user = ref.read(currentUserProvider)!;
                          await store.claimSelf(
                              actorId: user.id, member: member);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Profile claimed as you'),
                              behavior: SnackBarBehavior.floating,
                            ));
                          }
                        }
                      : null,
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

                // Attachments (photos + documents)
                _AttachmentsSection(
                  memberId: memberId,
                  isDark: isDark,
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
    required this.isDark,
    required this.onTap,
    this.silenceGap,
    this.hasDirectEdge = false,
    this.onLogContact,
  });

  final Member member;
  final String role;
  final bool isDark;
  final VoidCallback onTap;
  final int? silenceGap;
  final bool hasDirectEdge;
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
              clipBehavior: Clip.antiAlias,
              child: member.photoUrl != null
                  ? _buildConnectionPhoto(member.photoUrl!)
                  : Center(
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
                    ],
                  ),
                  if (silenceGap != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: _SilenceBadge(days: silenceGap!, isDark: isDark),
                    ),
                  if (silenceGap == null && hasDirectEdge)
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

  Widget _buildConnectionPhoto(String url) {
    if (url.startsWith('data:')) {
      final comma = url.indexOf(',');
      if (comma != -1) {
        try {
          final bytes = base64Decode(url.substring(comma + 1));
          return Image.memory(bytes, fit: BoxFit.cover, width: 36, height: 36);
        } catch (_) {}
      }
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: 36,
      height: 36,
      errorWidget: (_, __, ___) => Center(
        child: Text(
          member.initials,
          style: SilatTypography.label(color: _color)
              .copyWith(fontWeight: FontWeight.w600),
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
    this.currentUserId,
    this.onClaimSelf,
    required this.onSendIdentityInvite,
    this.onRevokeIdentity,
    required this.onSendStewardInvite,
    this.onRevokeSteward,
  });

  final Member member;
  final bool isDark;
  final String? currentUserId;
  final VoidCallback? onClaimSelf;
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
            currentUserId: currentUserId,
            onClaimSelf: onClaimSelf,
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
    this.currentUserId,
    this.onClaimSelf,
    required this.onSendInvite,
    this.onRevoke,
  });

  final Member member;
  final bool isDark;
  final String? currentUserId;
  final VoidCallback? onClaimSelf;
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
          Wrap(
            spacing: SilatSpacing.sm,
            runSpacing: SilatSpacing.sm,
            children: [
              if (onClaimSelf != null && currentUserId != null)
                FilledButton.icon(
                  onPressed: onClaimSelf,
                  icon: Icon(Icons.how_to_reg_outlined, size: 13),
                  label: const Text('this is me'),
                  style: FilledButton.styleFrom(
                    backgroundColor: SilatColors.terracotta,
                    textStyle: SilatTypography.label(dark: isDark),
                    padding: const EdgeInsets.symmetric(
                        horizontal: SilatSpacing.md, vertical: SilatSpacing.xs),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: onSendInvite,
                icon: const Icon(Icons.link, size: 13),
                label: Text(isPending ? 'copy new link' : 'send to someone else'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SilatColors.terracotta,
                  side: BorderSide(color: SilatColors.terracotta),
                  textStyle: SilatTypography.label(dark: isDark),
                  padding: const EdgeInsets.symmetric(
                      horizontal: SilatSpacing.md, vertical: SilatSpacing.xs),
                ),
              ),
              if (onRevoke != null)
                TextButton(
                  onPressed: onRevoke,
                  child: Text('revoke',
                      style: SilatTypography.label(dark: isDark)
                          .copyWith(color: SilatColors.fg3)),
                ),
            ],
          ),
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

// ── Attachments section ─────────────────────────────────────────────────────

class _AttachmentsSection extends ConsumerStatefulWidget {
  const _AttachmentsSection({required this.memberId, required this.isDark});
  final String memberId;
  final bool isDark;

  @override
  ConsumerState<_AttachmentsSection> createState() => _AttachmentsSectionState();
}

class _AttachmentsSectionState extends ConsumerState<_AttachmentsSection> {
  List<Attachment>? _attachments;
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final atts = await ref
          .read(eventStoreProvider)
          .getAttachments(widget.memberId);
      if (mounted) setState(() { _attachments = atts; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _attachments = []; _loading = false; });
    }
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() => _uploading = true);
    try {
      final user = ref.read(currentUserProvider);
      final att = await ref.read(eventStoreProvider).uploadAttachment(
            actorId: user?.id ?? 'unknown',
            memberId: widget.memberId,
            filename: file.name,
            mimeType: _mimeType(file.extension ?? 'bin'),
            bytes: file.bytes!,
          );
      if (mounted) setState(() { _attachments = [...?_attachments, att]; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _delete(Attachment att) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete attachment?'),
        content: Text('Remove "${att.filename}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final user = ref.read(currentUserProvider);
      await ref.read(eventStoreProvider).deleteAttachment(
            actorId: user?.id ?? 'unknown',
            attachmentId: att.id,
          );
      if (mounted) setState(() => _attachments?.remove(att));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'archive',
      isDark: widget.isDark,
      action: _uploading
          ? const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
          : IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              onPressed: _pickAndUpload,
              color: SilatColors.slate,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Add photo or document',
            ),
      child: _loading
          ? const SizedBox(height: 40, child: Center(child: CircularProgressIndicator()))
          : (_attachments == null || _attachments!.isEmpty)
              ? Text('no photos or documents yet',
                  style: SilatTypography.label(dark: widget.isDark))
              : _AttachmentsGrid(
                  attachments: _attachments!,
                  isDark: widget.isDark,
                  onDelete: _delete,
                ),
    );
  }

  static String _mimeType(String ext) => switch (ext.toLowerCase()) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        'pdf' => 'application/pdf',
        _ => 'application/octet-stream',
      };
}

class _AttachmentsGrid extends StatelessWidget {
  const _AttachmentsGrid({
    required this.attachments,
    required this.isDark,
    required this.onDelete,
  });

  final List<Attachment> attachments;
  final bool isDark;
  final void Function(Attachment) onDelete;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: SilatSpacing.xs,
        mainAxisSpacing: SilatSpacing.xs,
      ),
      itemCount: attachments.length,
      itemBuilder: (_, i) => _AttachmentThumb(
        attachment: attachments[i],
        isDark: isDark,
        onDelete: () => onDelete(attachments[i]),
      ),
    );
  }
}

class _AttachmentThumb extends StatelessWidget {
  const _AttachmentThumb({
    required this.attachment,
    required this.isDark,
    required this.onDelete,
  });

  final Attachment attachment;
  final bool isDark;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(attachment.blobUrl)),
      onLongPress: onDelete,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SilatRadius.sm),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail
            if (attachment.isImage)
              Image.network(attachment.blobUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _docThumb(context))
            else
              _docThumb(context),

            // Filename overlay at bottom
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 2),
                color: Colors.black54,
                child: Text(
                  attachment.filename,
                  style: const TextStyle(
                      fontSize: 8, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _docThumb(BuildContext context) {
    return Container(
      color: isDark ? SilatColors.bg2 : SilatColors.lbg2,
      child: Center(
        child: Icon(
          attachment.isPdf
              ? Icons.picture_as_pdf_outlined
              : Icons.insert_drive_file_outlined,
          size: 28,
          color: SilatColors.slate,
        ),
      ),
    );
  }
}
