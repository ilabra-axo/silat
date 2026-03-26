// Arc diagram visualization.
// All members on a horizontal baseline ordered by generation (oldest left).
// Partner bonds arch above the line; parent-child bonds arch below.
// Arc height scales with span, capped to keep the diagram compact.
// Scroll horizontally for large families.

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

  static const _nodeSpacing = 72.0;
  static const _paddingH = 52.0;

  void compute({
    required List<Member> members,
    required List<Relationship> rels,
    required String? egoId,
    required double viewHeight,
  }) {
    _nodes = [];
    if (members.isEmpty) return;

    final anchorId = egoId ?? members.first.id;
    final gens = GenLaneLayout.assignGenerations(anchorId, members, rels);

    // Sort: oldest generation first, then group siblings (same parents) together
    final sorted = List<Member>.from(members);
    sorted.sort((a, b) {
      final ga = gens[a.id] ?? 0;
      final gb = gens[b.id] ?? 0;
      if (ga != gb) return ga.compareTo(gb);
      return a.id.compareTo(b.id); // stable secondary sort
    });

    canvasWidth = sorted.length * _nodeSpacing + _paddingH * 2;
    final baseline = viewHeight * 0.52;

    for (int i = 0; i < sorted.length; i++) {
      final x = _paddingH + i * _nodeSpacing;
      _nodes.add(_ArcNode(sorted[i].id, Offset(x, baseline)));
    }
  }

  String? hitTest(Offset pos, {double radius = 18}) {
    for (final n in _nodes) {
      if ((n.pos - pos).distance <= radius) return n.id;
    }
    return null;
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

  // Maximum arc height above / below the baseline (px)
  static const _maxArcHeight = 96.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (layout._nodes.isEmpty) return;
    _drawBaseline(canvas, size);
    _drawArcs(canvas);
    _drawNodes(canvas);
  }

  void _drawBaseline(Canvas canvas, Size size) {
    if (layout._nodes.isEmpty) return;
    final y = layout._nodes.first.pos.dy;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = SilatColors.bg3.withOpacity(0.35)
        ..strokeWidth = 0.5,
    );
  }

  void _drawArcs(Canvas canvas) {
    final posById = {for (final n in layout._nodes) n.id: n.pos};

    for (final rel in relationships) {
      final sp = posById[rel.sourceId];
      final tp = posById[rel.targetId];
      if (sp == null || tp == null) continue;

      final isPartner = rel.relType == RelType.partner;
      final paint = Paint()
        ..color = (isPartner ? SilatColors.slate : SilatColors.terracotta)
            .withOpacity(isPartner ? 0.38 : 0.30)
        ..strokeWidth = isPartner ? 1.0 : 1.1
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final x1 = math.min(sp.dx, tp.dx);
      final x2 = math.max(sp.dx, tp.dx);
      final baseline = sp.dy; // all nodes share the same y
      final span = x2 - x1;
      // Arc height: half the span, capped to keep it readable
      final arcH = math.min(span * 0.45, _maxArcHeight);

      // Partners arch above, parent-child arch below
      final above = isPartner;
      final cy = above ? baseline - arcH : baseline + arcH;

      final path = Path()
        ..moveTo(x1, baseline)
        ..cubicTo(x1, cy, x2, cy, x2, baseline);

      if (isPartner) {
        _drawDashedPath(canvas, path, paint);
      } else {
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawNodes(Canvas canvas) {
    final memberById = {for (final m in members) m.id: m};

    for (final node in layout._nodes) {
      final member = memberById[node.id];
      if (member == null) continue;

      final isEgo = node.id == egoId;
      final color = isEgo ? SilatColors.gen0 : _genderColor(member.gender);
      const r = 11.0;
      final pos = node.pos;

      canvas.drawCircle(
          pos, r, Paint()..color = color.withOpacity(isEgo ? 0.22 : 0.12));
      canvas.drawCircle(
          pos,
          r,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = isEgo ? 2.0 : 1.0);

      _drawText(canvas, member.initials, pos,
          fontSize: 7.5, color: color, bold: true);

      // Kinship / "you" label sits above the baseline (above-arc space)
      final kLabel = isEgo ? 'you' : (kinshipMap[node.id]?.displayLabel ?? '');
      if (kLabel.isNotEmpty) {
        _drawText(canvas, kLabel, Offset(pos.dx, pos.dy - r - 8),
            fontSize: 7.5,
            color: isEgo ? SilatColors.gen0 : SilatColors.fg3);
      }

      // Name label below — rotated −45° to pack horizontally
      _drawRotatedLabel(canvas, member.displayName,
          Offset(pos.dx, pos.dy + r + 4));
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

  void _drawText(Canvas canvas, String text, Offset center,
      {required double fontSize, required Color color, bool bold = false}) {
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
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawRotatedLabel(Canvas canvas, String text, Offset anchor) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 8.0,
          color: SilatColors.fg2,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(anchor.dx, anchor.dy);
    canvas.rotate(-math.pi / 4);
    tp.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(ArcDiagramPainter oldDelegate) => true;
}
