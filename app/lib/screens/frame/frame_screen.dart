// Frame Screen — Brilliant Labs Frame glasses controller.
// Phone-side mirror + BLE connection management.
// Renders: member name + kinship label at 8fps over BLE.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/silat_theme.dart';
import '../../providers/providers.dart';

enum FrameState { disconnected, scanning, connecting, connected, error }

class FrameScreen extends ConsumerStatefulWidget {
  const FrameScreen({super.key});

  @override
  ConsumerState<FrameScreen> createState() => _FrameScreenState();
}

class _FrameScreenState extends ConsumerState<FrameScreen> {
  FrameState _state = FrameState.disconnected;
  String? _errorMessage;

  // TODO(phase4): inject FrameService (same pattern as rabble frame_service.dart)

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final egoId = ref.watch(egoPerspectiveIdProvider);
    final membersAsync = ref.watch(membersProvider);

    final ego = egoId == null ? null :
        (membersAsync.value ?? []).where((m) => m.id == egoId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('frame')),
      body: Padding(
        padding: const EdgeInsets.all(SilatSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection status
            _ConnectionBanner(state: _state, error: _errorMessage),

            const SizedBox(height: SilatSpacing.lg),

            // Mirror preview — 640×400 aspect ratio
            _FrameMirror(
              state: _state,
              egoName: ego?.displayName,
              isDark: isDark,
            ),

            const SizedBox(height: SilatSpacing.lg),

            // Perspective indicator
            _Section(
              title: 'perspective',
              isDark: isDark,
              child: ego == null
                  ? Text(
                      'No perspective set. Long-press a member to set.',
                      style: SilatTypography.body(dark: isDark),
                    )
                  : Text(
                      ego.displayName,
                      style: SilatTypography.title(dark: isDark),
                    ),
            ),

            const SizedBox(height: SilatSpacing.lg),

            // Connect / disconnect
            SizedBox(
              width: double.infinity,
              child: _state == FrameState.connected
                  ? OutlinedButton(
                      onPressed: _disconnect,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SilatColors.error,
                        side: BorderSide(color: SilatColors.error),
                      ),
                      child: const Text('disconnect frame'),
                    )
                  : FilledButton.icon(
                      onPressed: _state == FrameState.scanning ||
                              _state == FrameState.connecting
                          ? null
                          : _connect,
                      icon: const Icon(Icons.bluetooth_outlined, size: 18),
                      label: Text(
                        _state == FrameState.scanning
                            ? 'scanning…'
                            : _state == FrameState.connecting
                                ? 'connecting…'
                                : 'connect frame glasses',
                      ),
                    ),
            ),

            const Spacer(),

            // Phase note
            Container(
              padding: const EdgeInsets.all(SilatSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? SilatColors.bg2 : SilatColors.lbg2,
                borderRadius: BorderRadius.circular(SilatRadius.md),
                border: Border.all(
                    color: isDark ? SilatColors.bg3 : SilatColors.lbg3),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: SilatColors.slate),
                  const SizedBox(width: SilatSpacing.sm),
                  Expanded(
                    child: Text(
                      'Frame support is Phase 4. BLE rendering will show '
                      'member name + kinship label at ~8fps.',
                      style: SilatTypography.label(
                          dark: isDark, color: SilatColors.fg2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _connect() {
    setState(() => _state = FrameState.scanning);
    // TODO(phase4): FrameService.connect()
  }

  void _disconnect() {
    setState(() => _state = FrameState.disconnected);
    // TODO(phase4): FrameService.disconnect()
  }
}

class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner({required this.state, this.error});
  final FrameState state;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      FrameState.disconnected => ('disconnected', SilatColors.fg3),
      FrameState.scanning => ('scanning for frame…', SilatColors.slate),
      FrameState.connecting => ('connecting…', SilatColors.warning),
      FrameState.connected => ('frame connected', SilatColors.success),
      FrameState.error => (error ?? 'error', SilatColors.error),
    };

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: SilatSpacing.sm),
        Text(label,
            style: SilatTypography.label(dark: true, color: color)),
      ],
    );
  }
}

class _FrameMirror extends StatelessWidget {
  const _FrameMirror({
    required this.state,
    required this.egoName,
    required this.isDark,
  });

  final FrameState state;
  final String? egoName;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Frame display: 640×400 → 8:5 ratio
    return AspectRatio(
      aspectRatio: 640 / 400,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(SilatRadius.md),
          border: Border.all(
            color: state == FrameState.connected
                ? SilatColors.success
                : SilatColors.bg3,
          ),
        ),
        child: state == FrameState.connected
            ? _FrameCanvas(egoName: egoName)
            : Center(
                child: Text(
                  'frame display',
                  style: SilatTypography.label(
                      dark: true, color: SilatColors.fg3),
                ),
              ),
      ),
    );
  }
}

// Simulates what the Frame OLED shows — monospace text on black
class _FrameCanvas extends StatelessWidget {
  const _FrameCanvas({required this.egoName});
  final String? egoName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SilatSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[ silat ]',
            style: SilatTypography.mono(
                dark: true, color: SilatColors.terracotta),
          ),
          if (egoName != null) ...[
            const SizedBox(height: 4),
            Text(
              egoName!,
              style: SilatTypography.mono(dark: true, color: SilatColors.fg1),
            ),
          ],
          const Spacer(),
          Text(
            '~~ scan badge to identify ~~',
            style: SilatTypography.mono(
                dark: true, color: SilatColors.fg3),
          ),
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
  });

  final String title;
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: SilatTypography.label(
              dark: isDark, color: SilatColors.terracotta)
              .copyWith(letterSpacing: 1.5),
        ),
        const SizedBox(height: SilatSpacing.sm),
        child,
      ],
    );
  }
}
