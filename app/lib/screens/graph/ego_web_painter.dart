// Concentric ego-web visualization.
// Ego sits at centre. Kinship degree determines ring — closer kin on inner rings.
// Ring guides make relational distance immediately legible.
// Tap to navigate; long-press to re-centre on any node.

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/silat_theme.dart';
import '../../models/member.dart';
import '../../models/relationship.dart';
import '../../models/kinship.dart';

// ---------------------------------------------------------------------------
// Layout
// ---------------------------------------------------------------------------

class _WebNode {
  final String id;
  final Offset pos;
  final int degree; // 0 = ego
  _WebNode(this.id, this.pos, this.degree);
}

class EgoWebLayout {
  List<_WebNode> _nodes = [];

  // Ring radii indexed by degree (0 = ego at centre)
  static const _radii = [0.0, 88.0, 162.0, 228.0, 288.0];

  void compute({
    required List<Member> members,
    required List<Relationship> rels,
    required String? egoId,
    required Map<String, KinshipResult> kinshipMap,
    required double width,
    required double height,
  }) {
    _nodes = [];
    if (egoId == null || members.isEmpty) return;

    final cx = width / 2;
    final cy = height / 2;

    _nodes.add(_WebNode(egoId, Offset(cx, cy), 0));

    // Bucket all other members by kinship degree (capped at ring 4)
    final byDegree = <int, List<String>>{};
    for (final m in members) {
      if (m.id == egoId) continue;
      final deg = (kinshipMap[m.id]?.degree ?? 99).clamp(1, 4);
      byDegree.putIfAbsent(deg, () => []).add(m.id);
    }

    for (final entry in byDegree.entries) {
      final ring = entry.key;
      final ids = List<String>.from(entry.value);
      final r = _radii[ring];

      // Sort so similar kinship labels cluster together on the ring
      ids.sort((a, b) => _ringSort(kinshipMap[a]?.label)
          .compareTo(_ringSort(kinshipMap[b]?.label)));

      final count = ids.length;
      for (int i = 0; i < count; i++) {
        final angle = -math.pi / 2 + 2 * math.pi * i / count;
        _nodes.add(_WebNode(
          ids[i],
          Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
          ring,
        ));
      }
    }
  }

  String? hitTest(Offset pos, {double radius = 22}) {
    for (final n in _nodes) {
      if ((n.pos - pos).distance <= radius) return n.id;
    }
    return null;
  }

  static int _ringSort(KinshipLabel? label) => switch (label) {
        KinshipLabel.partner => 0,
        KinshipLabel.parent => 10,
        KinshipLabel.child => 20,
        KinshipLabel.sibling => 30,
        KinshipLabel.grandparent => 40,
        KinshipLabel.grandchild => 50,
        KinshipLabel.parentInLaw => 60,
        KinshipLabel.siblingInLaw => 70,
        KinshipLabel.aunt => 80,
        KinshipLabel.uncle => 80,
        KinshipLabel.niece => 90,
        KinshipLabel.nephew => 90,
        KinshipLabel.greatGrandparent => 100,
        KinshipLabel.firstCousin => 110,
        KinshipLabel.stepparent => 120,
        KinshipLabel.stepchild => 130,
        KinshipLabel.secondCousin => 140,
        _ => 200,
      };
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class EgoWebPainter extends CustomPainter {
  EgoWebPainter({
    required this.layout,
    required this.members,
    required this.relationships,
    required this.kinshipMap,
    required this.egoId,
  });

  final EgoWebLayout layout;
  final List<Member> members;
  final List<Relationship> relationships;
  final Map<String, KinshipResult> kinshipMap;
  final String? egoId;

  @override
  void paint(Canvas canvas, Size size) {
    if (layout._nodes.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    _drawRingGuides(canvas, center);
    _drawEdges(canvas, center);
    _drawNodes(canvas);
  }

  void _drawRingGuides(Canvas canvas, Offset center) {
    final ringPaint = Paint()
      ..color = SilatColors.bg3.withOpacity(0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const ringLabels = ['', '1st', '2nd', '3rd', '4th+'];
    for (int ring = 1; ring <= 4; ring++) {
      final r = EgoWebLayout._radii[ring];
      canvas.drawCircle(center, r, ringPaint);
      _drawText(
        canvas,
        ringLabels[ring],
        Offset(center.dx + r - 2, center.dy - 7),
        fontSize: 7.5,
        color: SilatColors.fg3,
        alignLeft: true,
      );
    }
  }

  void _drawEdges(Canvas canvas, Offset center) {
    final nodeById = {for (final n in layout._nodes) n.id: n};

    for (final rel in relationships) {
      final src = nodeById[rel.sourceId];
      final tgt = nodeById[rel.targetId];
      if (src == null || tgt == null) continue;

      final isPartner = rel.relType == RelType.partner;
      final edgeColor = isPartner ? SilatColors.slate : SilatColors.terracotta;
      final paint = Paint()
        ..color = edgeColor.withOpacity(isPartner ? 0.28 : 0.22)
        ..strokeWidth = isPartner ? 0.9 : 1.1
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Control point: slightly toward centre for parent-child (concave),
      // slightly away for partner (convex) — gives a subtle organic curve.
      final ctrl = _bezierControl(src.pos, tgt.pos, center, push: isPartner);
      final path = Path()
        ..moveTo(src.pos.dx, src.pos.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, tgt.pos.dx, tgt.pos.dy);

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
      final r = isEgo ? 22.0 : (node.degree == 1 ? 16.0 : 13.0);
      final pos = node.pos;

      canvas.drawCircle(
          pos, r, Paint()..color = color.withOpacity(isEgo ? 0.18 : 0.10));
      canvas.drawCircle(
          pos,
          r,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = isEgo ? 2.0 : 1.1);

      _drawText(canvas, member.initials, pos,
          fontSize: isEgo ? 10 : 8, color: color, bold: true);
      _drawText(canvas, member.displayName, Offset(pos.dx, pos.dy + r + 9),
          fontSize: 9, color: SilatColors.fg1);

      final kinshipLabel = isEgo
          ? 'you'
          : (kinshipMap[node.id]?.displayLabel ?? '');
      if (kinshipLabel.isNotEmpty) {
        _drawText(canvas, kinshipLabel, Offset(pos.dx, pos.dy + r + 19),
            fontSize: 8,
            color: isEgo ? SilatColors.gen0 : SilatColors.fg3);
      }
    }
  }

  static Color _genderColor(Gender g) => switch (g) {
        Gender.male => SilatColors.genderM,
        Gender.female => SilatColors.genderF,
        _ => SilatColors.genderX,
      };

  static Offset _bezierControl(
      Offset src, Offset tgt, Offset center, {required bool push}) {
    final mid = Offset((src.dx + tgt.dx) / 2, (src.dy + tgt.dy) / 2);
    // push = true → bow outward (away from centre); false → bow inward
    final factor = push ? -0.20 : 0.12;
    return Offset(
      mid.dx + (center.dx - mid.dx) * factor,
      mid.dy + (center.dy - mid.dy) * factor,
    );
  }

  static void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLen = 5.0;
    const gapLen = 3.5;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      bool drawing = true;
      while (dist < metric.length) {
        final segEnd =
            math.min(dist + (drawing ? dashLen : gapLen), metric.length);
        if (drawing) {
          canvas.drawPath(metric.extractPath(dist, segEnd), paint);
        }
        dist = segEnd;
        drawing = !drawing;
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset center,
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
    tp.paint(canvas, center - Offset(dx, tp.height / 2));
  }

  @override
  bool shouldRepaint(EgoWebPainter oldDelegate) => true;
}
