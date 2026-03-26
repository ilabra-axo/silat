// Generation-lane visualization — modified Reingold-Tilford style.
// Members arranged in horizontal rows by generational distance from ego.
// Ego = generation 0. Parents = −1. Children = +1. Partners share generation.
// Elbow connectors for parent-child; dashed horizontals for partners.

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/silat_theme.dart';
import '../../models/member.dart';
import '../../models/relationship.dart';
import '../../models/kinship.dart';

// ---------------------------------------------------------------------------
// Layout
// ---------------------------------------------------------------------------

class _LaneNode {
  final String id;
  final Offset pos;
  final int gen;
  _LaneNode(this.id, this.pos, this.gen);
}

class GenLaneLayout {
  List<_LaneNode> _nodes = [];
  double canvasWidth = 0;
  double canvasHeight = 0;

  static const _nodeSpacingX = 84.0;
  static const _laneSpacingY = 110.0;
  static const _paddingH = 64.0;
  static const _paddingV = 56.0;

  void compute({
    required List<Member> members,
    required List<Relationship> rels,
    required String? egoId,
  }) {
    _nodes = [];
    if (members.isEmpty) return;

    final anchorId = egoId ?? members.first.id;
    final gens = assignGenerations(anchorId, members, rels);

    final byGen = <int, List<String>>{};
    for (final e in gens.entries) {
      byGen.putIfAbsent(e.value, () => []).add(e.key);
    }

    final minGen = byGen.keys.reduce(math.min);
    final maxGen = byGen.keys.reduce(math.max);
    final maxPerRow = byGen.values.map((l) => l.length).reduce(math.max);

    canvasWidth = math.max(maxPerRow * _nodeSpacingX + _paddingH * 2, 400.0);
    canvasHeight = (maxGen - minGen + 1) * _laneSpacingY + _paddingV * 2;

    // Place each generation, ordering members by parent x (for natural grouping)
    final xByMember = <String, double>{};
    for (int g = minGen; g <= maxGen; g++) {
      final ids = List<String>.from(byGen[g] ?? []);
      if (ids.isEmpty) continue;

      ids.sort((a, b) {
        final ax = _parentAnchorX(a, rels, xByMember, gens, g);
        final bx = _parentAnchorX(b, rels, xByMember, gens, g);
        if ((ax - bx).abs() < 0.01) return a.compareTo(b);
        return ax.compareTo(bx);
      });

      final totalW = (ids.length - 1) * _nodeSpacingX;
      final startX = (canvasWidth - totalW) / 2;
      for (int i = 0; i < ids.length; i++) {
        xByMember[ids[i]] = startX + i * _nodeSpacingX;
      }
    }

    for (final e in gens.entries) {
      final x = xByMember[e.key] ?? canvasWidth / 2;
      final y = _paddingV + (e.value - minGen) * _laneSpacingY;
      _nodes.add(_LaneNode(e.key, Offset(x, y), e.value));
    }
  }

  String? hitTest(Offset pos, {double radius = 22}) {
    for (final n in _nodes) {
      if ((n.pos - pos).distance <= radius) return n.id;
    }
    return null;
  }

  // Public so ArcLayout can reuse it.
  static Map<String, int> assignGenerations(
      String anchorId, List<Member> members, List<Relationship> rels) {
    final gens = <String, int>{anchorId: 0};
    final queue = [anchorId];

    while (queue.isNotEmpty) {
      final id = queue.removeAt(0);
      final g = gens[id]!;

      for (final rel in rels) {
        if (rel.relType == RelType.parentChild) {
          if (rel.targetId == id && !gens.containsKey(rel.sourceId)) {
            gens[rel.sourceId] = g - 1;
            queue.add(rel.sourceId);
          } else if (rel.sourceId == id && !gens.containsKey(rel.targetId)) {
            gens[rel.targetId] = g + 1;
            queue.add(rel.targetId);
          }
        } else if (rel.relType == RelType.partner) {
          final otherId = rel.sourceId == id ? rel.targetId : rel.sourceId;
          if (!gens.containsKey(otherId)) {
            gens[otherId] = g;
            queue.add(otherId);
          }
        }
      }
    }

    // Disconnected members fall into generation 0
    for (final m in members) {
      if (!gens.containsKey(m.id)) gens[m.id] = 0;
    }
    return gens;
  }

  static double _parentAnchorX(String id, List<Relationship> rels,
      Map<String, double> placed, Map<String, int> gens, int myGen) {
    final anchors = <double>[];
    for (final rel in rels) {
      if (rel.relType == RelType.parentChild && rel.targetId == id) {
        final px = placed[rel.sourceId];
        if (px != null) anchors.add(px);
      }
      if (rel.relType == RelType.partner) {
        final pid = rel.sourceId == id ? rel.targetId : rel.sourceId;
        final px = placed[pid];
        if (px != null && gens[pid] == myGen) anchors.add(px + 0.5);
      }
    }
    if (anchors.isEmpty) return double.maxFinite;
    return anchors.reduce((a, b) => a + b) / anchors.length;
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class GenLanePainter extends CustomPainter {
  GenLanePainter({
    required this.layout,
    required this.members,
    required this.relationships,
    required this.kinshipMap,
    required this.egoId,
  });

  final GenLaneLayout layout;
  final List<Member> members;
  final List<Relationship> relationships;
  final Map<String, KinshipResult> kinshipMap;
  final String? egoId;

  @override
  void paint(Canvas canvas, Size size) {
    if (layout._nodes.isEmpty) return;
    _drawLaneGuides(canvas, size);
    _drawEdges(canvas);
    _drawNodes(canvas);
  }

  void _drawLaneGuides(Canvas canvas, Size size) {
    final gens = layout._nodes.map((n) => n.gen).toSet();
    final minGen = gens.reduce(math.min);

    final linePaint = Paint()
      ..color = SilatColors.bg3.withOpacity(0.22)
      ..strokeWidth = 0.5;

    for (final g in gens) {
      final y = GenLaneLayout._paddingV +
          (g - minGen) * GenLaneLayout._laneSpacingY;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);

      final label = g == 0
          ? 'you'
          : g < 0
              ? 'gen ${-g}↑'
              : 'gen $g↓';
      _drawText(canvas, label, Offset(6, y - 9),
          fontSize: 8, color: SilatColors.fg3, alignLeft: true);
    }
  }

  void _drawEdges(Canvas canvas) {
    final nodeById = {for (final n in layout._nodes) n.id: n};

    for (final rel in relationships) {
      final src = nodeById[rel.sourceId];
      final tgt = nodeById[rel.targetId];
      if (src == null || tgt == null) continue;

      final isPartner = rel.relType == RelType.partner;
      final paint = Paint()
        ..color = (isPartner ? SilatColors.slate : SilatColors.terracotta)
            .withOpacity(isPartner ? 0.38 : 0.28)
        ..strokeWidth = isPartner ? 1.0 : 1.1
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (isPartner) {
        _drawDashedLine(canvas, src.pos, tgt.pos, paint);
      } else {
        // Elbow: vertical from parent, horizontal jog, vertical to child
        final midY = (src.pos.dy + tgt.pos.dy) / 2;
        final path = Path()
          ..moveTo(src.pos.dx, src.pos.dy)
          ..lineTo(src.pos.dx, midY)
          ..lineTo(tgt.pos.dx, midY)
          ..lineTo(tgt.pos.dx, tgt.pos.dy);
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
      const r = 16.0;
      final pos = node.pos;

      canvas.drawCircle(
          pos, r, Paint()..color = color.withOpacity(isEgo ? 0.20 : 0.11));
      canvas.drawCircle(
          pos,
          r,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = isEgo ? 2.0 : 1.2);

      _drawText(canvas, member.initials, pos,
          fontSize: 9, color: color, bold: true);
      _drawText(canvas, member.displayName, Offset(pos.dx, pos.dy + r + 9),
          fontSize: 9, color: SilatColors.fg1);

      if (!isEgo) {
        final k = kinshipMap[node.id];
        if (k != null) {
          _drawText(canvas, k.displayLabel, Offset(pos.dx, pos.dy + r + 19),
              fontSize: 8, color: SilatColors.fg3);
        }
      } else {
        _drawText(canvas, 'you', Offset(pos.dx, pos.dy + r + 19),
            fontSize: 8, color: SilatColors.gen0);
      }
    }
  }

  static Color _genderColor(Gender g) => switch (g) {
        Gender.male => SilatColors.genderM,
        Gender.female => SilatColors.genderF,
        _ => SilatColors.genderX,
      };

  static void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dashLen = 5.0;
    const gapLen = 3.5;
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final d = math.sqrt(dx * dx + dy * dy);
    if (d == 0) return;
    final ux = dx / d;
    final uy = dy / d;
    double dist = 0;
    bool drawing = true;
    while (dist < d) {
      final segLen = drawing ? dashLen : gapLen;
      final end = math.min(dist + segLen, d);
      if (drawing) {
        canvas.drawLine(
          Offset(from.dx + ux * dist, from.dy + uy * dist),
          Offset(from.dx + ux * end, from.dy + uy * end),
          paint,
        );
      }
      dist = end;
      drawing = !drawing;
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
  bool shouldRepaint(GenLanePainter oldDelegate) => true;
}
