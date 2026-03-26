// Graph screen — three visualization modes accessible via the mode bar.
//   web  — concentric ego-web: kinship degree = ring distance from centre
//   tree — generation lanes: Reingold-Tilford-style horizontal rows
//   arc  — arc diagram: linear axis, arched relationship lines
//
// Tap any node → member profile.
// Long-press any node → re-centre perspective on that person.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/silat_theme.dart';
import '../../providers/providers.dart';
import '../../models/member.dart';
import '../../models/relationship.dart';
import '../../models/kinship.dart';
import 'ego_web_painter.dart';
import 'gen_lane_painter.dart';
import 'arc_diagram_painter.dart';

enum _GraphMode { web, tree, arc }

class GraphScreen extends ConsumerStatefulWidget {
  const GraphScreen({super.key});

  @override
  ConsumerState<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends ConsumerState<GraphScreen> {
  _GraphMode _mode = _GraphMode.web;

  // Layouts are computed fresh each build; held here to avoid reallocation.
  final _webLayout = EgoWebLayout();
  final _treeLayout = GenLaneLayout();
  final _arcLayout = ArcLayout();

  // Transformation controller for tree view — used to fit content on first show.
  final _treeController = TransformationController();
  bool _treeTransformSet = false;

  @override
  void dispose() {
    _treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersProvider);
    final relsAsync = ref.watch(relationshipsProvider);
    final egoId = ref.watch(egoPerspectiveIdProvider);
    final kinshipMap = ref.watch(kinshipMapProvider);

    return Column(
      children: [
        _ModeBar(
          mode: _mode,
          onChanged: (m) {
            setState(() {
              _mode = m;
              _treeTransformSet = false; // re-fit on next tree render
            });
          },
        ),
        Expanded(
          child: membersAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (members) {
              // Auto-select first member as ego if none set yet
              if (egoId == null && members.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(egoPerspectiveIdProvider.notifier).state =
                      members.first.id;
                });
              }

              return relsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (rels) {
                  if (members.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.hub_outlined,
                              size: 48, color: SilatColors.fg3),
                          const SizedBox(height: SilatSpacing.md),
                          Text('no members yet',
                              style: SilatTypography.body()),
                        ],
                      ),
                    );
                  }

                  return LayoutBuilder(builder: (ctx, constraints) {
                    return switch (_mode) {
                      _GraphMode.web => _buildWebView(
                          constraints, members, rels, egoId, kinshipMap),
                      _GraphMode.tree => _buildTreeView(
                          constraints, members, rels, egoId, kinshipMap),
                      _GraphMode.arc => _buildArcView(
                          constraints, members, rels, egoId, kinshipMap),
                    };
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Web view
  // ---------------------------------------------------------------------------

  Widget _buildWebView(
    BoxConstraints constraints,
    List<Member> members,
    List<Relationship> rels,
    String? egoId,
    Map<String, KinshipResult> kinshipMap,
  ) {
    _webLayout.compute(
      members: members,
      rels: rels,
      egoId: egoId,
      kinshipMap: kinshipMap,
      width: constraints.maxWidth,
      height: constraints.maxHeight,
    );

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(320),
      minScale: 0.25,
      maxScale: 4.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (d) {
          final hit = _webLayout.hitTest(d.localPosition);
          if (hit != null) context.push('/members/$hit');
        },
        onLongPressStart: (d) =>
            _setEgo(d.localPosition, _webLayout.hitTest, members),
        child: CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: EgoWebPainter(
            layout: _webLayout,
            members: members,
            relationships: rels,
            kinshipMap: kinshipMap,
            egoId: egoId,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tree / generation-lane view
  // ---------------------------------------------------------------------------

  Widget _buildTreeView(
    BoxConstraints constraints,
    List<Member> members,
    List<Relationship> rels,
    String? egoId,
    Map<String, KinshipResult> kinshipMap,
  ) {
    _treeLayout.compute(members: members, rels: rels, egoId: egoId);

    final canvasW = _treeLayout.canvasWidth;
    final canvasH = _treeLayout.canvasHeight;
    final vpW = constraints.maxWidth;
    final vpH = constraints.maxHeight;

    // Fit the whole tree into view on first render (or after mode switch).
    if (!_treeTransformSet && canvasW > 0 && canvasH > 0) {
      _treeTransformSet = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _treeController.value = _fitMatrix(canvasW, canvasH, vpW, vpH);
        }
      });
    }

    return InteractiveViewer(
      transformationController: _treeController,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(80),
      minScale: 0.15,
      maxScale: 4.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (d) {
          final hit = _treeLayout.hitTest(d.localPosition);
          if (hit != null) context.push('/members/$hit');
        },
        onLongPressStart: (d) =>
            _setEgo(d.localPosition, _treeLayout.hitTest, members),
        child: CustomPaint(
          size: Size(canvasW, canvasH),
          painter: GenLanePainter(
            layout: _treeLayout,
            members: members,
            relationships: rels,
            kinshipMap: kinshipMap,
            egoId: egoId,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Arc diagram view
  // ---------------------------------------------------------------------------

  Widget _buildArcView(
    BoxConstraints constraints,
    List<Member> members,
    List<Relationship> rels,
    String? egoId,
    Map<String, KinshipResult> kinshipMap,
  ) {
    _arcLayout.compute(
      members: members,
      rels: rels,
      egoId: egoId,
      viewWidth: constraints.maxWidth,
      viewHeight: constraints.maxHeight,
    );

    // Canvas width = viewport width (no horizontal overflow).
    // Canvas height may exceed viewport — user pans vertically.
    final canvasH = _arcLayout.canvasHeight;

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.symmetric(horizontal: 0, vertical: 80),
      minScale: 0.3,
      maxScale: 4.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (d) {
          final hit = _arcLayout.hitTest(d.localPosition);
          if (hit != null) context.push('/members/$hit');
        },
        onLongPressStart: (d) =>
            _setEgo(d.localPosition, _arcLayout.hitTest, members),
        child: CustomPaint(
          size: Size(constraints.maxWidth, canvasH),
          painter: ArcDiagramPainter(
            layout: _arcLayout,
            members: members,
            relationships: rels,
            kinshipMap: kinshipMap,
            egoId: egoId,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  /// Returns a Matrix4 that scales and centres [contentW × contentH]
  /// to fit inside [vpW × vpH] at 90% of available space.
  static Matrix4 _fitMatrix(
      double contentW, double contentH, double vpW, double vpH) {
    final scale =
        math.min(vpW / contentW, vpH / contentH).clamp(0.1, 1.0) * 0.90;
    final tx = (vpW - contentW * scale) / 2;
    final ty = (vpH - contentH * scale) / 2;
    // viewport = Translate(tx,ty) * Scale(s,s) * scene
    return Matrix4.identity()
      ..translate(tx, ty, 0.0)
      ..scale(scale, scale, 1.0);
  }

  void _setEgo(Offset pos, String? Function(Offset) hitTest,
      List<Member> members) {
    final hit = hitTest(pos);
    if (hit == null) return;
    ref.read(egoPerspectiveIdProvider.notifier).state = hit;
    final m = members.firstWhere((m) => m.id == hit);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Perspective \u2192 ${m.displayName}'),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

// ---------------------------------------------------------------------------
// Mode bar
// ---------------------------------------------------------------------------

class _ModeBar extends StatelessWidget {
  const _ModeBar({required this.mode, required this.onChanged});

  final _GraphMode mode;
  final ValueChanged<_GraphMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SilatSpacing.md, vertical: SilatSpacing.xs + 2),
      color: SilatColors.bg0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ModeChip(
            icon: Icons.radar,
            label: 'web',
            selected: mode == _GraphMode.web,
            onTap: () => onChanged(_GraphMode.web),
          ),
          const SizedBox(width: SilatSpacing.sm),
          _ModeChip(
            icon: Icons.account_tree_outlined,
            label: 'tree',
            selected: mode == _GraphMode.tree,
            onTap: () => onChanged(_GraphMode.tree),
          ),
          const SizedBox(width: SilatSpacing.sm),
          _ModeChip(
            icon: Icons.show_chart,
            label: 'arc',
            selected: mode == _GraphMode.arc,
            onTap: () => onChanged(_GraphMode.arc),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? SilatColors.terracotta : SilatColors.fg3;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: SilatSpacing.md, vertical: SilatSpacing.xs),
        decoration: BoxDecoration(
          color: selected
              ? SilatColors.terracotta.withOpacity(0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(SilatRadius.pill),
          border: Border.all(
            color: selected
                ? SilatColors.terracotta.withOpacity(0.35)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: SilatTypography.label(color: color)
                    .copyWith(letterSpacing: 0.8)),
          ],
        ),
      ),
    );
  }
}
