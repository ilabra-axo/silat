import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../theme/silat_theme.dart';
import '../../models/member.dart';

class MemberTile extends StatelessWidget {
  const MemberTile({
    super.key,
    required this.member,
    this.kinshipLabel,
    this.isEgo = false,
    this.onTap,
    this.onLongPress,
  });

  final Member member;
  final String? kinshipLabel;
  final bool isEgo;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: SilatSpacing.md,
        vertical: SilatSpacing.xs,
      ),
      leading: _Avatar(member: member, isEgo: isEgo),
      title: Text(
        member.displayName,
        style: SilatTypography.body(dark: isDark).copyWith(
          color: isEgo ? SilatColors.terracotta : null,
          fontWeight: isEgo ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
      subtitle: _subtitle(context, isDark),
      trailing: kinshipLabel != null
          ? _KinshipChip(label: kinshipLabel!, isEgo: isEgo)
          : null,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Widget? _subtitle(BuildContext context, bool isDark) {
    final parts = <String>[];

    // Lifespan / dates
    if (member.birthYear != null) {
      parts.add(member.isLiving
          ? 'b. ${member.birthYear}'
          : '${member.birthYear}–${member.deathYear ?? '?'}');
    }

    // City (first non-numeric segment of locationLabel)
    final city = _extractCity(member.locationLabel);
    if (city != null) parts.add(city);

    if (parts.isEmpty) return null;

    return Text(
      parts.join(' · '),
      style: SilatTypography.label(dark: isDark),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  static String? _extractCity(String? label) {
    if (label == null || label.isEmpty) return null;
    final parts = label
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && !RegExp(r'^\d+$').hasMatch(s))
        .toList();
    if (parts.isEmpty) return null;
    return parts.first;
  }

}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.member, required this.isEgo});
  final Member member;
  final bool isEgo;

  Color get _color => switch (member.gender) {
        Gender.male => SilatColors.genderM,
        Gender.female => SilatColors.genderF,
        _ => SilatColors.genderX,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatar = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        border: Border.all(
          color: isEgo ? SilatColors.terracotta : _color.withValues(alpha: 0.4),
          width: isEgo ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(SilatRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: member.photoUrl != null
          ? _buildPhoto(member.photoUrl!)
          : Center(
              child: Text(
                member.initials,
                style: SilatTypography.label(
                  color: isEgo ? SilatColors.terracotta : _color,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
    );

    if (!member.isUrgent) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: SilatColors.terracotta,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? SilatColors.bg0 : Colors.white,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoto(String url) {
    if (url.startsWith('data:')) {
      final comma = url.indexOf(',');
      if (comma != -1) {
        try {
          final bytes = base64Decode(url.substring(comma + 1));
          return Image.memory(bytes, fit: BoxFit.cover, width: 44, height: 44);
        } catch (_) {}
      }
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: 44,
      height: 44,
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

class _KinshipChip extends StatelessWidget {
  const _KinshipChip({required this.label, required this.isEgo});
  final String label;
  final bool isEgo;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SilatSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isEgo
            ? SilatColors.terracotta.withValues(alpha: 0.12)
            : (isDark ? SilatColors.bg2 : SilatColors.lbg2),
        borderRadius: BorderRadius.circular(SilatRadius.sm),
        border: Border.all(
          color: isEgo
              ? SilatColors.terracotta.withValues(alpha: 0.4)
              : (isDark ? SilatColors.bg3 : SilatColors.lbg3),
        ),
      ),
      child: Text(
        label,
        style: SilatTypography.label(dark: isDark).copyWith(
          color: isEgo ? SilatColors.terracotta : null,
        ),
      ),
    );
  }
}
