// AR Scan Screen — QR scanner that resolves a member and launches portrait overlay.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../theme/silat_theme.dart';
import '../../providers/providers.dart';

class ArScanScreen extends ConsumerStatefulWidget {
  const ArScanScreen({super.key});

  @override
  ConsumerState<ArScanScreen> createState() => _ArScanScreenState();
}

class _ArScanScreenState extends ConsumerState<ArScanScreen> {
  final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _processing = false;
  String? _error;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final raw = barcode!.rawValue!;

    // Expected format: silat://member/<id>
    if (!raw.startsWith('silat://member/')) {
      setState(() => _error = 'Not a silat badge');
      Future.delayed(const Duration(seconds: 2),
          () => mounted ? setState(() => _error = null) : null);
      return;
    }

    setState(() => _processing = true);

    final memberId = raw.replaceFirst('silat://member/', '');
    final members = ref.read(membersProvider).value ?? [];
    final found = members.where((m) => m.id == memberId).firstOrNull;

    if (found == null) {
      setState(() {
        _error = 'Member not in your tree';
        _processing = false;
      });
      Future.delayed(const Duration(seconds: 2),
          () => mounted ? setState(() => _error = null) : null);
      return;
    }

    await _scanner.stop();
    if (mounted) context.push('/ar/portrait/$memberId');
    setState(() => _processing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera feed
          MobileScanner(
            controller: _scanner,
            onDetect: _onDetect,
          ),

          // Viewfinder overlay
          _ScannerOverlay(),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SilatSpacing.md,
                vertical: SilatSpacing.sm,
              ),
              child: Row(
                children: [
                  Text(
                    'scan badge',
                    style: SilatTypography.title(dark: true),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.flash_on_outlined,
                        color: SilatColors.fg0),
                    onPressed: () => _scanner.toggleTorch(),
                  ),
                ],
              ),
            ),
          ),

          // Instruction / error text
          Positioned(
            bottom: 120,
            left: SilatSpacing.xl,
            right: SilatSpacing.xl,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _error != null
                  ? _StatusPill(
                      text: _error!,
                      color: SilatColors.error,
                      key: const ValueKey('error'),
                    )
                  : _processing
                      ? _StatusPill(
                          text: 'identifying…',
                          color: SilatColors.slate,
                          key: const ValueKey('processing'),
                        )
                      : _StatusPill(
                          text: 'point at a member\'s qr badge',
                          color: SilatColors.fg2,
                          key: const ValueKey('idle'),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

// Minimal viewfinder — four corner brackets only (Tufte: no chrome)
class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ViewfinderPainter(),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const side = 220.0;
    const corner = 24.0;
    const stroke = 2.5;

    final left = cx - side / 2;
    final right = cx + side / 2;
    final top = cy - side / 2;
    final bottom = cy + side / 2;

    // Dim overlay
    final dimPaint = Paint()..color = Colors.black54;
    final clearRect = Rect.fromLTWH(left, top, side, side);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), dimPaint);
    canvas.drawRect(clearRect,
        Paint()..blendMode = BlendMode.clear);

    // Corner brackets
    final bracketPaint = Paint()
      ..color = SilatColors.terracotta
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    void drawCorner(double x, double y, double dx, double dy) {
      final path = Path()
        ..moveTo(x + dx * corner, y)
        ..lineTo(x, y)
        ..lineTo(x, y + dy * corner);
      canvas.drawPath(path, bracketPaint);
    }

    drawCorner(left, top, 1, 1);
    drawCorner(right, top, -1, 1);
    drawCorner(left, bottom, 1, -1);
    drawCorner(right, bottom, -1, -1);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.text,
    required this.color,
    super.key,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SilatSpacing.md,
          vertical: SilatSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: SilatColors.bg0.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(SilatRadius.pill),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(text,
            style: SilatTypography.label(dark: true, color: color)),
      ),
    );
  }
}
