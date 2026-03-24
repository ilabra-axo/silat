import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/silat_theme.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: _AuthInitializer()));
}

// Initialise auth before rendering the app — prevents redirect flicker.
class _AuthInitializer extends ConsumerStatefulWidget {
  const _AuthInitializer();

  @override
  ConsumerState<_AuthInitializer> createState() => _AuthInitializerState();
}

class _AuthInitializerState extends ConsumerState<_AuthInitializer> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final auth = ref.read(authServiceProvider);
    await auth.initialize();
    if (auth.currentUser != null) {
      ref.read(currentUserProvider.notifier).state = auth.currentUser;
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: SilatColors.bg0,
          body: Center(
            child: CircularProgressIndicator(color: SilatColors.terracotta),
          ),
        ),
      );
    }
    return const SilatApp();
  }
}

class SilatApp extends ConsumerWidget {
  const SilatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'silat ar rahim',
      debugShowCheckedModeBanner: false,
      theme: silatLight(),
      darkTheme: silatDark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
