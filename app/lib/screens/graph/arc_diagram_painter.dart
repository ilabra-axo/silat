// Arc diagram — vertical orientation.
// Members placed on a centre vertical axis, sorted oldest generation (top) → youngest (bottom).
// Parent-child relationships arc to the LEFT.
// Partner relationships arc to the RIGHT.
// Canvas width = viewport width (no horizontal scroll).
// Canvas height scales with member count; users pan vertically.

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/silat_theme.dart';
import '../../models/member.dart';
import '../../models/relationship.dart';
import '../../models/kinship.dart';
import 'gen_lane_painter.dart' show GenLaneLayout;

// ---------------------------------------------------------------------------
// Layout
// ---------------------------------------------------------------------------

class _ArcNode {
  final String id;
  final Offset pos;
  _ArcNode(this.id, this.pos);
}

class ArcLayout {
  List<_ArcNode> _nodes = [];
  double canvasWidth = 0;
  double canvasHeight = 0;

  static const _nodeSpacing = 60.0; // vertical spacing between members
  static const _paddingV = 48.0;

  void compute({
    required List<Member> members,
    required List<Relationship> rels,
    required String? egoId,
    required double viewWidth,
    required double viewHeight,
  }) {
    _nodes = [];
    if (members.isEmpty) return;

    final anchorId = egoId ?? members.first.id;
    final gens = GenLaneLayout.assignGenerations(anchorId, members, rels);

    // Sort: oldest generation (most negative) at top, ego in middle, children below.
    // Within the same generation, sort partners adjacent to each other.
    final sorted = _sortMembers(members, rels, gens);

    // Scale spacing so the full family fits in roughly one screen height.
    // Floor at 40px so nodes don't collapse.
    final naturalH = sorted.length * _nodeSpacing;
    final scale = (viewHeight * 0.88 / naturalH).clamp(0.0, 1.0);
    final spacing = math.max(40.0, _nodeSpacing * scale);

    canvasWidth = viewWidth;
    canvasHeight = sorted.length * spacing + _paddingV * 2;

    final cx = viewWidth / 2;
    for (int i = 0; i < sorted.length; i++) {
      final y = _paddingV + i * spacing;
      _nodes.add(_ArcNode(sorted[i].id, Offset(cx, y)));
    }
  }

  String? hitTest(Offset pos, {double radius = 18}) {
    for (final n in _nodes) {
      if ((n.pos - pos).distance <= radius) return n.id;
    }
    return null;
  }

  // Sort members: by generation ascending (oldest ancestors first),
  // then group partners adjacent to each other within the same generation.
  static List<Member> _sortMembers(List<Member> members,
      List<Relationship> rels, Map<String, int> gens) {
    // Build partner pairs
    final partnerOf = <String, String>{};
    for (final rel in rels) {
      if (rel.relType == RelType.partner) {
        partnerOf[rel.sourceId] = rel.targetId;
        partnerOf[rel.targetId] = rel.sourceId;
      }
    }

    final sorted = List<Member>.from(members);
    sorted.sort((a, b) {
      final ga = gens[a.id] ?? 0;
      final gb = gens[b.id] ?? 0;
      if (ga != gb) return ga.compareTo(gb);
      // Same generation: keep partners adjacent by putting the
      // one with the lower-ID partner earlier.
      final pa = partnerOf[a.id];
      final pb = partnerOf[b.id];
      if (pa == b.id) return -1; // a is partner of b → keep a first
      if (pb == a.id) return 1;
      return a.id.compareTo(b.id);
    });
    return sorted;
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class ArcDiagramPainter extends CustomPainter {
  ArcDiagramPainter({
    required this.layout,
    required this.members,
    required this.relationships,
    required this.kinshipMap,
    required this.egoId,
  });

  final ArcLayout layout;
  final List<Member> members;
  final List<Relationship> relationships;
  final Map<String, KinshipResult> kinshipMap;
  final String? egoId;

  @override
  void paint(Canvas canvas, Size size) {
    if (layout._nodes.isEmpty) return;
    _drawCentreLine(canvas, size);
    _drawArcs(canvas, size);
    _drawNodes(canvas, size);
  }

  void _drawCentreLine(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      Paint()
        ..color = SilatColors.bg3.withOpacity(0.25)
        ..strokeWidth = 0.5,
    );
  }

  void _drawArcs(Canvas canvas, Size size) {
    final posById = {for (final n in layout._nodes) n.id: n.pos};
    // Left zone: parent-child arcs; right zone: partner arcs.
    final leftMax = size.width / 2 * 0.80;
    final rightMax = size.width / 2 * 0.72;

    for (final rel in relationships) {
      final sp = posById[rel.sourceId];
      final tp = posById[rel.targetId];
      if (sp == null || tp == null) continue;

      final isPartner = rel.relType == RelType.partner;
      final paint = Paint()
        ..color = (isPartner ? SilatColors.slate : SilatColors.terracotta)
            .withOpacity(isPartner ? 0.38 : 0.28)
        ..strokeWidth = isPartner ? 1.0 : 1.1
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final y1 = math.min(sp.dy, tp.dy);
      final y2 = math.max(sp.dy, tp.dy);
      final cx = sp.dx; // all nodes share the same x (centre line)

      final span = y2 - y1;
      // Arc bow proportional to span, capped
      final bow = isPartner
          ? math.min(span * 0.45, rightMax)
          : math.min(span * 0.45, leftMax);
      final sign = isPartner ? 1.0 : -1.0; // right vs left

      final path = Path()
        ..moveTo(cx, y1)
        ..cubicTo(cx + sign * bow, y1, cx + sign * bow, y2, cx, y2);

      if (isPartner) {
        _drawDashedPath(canvas, path, paint);
      } else {
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawNodes(Canvas canvas, Size size) {
    final memberById = {for (final m in members) m.id: m};

    for (final node in layout._nodes) {
      final member = memberById[node.id];
      if (member == null) continue;

      final isEgo = node.id == egoId;
      final color = isEgo ? SilatColors.gen0 : _genderColor(member.gender);
      final r = isEgo ? 14.0 : 11.0;
      final pos = node.pos;

      // Node circle
      canvas.drawCircle(
          pos, r, Paint()..color = color.withOpacity(isEgo ? 0.22 : 0.12));
      canvas.drawCircle(
          pos,
          r,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = isEgo ? 1.8 : 1.0);

      // Initials inside circle
      _drawText(canvas, member.initials, pos,
          fontSize: isEgo ? 8.5 : 7.0, color: color, bold: true);

      // Name to the right of the node (right side is partner-arc space,
      // but name text is short and fits in the gap between node and arcs)
      _drawText(canvas, member.displayName,
          Offset(pos.dx + r + 6, pos.dy - 5),
          fontSize: 9.5, color: SilatColors.fg1, alignLeft: true);

      // Kinship label below name, same x
      final kLabel = isEgo ? 'you' : (kinshipMap[node.id]?.displayLabel ?? '');
      if (kLabel.isNotEmpty) {
        _drawText(canvas, kLabel, Offset(pos.dx + r + 6, pos.dy + 6),
            fontSize: 8.0,
            color: isEgo ? SilatColors.gen0 : SilatColors.fg3,
            alignLeft: true);
      }
    }
  }

  static Color _genderColor(Gender g) => switch (g) {
        Gender.male => SilatColors.genderM,
        Gender.female => SilatColors.genderF,
        _ => SilatColors.genderX,
      };

  static void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLen = 5.0;
    const gapLen = 3.5;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      bool drawing = true;
      while (dist < metric.length) {
        final segEnd =
            math.min(dist + (drawing ? dashLen : gapLen), metric.length);
        if (drawing) canvas.drawPath(metric.extractPath(dist, segEnd), paint);
        dist = segEnd;
        drawing = !drawing;
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset origin,
      {required double fontSize,
      required Color color,
      bool bold = false,
      bool alignLeft = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = alignLeft ? 0.0 : tp.width / 2;
    tp.paint(canvas, origin - Offset(dx, tp.height / 2));
  }

  @override
  bool shouldRepaint(ArcDiagramPainter oldDelegate) => true;
}
