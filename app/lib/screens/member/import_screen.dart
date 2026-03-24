// CSV Import Screen
// Accepts the silat-import-template.csv format.
// Shows a results sheet with counts + any row errors.

import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/silat_theme.dart';
import '../../providers/providers.dart';
import '../../services/csv_import_service.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _loading = false;
  String? _fileName;

  Future<void> _pickAndImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    setState(() {
      _loading = true;
      _fileName = file.name;
    });

    final content = utf8.decode(bytes);
    final store = ref.read(eventStoreProvider);
    final user = ref.read(currentUserProvider)!;
    final service = CsvImportService(store);

    final importResult = await service.importCsv(
      csvContent: content,
      actorId: user.id,
    );

    setState(() => _loading = false);

    if (mounted) _showResults(importResult);
  }

  void _showResults(ImportResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: result.hasErrors ? 0.7 : 0.4,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(SilatSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: SilatSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? SilatColors.bg3 : SilatColors.lbg3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text('import complete', style: SilatTypography.title(dark: isDark)),
              const SizedBox(height: SilatSpacing.lg),

              // Stats row
              Row(
                children: [
                  _Stat(
                    value: '${result.membersAdded}',
                    label: 'members\nadded',
                    color: SilatColors.success,
                    isDark: isDark,
                  ),
                  const SizedBox(width: SilatSpacing.md),
                  _Stat(
                    value: '${result.relationshipsAdded}',
                    label: 'connections\nadded',
                    color: SilatColors.slate,
                    isDark: isDark,
                  ),
                  const SizedBox(width: SilatSpacing.md),
                  _Stat(
                    value: '${result.rowsFailed}',
                    label: 'rows\nfailed',
                    color: result.hasErrors
                        ? SilatColors.error
                        : SilatColors.fg3,
                    isDark: isDark,
                  ),
                ],
              ),

              // Error list
              if (result.hasErrors) ...[
                const SizedBox(height: SilatSpacing.lg),
                Text(
                  'errors',
                  style: SilatTypography.label(
                      dark: isDark, color: SilatColors.terracotta)
                      .copyWith(letterSpacing: 1.5),
                ),
                const SizedBox(height: SilatSpacing.sm),
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    itemCount: result.errors.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: SilatSpacing.sm),
                      child: Text(
                        result.errors[i],
                        style: SilatTypography.label(
                            dark: isDark, color: SilatColors.error),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: SilatSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/home');
                  },
                  child: const Text('view family'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('import csv')),
      body: Padding(
        padding: const EdgeInsets.all(SilatSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Format description
            _Section(
              title: 'format',
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Use the silat CSV template. Each row is one member '
                    'or one additional relationship for an existing member.',
                    style: SilatTypography.body(dark: isDark),
                  ),
                  const SizedBox(height: SilatSpacing.md),
                  _CodeBlock(
                    code: 'id, first_name, last_name, birth_year,\n'
                        'death_year, gender, location_label,\n'
                        'latitude, longitude, notes,\n'
                        'rel_type, rel_target_id',
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: SilatSpacing.lg),

            _Section(
              title: 'rules',
              isDark: isDark,
              child: Column(
                children: [
                  _Rule('Lines beginning with # are comments — ignored.',
                      isDark),
                  _Rule(
                      'Repeat a member\'s id to add more relationships '
                      '(member data only read from first row).',
                      isDark),
                  _Rule(
                      'rel_type values: parent-child | partner', isDark),
                  _Rule(
                      'Target member must appear before source in the file.',
                      isDark),
                ],
              ),
            ),

            const Spacer(),

            // Selected file indicator
            if (_fileName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: SilatSpacing.md),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined,
                        size: 16, color: SilatColors.slate),
                    const SizedBox(width: SilatSpacing.sm),
                    Expanded(
                      child: Text(
                        _fileName!,
                        style: SilatTypography.label(
                            dark: isDark, color: SilatColors.slate),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _pickAndImport,
                icon: _loading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file_outlined, size: 18),
                label: Text(
                    _loading ? 'importing…' : 'choose csv file'),
              ),
            ),

            const SizedBox(height: SilatSpacing.sm),

            // Download template hint
            Text(
              'Use silat-import-template.csv as a starting point.',
              style: SilatTypography.label(dark: isDark),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(
      {required this.title, required this.child, required this.isDark});
  final String title;
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Column(
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

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code, required this.isDark});
  final String code;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(SilatSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? SilatColors.bg2 : SilatColors.lbg2,
          borderRadius: BorderRadius.circular(SilatRadius.md),
          border: Border.all(
              color: isDark ? SilatColors.bg3 : SilatColors.lbg3),
        ),
        child: Text(
          code,
          style: SilatTypography.mono(dark: isDark),
        ),
      );
}

class _Rule extends StatelessWidget {
  const _Rule(this.text, this.isDark);
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: SilatSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5, right: SilatSpacing.sm),
              child: Container(
                width: 4, height: 4,
                decoration: const BoxDecoration(
                  color: SilatColors.terracotta,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: Text(text,
                  style: SilatTypography.body(dark: isDark)
                      .copyWith(fontSize: 13)),
            ),
          ],
        ),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(SilatSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? SilatColors.bg2 : SilatColors.lbg2,
            borderRadius: BorderRadius.circular(SilatRadius.md),
            border: Border.all(
                color: isDark ? SilatColors.bg3 : SilatColors.lbg3),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: SilatTypography.display(
                    dark: isDark, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: SilatTypography.label(dark: isDark),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}
