import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/silat_theme.dart';
import '../../providers/providers.dart';
import '../../services/seed_service.dart';
import '../../widgets/common/member_tile.dart';

class MemberListScreen extends ConsumerStatefulWidget {
  const MemberListScreen({super.key});

  @override
  ConsumerState<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends ConsumerState<MemberListScreen> {
  String _query = '';
  bool _fabOpen = false;
  bool _seeding = false;

  Future<void> _loadDemo() async {
    setState(() { _seeding = true; _fabOpen = false; });
    final store = ref.read(eventStoreProvider);
    await SeedService(store).loadBraunFamily();
    if (mounted) {
      setState(() => _seeding = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Demo family loaded — long-press a member to set perspective'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersProvider);
    final egoId = ref.watch(egoPerspectiveIdProvider);
    final kinshipMap = ref.watch(kinshipMapProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('silat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context, ref),
            tooltip: 'Settings',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              SilatSpacing.md, 0, SilatSpacing.md, SilatSpacing.sm,
            ),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'search members…',
                prefixIcon: Icon(Icons.search, size: 18),
                isDense: true,
              ),
              style: SilatTypography.body(),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          membersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (members) {
              final filtered = _query.isEmpty
                  ? members
                  : members
                      .where((m) =>
                          m.displayName.toLowerCase().contains(_query) ||
                          (m.notes?.toLowerCase().contains(_query) ?? false))
                      .toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline, size: 48, color: SilatColors.fg3),
                      const SizedBox(height: SilatSpacing.md),
                      Text(
                        members.isEmpty
                            ? 'No members yet.'
                            : 'No results for "$_query"',
                        style: SilatTypography.body(),
                        textAlign: TextAlign.center,
                      ),
                      if (members.isEmpty && kDebugMode) ...[
                        const SizedBox(height: SilatSpacing.lg),
                        OutlinedButton.icon(
                          onPressed: _seeding ? null : _loadDemo,
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: const Text('load demo family'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: SilatColors.slate,
                            side: const BorderSide(color: SilatColors.bg3),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: SilatColors.terracotta,
                onRefresh: () async => ref.invalidate(familyDataProvider),
                child: ListView.separated(
                padding: const EdgeInsets.only(
                  top: SilatSpacing.sm,
                  bottom: 100, // clearance for FAB
                ),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                itemBuilder: (_, i) {
                  final member = filtered[i];
                  final kinship = kinshipMap[member.id];
                  final isEgo = member.id == egoId;

                  return MemberTile(
                    member: member,
                    kinshipLabel: isEgo ? 'you' : kinship?.displayLabel,
                    isEgo: isEgo,
                    onTap: () => context.push('/members/${member.id}'),
                    onLongPress: () {
                      ref.read(egoPerspectiveIdProvider.notifier).state = member.id;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Perspective → ${member.displayName}'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                  );
                },
              ));  // close RefreshIndicator
            },
          ),

          // FAB backdrop dismiss
          if (_fabOpen)
            GestureDetector(
              onTap: () => setState(() => _fabOpen = false),
              child: Container(color: Colors.transparent),
            ),
        ],
      ),
      floatingActionButton: _buildFab(context, isDark),
    );
  }

  Widget _buildFab(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Mini action buttons — visible when open
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: _fabOpen
              ? Column(
                  key: const ValueKey('actions'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!bool.fromEnvironment('SILAT_PROD'))
                      _MiniFab(
                        label: 'load demo',
                        icon: Icons.auto_awesome,
                        color: SilatColors.slate,
                        onTap: _loadDemo,
                      ),
                    const SizedBox(height: SilatSpacing.sm),
                    _MiniFab(
                      label: 'import csv',
                      icon: Icons.upload_file_outlined,
                      color: SilatColors.slate,
                      onTap: () {
                        setState(() => _fabOpen = false);
                        context.push('/members/import');
                      },
                    ),
                    const SizedBox(height: SilatSpacing.sm),
                    _MiniFab(
                      label: 'link members',
                      icon: Icons.link,
                      color: SilatColors.slate,
                      onTap: () {
                        setState(() => _fabOpen = false);
                        context.push('/members/link');
                      },
                    ),
                    const SizedBox(height: SilatSpacing.sm),
                    _MiniFab(
                      label: 'add member',
                      icon: Icons.person_add_outlined,
                      color: SilatColors.terracotta,
                      onTap: () {
                        setState(() => _fabOpen = false);
                        context.push('/members/new');
                      },
                    ),
                    const SizedBox(height: SilatSpacing.md),
                  ],
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),

        // Main FAB
        FloatingActionButton(
          onPressed: () => setState(() => _fabOpen = !_fabOpen),
          backgroundColor: SilatColors.terracotta,
          foregroundColor: SilatColors.fg0,
          elevation: 0,
          child: AnimatedRotation(
            turns: _fabOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    final isDark = ref.read(themeModeProvider);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SilatSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('settings', style: SilatTypography.title()),
              const SizedBox(height: SilatSpacing.md),
              SwitchListTile(
                title: Text('dark mode', style: SilatTypography.body()),
                value: isDark,
                onChanged: (v) {
                  ref.read(themeModeProvider.notifier).state = v;
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text('sign out', style: SilatTypography.body()),
                onTap: () async {
                  await ref.read(authServiceProvider).signOut();
                  ref.read(currentUserProvider.notifier).state = null;
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniFab extends StatelessWidget {
  const _MiniFab({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SilatSpacing.md,
              vertical: SilatSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: SilatColors.bg1,
              borderRadius: BorderRadius.circular(SilatRadius.pill),
              border: Border.all(color: SilatColors.bg3),
            ),
            child: Text(label,
                style: SilatTypography.label(
                    dark: true, color: SilatColors.fg1)),
          ),
          const SizedBox(width: SilatSpacing.sm),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: SilatColors.fg0, size: 18),
          ),
        ],
      ),
    );
  }
}
