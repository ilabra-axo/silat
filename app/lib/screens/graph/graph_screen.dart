// Force-directed kinship graph.
// Nodes = members, edges = relationships.
// Ego node is highlighted; kinship labels float below each node.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/silat_theme.dart';
import '../../providers/providers.dart';
import '../../models/member.dart';
import '../../models/relationship.dart';
import '../../models/kinship.dart';

class GraphScreen extends ConsumerStatefulWidget {
  const GraphScreen({super.key});

  @override
  ConsumerState<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends ConsumerState<GraphScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final _sim = _ForceSimulation();
  bool _settled = false;
  int _tickCount = 0;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addListener(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick() {
    if (_settled) return;
    _sim.tick();
    _tickCount++;
    if (_tickCount > 300) {
      _settled = true;
      _ticker.stop();
    }
    setState(() {});
  }

  void _resetSimulation(List<Member> members, List<Relationship> rels) {
    _sim.init(members, rels);
    _settled = false;
    _tickCount = 0;
    if (!_ticker.isAnimating) {
      _ticker.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersProvider);
    final relsAsync = ref.watch(relationshipsProvider);
    final egoId = ref.watch(egoPerspectiveIdProvider);
    final kinshipMap = ref.watch(kinshipMapProvider);

    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (members) => relsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (rels) {
          if (members.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hub_outlined, size: 48, color: SilatColors.fg3),
                  const SizedBox(height: SilatSpacing.md),
                  Text('no members yet',
                      style: SilatTypography.body()),
                ],
              ),
            );
          }

          // Re-init simulation when members/rels change
          if (_sim.nodeCount != members.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _resetSimulation(members, rels);
            });
          }

          return LayoutBuilder(builder: (context, constraints) {
            _sim.width = constraints.maxWidth;
            _sim.height = constraints.maxHeight;

            return GestureDetector(
              onTapUp: (details) {
                final hit = _sim.hitTest(details.localPosition);
                if (hit != null) {
                  context.push('/members/$hit');
                }
              },
              onLongPressStart: (details) {
                final hit = _sim.hitTest(details.localPosition);
                if (hit != null) {
                  ref.read(egoPerspectiveIdProvider.notifier).state = hit;
                  final m = members.firstWhere((m) => m.id == hit);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Perspective \u2192 ${m.displayName}'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(200),
                minScale: 0.3,
                maxScale: 4.0,
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _GraphPainter(
                    simulation: _sim,
                    members: members,
                    relationships: rels,
                    kinshipMap: kinshipMap,
                    egoId: egoId,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Force simulation
// ---------------------------------------------------------------------------

class _FNode {
  final String id;
  double x, y;
  double vx = 0, vy = 0;
  _FNode(this.id, this.x, this.y);
}

class _ForceSimulation {
  List<_FNode> nodes = [];
  List<(String, String)> _edges = [];
  double width = 400;
  double height = 600;

  static const _repulsion = 3500.0;
  static const _springLength = 100.0;
  static const _springK = 0.08;
  static const _gravity = 0.015;
  static const _damping = 0.82;

  int get nodeCount => nodes.length;

  void init(List<Member> members, List<Relationship> rels) {
    final rng = math.Random(42);
    final cx = width / 2;
    final cy = height / 2;
    final r = math.min(width, height) * 0.3;

    nodes = List.generate(members.length, (i) {
      final angle = 2 * math.pi * i / members.length;
      return _FNode(
        members[i].id,
        cx + r * math.cos(angle) + rng.nextDouble() * 10,
        cy + r * math.sin(angle) + rng.nextDouble() * 10,
      );
    });

    _edges = rels
        .map((r) => (r.sourceId, r.targetId))
        .where((e) =>
            nodes.any((n) => n.id == e.$1) &&
            nodes.any((n) => n.id == e.$2))
        .toList();
  }

  void tick() {
    if (nodes.isEmpty) return;
    final cx = width / 2;
    final cy = height / 2;

    // Repulsion
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final dx = nodes[j].x - nodes[i].x;
        final dy = nodes[j].y - nodes[i].y;
        final d2 = math.max(dx * dx + dy * dy, 1.0);
        final d = math.sqrt(d2);
        final f = _repulsion / d2;
        nodes[i].vx -= f * dx / d;
        nodes[i].vy -= f * dy / d;
        nodes[j].vx += f * dx / d;
        nodes[j].vy += f * dy / d;
      }
    }

    // Spring attraction
    for (final (srcId, tgtId) in _edges) {
      final src = nodeById(srcId);
      final tgt = nodeById(tgtId);
      if (src == null || tgt == null) continue;
      final dx = tgt.x - src.x;
      final dy = tgt.y - src.y;
      final d = math.max(math.sqrt(dx * dx + dy * dy), 0.1);
      final f = _springK * (d - _springLength);
      src.vx += f * dx / d;
      src.vy += f * dy / d;
      tgt.vx -= f * dx / d;
      tgt.vy -= f * dy / d;
    }

    // Center gravity + integrate
    for (final n in nodes) {
      n.vx += (cx - n.x) * _gravity;
      n.vy += (cy - n.y) * _gravity;
      n.vx *= _damping;
      n.vy *= _damping;
      n.x += n.vx;
      n.y += n.vy;
    }
  }

  _FNode? nodeById(String id) {
    for (final n in nodes) {
      if (n.id == id) return n;
    }
    return null;
  }

  String? hitTest(Offset pos, {double radius = 28}) {
    for (final n in nodes) {
      final dx = n.x - pos.dx;
      final dy = n.y - pos.dy;
      if (dx * dx + dy * dy <= radius * radius) return n.id;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class _GraphPainter extends CustomPainter {
  _GraphPainter({
    required this.simulation,
    required this.members,
    required this.relationships,
    required this.kinshipMap,
    this.egoId,
  });

  final _ForceSimulation simulation;
  final List<Member> members;
  final List<Relationship> relationships;
  final Map<String, KinshipResult> kinshipMap;
  final String? egoId;

  static Color _genderColor(Gender g) => switch (g) {
        Gender.male => SilatColors.genderM,
        Gender.female => SilatColors.genderF,
        _ => SilatColors.genderX,
      };

  @override
  void paint(Canvas canvas, Size size) {
    if (simulation.nodeCount == 0) return;

    final edgePaintParent = Paint()
      ..color = SilatColors.terracotta.withOpacity(0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final edgePaintPartner = Paint()
      ..color = SilatColors.slate.withOpacity(0.45)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Edges
    for (final rel in relationships) {
      final src = simulation.nodeById(rel.sourceId);
      final tgt = simulation.nodeById(rel.targetId);
      if (src == null || tgt == null) continue;
      final paint = rel.relType == RelType.partner
          ? edgePaintPartner
          : edgePaintParent;
      if (rel.relType == RelType.partner) {
        // Dashed line for partners
        _drawDashed(canvas, Offset(src.x, src.y), Offset(tgt.x, tgt.y), paint);
      } else {
        canvas.drawLine(Offset(src.x, src.y), Offset(tgt.x, tgt.y), paint);
        // Arrow for parent→child direction
        _drawArrow(canvas, Offset(src.x, src.y), Offset(tgt.x, tgt.y), paint);
      }
    }

    // Nodes
    for (final node in simulation.nodes) {
      final member = members.where((m) => m.id == node.id).firstOrNull;
      if (member == null) continue;
      final isEgo = node.id == egoId;
      final color = isEgo ? SilatColors.terracotta : _genderColor(member.gender);
      final nodeR = isEgo ? 22.0 : 16.0;
      final pos = Offset(node.x, node.y);

      // Fill
      canvas.drawCircle(pos, nodeR,
          Paint()..color = color.withOpacity(isEgo ? 0.25 : 0.15));

      // Border
      canvas.drawCircle(
          pos,
          nodeR,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = isEgo ? 2.5 : 1.5);

      // Initials
      _drawText(canvas, member.initials, pos,
          fontSize: isEgo ? 11 : 9,
          color: color,
          bold: true);

      // Name below
      _drawText(canvas, member.displayName,
          Offset(pos.dx, pos.dy + nodeR + 10),
          fontSize: 10, color: SilatColors.fg1);

      // Kinship label below name
      final kinship = kinshipMap[node.id];
      if (kinship != null) {
        final label = isEgo ? 'you' : kinship.displayLabel;
        _drawText(canvas, label,
            Offset(pos.dx, pos.dy + nodeR + 22),
            fontSize: 9,
            color: isEgo ? SilatColors.terracotta : SilatColors.slate);
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

  void _drawArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final d = math.sqrt(dx * dx + dy * dy);
    if (d < 20) return;
    final ux = dx / d;
    final uy = dy / d;
    // Arrow tip offset from target node edge
    const tip = 18.0;
    const arrowSize = 6.0;
    final ax = to.dx - ux * tip;
    final ay = to.dy - uy * tip;
    final arrowPaint = Paint()
      ..color = paint.color
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(ax, ay)
      ..lineTo(ax - arrowSize * ux + arrowSize * 0.5 * uy,
               ay - arrowSize * uy - arrowSize * 0.5 * ux)
      ..lineTo(ax - arrowSize * ux - arrowSize * 0.5 * uy,
               ay - arrowSize * uy + arrowSize * 0.5 * ux)
      ..close();
    canvas.drawPath(path, arrowPaint);
  }

  void _drawDashed(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dashLen = 6.0;
    const gapLen = 4.0;
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

  @override
  bool shouldRepaint(_GraphPainter old) => true;
}
