// Geo view — members on a world map with relationship arcs.
// Only shows members with lat/lon coordinates.
// Connection arcs drawn as polylines; color by relationship type.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../theme/silat_theme.dart';
import '../../providers/providers.dart';
import '../../models/member.dart';
import '../../models/relationship.dart';

class GeoScreen extends ConsumerWidget {
  const GeoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider);
    final relsAsync = ref.watch(relationshipsProvider);
    final egoId = ref.watch(egoPerspectiveIdProvider);
    final kinshipMap = ref.watch(kinshipMapProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (members) {
        final geoMembers = members
            .where((m) => m.latitude != null && m.longitude != null)
            .toList();

        if (geoMembers.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_outlined, size: 48, color: SilatColors.fg3),
                const SizedBox(height: SilatSpacing.md),
                Text('no members with location data',
                    style: SilatTypography.body()),
                const SizedBox(height: SilatSpacing.sm),
                Text('add lat/lon when editing a member',
                    style: SilatTypography.label()),
              ],
            ),
          );
        }

        // Compute map center
        final avgLat =
            geoMembers.map((m) => m.latitude!).reduce((a, b) => a + b) /
                geoMembers.length;
        final avgLon =
            geoMembers.map((m) => m.longitude!).reduce((a, b) => a + b) /
                geoMembers.length;

        return relsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (rels) {
            // Build polylines for relationships where both members have geo
            final geoIds = geoMembers.map((m) => m.id).toSet();
            final lines = rels
                .where((r) =>
                    geoIds.contains(r.sourceId) && geoIds.contains(r.targetId))
                .map((r) {
              final src = geoMembers.firstWhere((m) => m.id == r.sourceId);
              final tgt = geoMembers.firstWhere((m) => m.id == r.targetId);
              return (
                points: [
                  LatLng(src.latitude!, src.longitude!),
                  LatLng(tgt.latitude!, tgt.longitude!),
                ],
                color: r.relType == RelType.partner
                    ? SilatColors.slate.withOpacity(0.55)
                    : SilatColors.terracotta.withOpacity(0.45),
              );
            }).toList();

            return Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(avgLat, avgLon),
                    initialZoom: 4,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.kask.silat',
                      tileBuilder: isDark ? darkModeTileBuilder : null,
                    ),
                    // Connection arcs
                    PolylineLayer(
                      polylines: lines
                          .map((l) => Polyline(
                                points: l.points,
                                color: l.color,
                                strokeWidth: 1.5,
                              ))
                          .toList(),
                    ),
                    // Member markers
                    MarkerLayer(
                      markers: geoMembers.map((member) {
                        final isEgo = member.id == egoId;
                        final kinship = kinshipMap[member.id];
                        final color = isEgo
                            ? SilatColors.terracotta
                            : switch (member.gender) {
                                Gender.male => SilatColors.genderM,
                                Gender.female => SilatColors.genderF,
                                _ => SilatColors.genderX,
                              };

                        return Marker(
                          point: LatLng(member.latitude!, member.longitude!),
                          width: 72,
                          height: 56,
                          child: GestureDetector(
                            onTap: () => context.push('/members/${member.id}'),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color.withOpacity(0.2),
                                    border: Border.all(
                                      color: color,
                                      width: isEgo ? 2.5 : 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      member.initials,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? SilatColors.bg1.withOpacity(0.85)
                                        : Colors.white.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    isEgo
                                        ? 'you'
                                        : (kinship?.displayLabel ??
                                            member.firstName),
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: isEgo
                                          ? SilatColors.terracotta
                                          : SilatColors.slate,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Legend
                Positioned(
                  bottom: SilatSpacing.md,
                  left: SilatSpacing.md,
                  child: _Legend(isDark: isDark),
                ),

                // Members without geo (count badge)
                if (geoMembers.length < members.length)
                  Positioned(
                    top: SilatSpacing.sm,
                    right: SilatSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SilatSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? SilatColors.bg1.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(SilatRadius.sm),
                        border: Border.all(
                          color: isDark ? SilatColors.bg3 : SilatColors.lbg3,
                        ),
                      ),
                      child: Text(
                        '${members.length - geoMembers.length} without location',
                        style: SilatTypography.label(dark: isDark),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SilatSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? SilatColors.bg1.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(SilatRadius.sm),
        border: Border.all(
          color: isDark ? SilatColors.bg3 : SilatColors.lbg3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendItem(
            color: SilatColors.terracotta.withOpacity(0.6),
            label: 'parent \u00b7 child',
            isDark: isDark,
            dashed: false,
          ),
          const SizedBox(height: 4),
          _LegendItem(
            color: SilatColors.slate.withOpacity(0.7),
            label: 'partner',
            isDark: isDark,
            dashed: true,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.isDark,
    required this.dashed,
  });
  final Color color;
  final String label;
  final bool isDark;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 2,
          child: CustomPaint(
            painter: _LinePainter(color: color, dashed: dashed),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: SilatTypography.label(dark: isDark)
            .copyWith(fontSize: 10)),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  const _LinePainter({required this.color, required this.dashed});
  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    if (!dashed) {
      canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    } else {
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, 0), Offset((x + 4).clamp(0, size.width), 0), paint);
        x += 7;
      }
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => false;
}
