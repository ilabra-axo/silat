import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/silat_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    int tabIndex() {
      if (location.startsWith('/ar')) return 1;
      if (location.startsWith('/frame')) return 2;
      return 0;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 1),
          BottomNavigationBar(
            currentIndex: tabIndex(),
            onTap: (i) {
              switch (i) {
                case 0: context.go('/home');
                case 1: context.go('/ar');
                case 2: context.go('/frame');
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'family',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner_outlined),
                activeIcon: Icon(Icons.qr_code_scanner),
                label: 'scan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.visibility_outlined),
                activeIcon: Icon(Icons.visibility),
                label: 'frame',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
