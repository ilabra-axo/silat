import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/silat_theme.dart';
import '../member/member_list_screen.dart';
import '../graph/graph_screen.dart';
import '../geo/geo_screen.dart';
import '../serendipity/serendipity_screen.dart';

class FamilyShell extends ConsumerWidget {
  const FamilyShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0, // suppress default title bar - each sub-screen has its own
          bottom: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.format_list_bulleted, size: 16), text: 'list'),
              Tab(icon: Icon(Icons.account_tree_outlined, size: 16), text: 'graph'),
              Tab(icon: Icon(Icons.map_outlined, size: 16), text: 'geo'),
              Tab(icon: Icon(Icons.grain_outlined, size: 16), text: 'reach'),
            ],
            labelStyle: SilatTypography.label(dark: isDark)
                .copyWith(letterSpacing: 1.2),
            labelColor: SilatColors.terracotta,
            unselectedLabelColor: SilatColors.fg3,
            indicatorColor: SilatColors.terracotta,
            indicatorSize: TabBarIndicatorSize.label,
            iconSize: 16,
          ),
        ),
        body: const TabBarView(
          children: [
            MemberListScreen(),
            GraphScreen(),
            GeoScreen(),
            SerendipityScreen(),
          ],
        ),
      ),
    );
  }
}
