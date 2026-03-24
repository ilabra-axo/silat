// Link two members with a relationship type.
// Launched from member detail or via FAB on member list.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/silat_theme.dart';
import '../../providers/providers.dart';
import '../../models/relationship.dart';

class LinkMembersScreen extends ConsumerStatefulWidget {
  const LinkMembersScreen({super.key, this.prefillSourceId});
  final String? prefillSourceId;

  @override
  ConsumerState<LinkMembersScreen> createState() => _LinkMembersScreenState();
}

class _LinkMembersScreenState extends ConsumerState<LinkMembersScreen> {
  String? _sourceId;
  String? _targetId;
  RelType _relType = RelType.parentChild;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sourceId = widget.prefillSourceId;
  }

  Future<void> _save() async {
    if (_sourceId == null || _targetId == null) {
      setState(() => _error = 'Select both members');
      return;
    }
    if (_sourceId == _targetId) {
      setState(() => _error = 'Cannot link a member to themselves');
      return;
    }

    setState(() { _saving = true; _error = null; });
    final store = ref.read(eventStoreProvider);
    final user = ref.read(currentUserProvider)!;

    final result = await store.createRelationship(
      actorId: user.id,
      sourceId: _sourceId!,
      targetId: _targetId!,
      relType: _relType,
    );

    if (mounted) {
      if (result == null) {
        setState(() { _error = 'This connection already exists'; _saving = false; });
      } else {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('link members')),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (members) {
          final sorted = [...members]
            ..sort((a, b) => a.displayName.compareTo(b.displayName));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(SilatSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Relationship type
                _SectionLabel('type', isDark),
                const SizedBox(height: SilatSpacing.sm),
                Wrap(
                  spacing: SilatSpacing.sm,
                  children: RelType.values.map((t) => ChoiceChip(
                    label: Text(t.displayLabel),
                    selected: _relType == t,
                    onSelected: (_) => setState(() => _relType = t),
                  )).toList(),
                ),

                const SizedBox(height: SilatSpacing.lg),

                // Relationship type description
                Container(
                  padding: const EdgeInsets.all(SilatSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? SilatColors.bg2 : SilatColors.lbg2,
                    borderRadius: BorderRadius.circular(SilatRadius.md),
                  ),
                  child: Text(
                    _relType == RelType.parentChild
                        ? 'parent-child  ·  The first member is the parent of the second.'
                        : 'partner  ·  Both members are partners (symmetric).',
                    style: SilatTypography.label(dark: isDark),
                  ),
                ),

                const SizedBox(height: SilatSpacing.lg),

                // Source
                _SectionLabel(
                  _relType == RelType.parentChild ? 'parent' : 'first partner',
                  isDark,
                ),
                const SizedBox(height: SilatSpacing.sm),
                _MemberPicker(
                  members: sorted,
                  selectedId: _sourceId,
                  excludeId: _targetId,
                  isDark: isDark,
                  onSelected: (id) => setState(() => _sourceId = id),
                ),

                const SizedBox(height: SilatSpacing.lg),

                // Target
                _SectionLabel(
                  _relType == RelType.parentChild ? 'child' : 'second partner',
                  isDark,
                ),
                const SizedBox(height: SilatSpacing.sm),
                _MemberPicker(
                  members: sorted,
                  selectedId: _targetId,
                  excludeId: _sourceId,
                  isDark: isDark,
                  onSelected: (id) => setState(() => _targetId = id),
                ),

                const SizedBox(height: SilatSpacing.lg),

                if (_error != null) ...[
                  Text(_error!,
                      style: SilatTypography.label(
                          dark: isDark, color: SilatColors.error)),
                  const SizedBox(height: SilatSpacing.md),
                ],

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 16, width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('create connection'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.isDark);
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: SilatTypography.label(dark: isDark, color: SilatColors.terracotta)
            .copyWith(letterSpacing: 1.5),
      );
}

class _MemberPicker extends StatelessWidget {
  const _MemberPicker({
    required this.members,
    required this.selectedId,
    required this.excludeId,
    required this.isDark,
    required this.onSelected,
  });

  final List members;
  final String? selectedId;
  final String? excludeId;
  final bool isDark;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: isDark ? SilatColors.bg3 : SilatColors.lbg3),
        borderRadius: BorderRadius.circular(SilatRadius.md),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: selectedId,
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SilatSpacing.md),
            child: Text('select member',
                style: SilatTypography.body(
                    dark: isDark, color: SilatColors.fg2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: SilatSpacing.md),
          items: members
              .where((m) => m.id != excludeId)
              .map<DropdownMenuItem>((m) => DropdownMenuItem(
                    value: m.id as String,
                    child: Text(m.displayName as String,
                        style: SilatTypography.body(dark: isDark)),
                  ))
              .toList(),
          onChanged: (v) { if (v != null) onSelected(v as String); },
        ),
      ),
    );
  }
}
