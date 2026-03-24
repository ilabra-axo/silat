// Member form — create or edit a member.
// Sections: identity · dates · photo · residence · birth location

import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../theme/silat_theme.dart';
import '../../providers/providers.dart';
import '../../models/member.dart';

final _dateFmt = DateFormat('d MMM yyyy');

class MemberFormScreen extends ConsumerStatefulWidget {
  const MemberFormScreen({super.key, this.memberId});
  final String? memberId;

  @override
  ConsumerState<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends ConsumerState<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _notes;

  // Residence
  late final TextEditingController _residenceLabel;
  late final TextEditingController _residenceLat;
  late final TextEditingController _residenceLon;

  // Birth location
  late final TextEditingController _birthLabel;
  late final TextEditingController _birthLat;
  late final TextEditingController _birthLon;

  // Contact
  late final TextEditingController _phone;
  late final TextEditingController _whatsapp;

  Gender _gender = Gender.unspecified;
  DateTime? _birthDate;
  DateTime? _deathDate;
  String? _photoUrl;
  bool _isUrgent = false;
  bool _saving = false;
  Member? _existing;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController();
    _lastName = TextEditingController();
    _notes = TextEditingController();
    _residenceLabel = TextEditingController();
    _residenceLat = TextEditingController();
    _residenceLon = TextEditingController();
    _birthLabel = TextEditingController();
    _birthLat = TextEditingController();
    _birthLon = TextEditingController();
    _phone = TextEditingController();
    _whatsapp = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.memberId != null && _existing == null) {
      final members = ref.read(membersProvider).value;
      final found = members?.where((m) => m.id == widget.memberId).firstOrNull;
      if (found != null) {
        _existing = found;
        _firstName.text = found.firstName;
        _lastName.text = found.lastName ?? '';
        _notes.text = found.notes ?? '';
        _residenceLabel.text = found.locationLabel ?? '';
        _residenceLat.text = found.latitude?.toString() ?? '';
        _residenceLon.text = found.longitude?.toString() ?? '';
        _birthLabel.text = found.birthLocationLabel ?? '';
        _birthLat.text = found.birthLatitude?.toString() ?? '';
        _birthLon.text = found.birthLongitude?.toString() ?? '';
        _phone.text = found.phone ?? '';
        _whatsapp.text = found.whatsapp ?? '';
        _birthDate = found.birthDate;
        _deathDate = found.deathDate;
        _photoUrl = found.photoUrl;
        _isUrgent = found.isUrgent;
        setState(() => _gender = found.gender);
      }
    }
  }

  @override
  void dispose() {
    for (final c in [
      _firstName, _lastName, _notes,
      _residenceLabel, _residenceLat, _residenceLon,
      _birthLabel, _birthLat, _birthLon,
      _phone, _whatsapp,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime? current,
    required void Function(DateTime) onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(1950),
      firstDate: DateTime(1000),
      lastDate: DateTime.now(),
      helpText: '',
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.first.bytes;
    if (bytes == null) return;
    final ext = result.files.first.extension ?? 'jpg';
    final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
    setState(() {
      _photoUrl = 'data:$mime;base64,${base64Encode(bytes)}';
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final store = ref.read(eventStoreProvider);
    final user = ref.read(currentUserProvider)!;

    String? residenceLabel = _residenceLabel.text.trim().isEmpty
        ? null : _residenceLabel.text.trim();
    double? residenceLat = double.tryParse(_residenceLat.text);
    double? residenceLon = double.tryParse(_residenceLon.text);
    String? birthLabel = _birthLabel.text.trim().isEmpty
        ? null : _birthLabel.text.trim();
    double? birthLat = double.tryParse(_birthLat.text);
    double? birthLon = double.tryParse(_birthLon.text);
    String? notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();
    String? lastName = _lastName.text.trim().isEmpty
        ? null : _lastName.text.trim();
    String? phone = _phone.text.trim().isEmpty ? null : _phone.text.trim();
    String? whatsapp = _whatsapp.text.trim().isEmpty ? null : _whatsapp.text.trim();

    try {
      if (_existing == null) {
        final member = await store.addMember(
          actorId: user.id,
          firstName: _firstName.text.trim(),
          lastName: lastName,
          birthDate: _birthDate,
          deathDate: _deathDate,
          gender: _gender,
          locationLabel: residenceLabel,
          latitude: residenceLat,
          longitude: residenceLon,
          birthLocationLabel: birthLabel,
          birthLatitude: birthLat,
          birthLongitude: birthLon,
          notes: notes,
          photoUrl: _photoUrl,
          phone: phone,
          whatsapp: whatsapp,
          isUrgent: _isUrgent,
        );
        if (mounted) context.go('/members/${member.id}');
      } else {
        await store.updateMember(
          actorId: user.id,
          current: _existing!,
          firstName: _firstName.text.trim(),
          lastName: lastName,
          birthDate: _birthDate,
          deathDate: _deathDate,
          gender: _gender,
          locationLabel: residenceLabel,
          latitude: residenceLat,
          longitude: residenceLon,
          birthLocationLabel: birthLabel,
          birthLatitude: birthLat,
          birthLongitude: birthLon,
          notes: notes,
          photoUrl: _photoUrl,
          phone: phone,
          whatsapp: whatsapp,
          isUrgent: _isUrgent,
        );
        if (mounted) context.pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNew = widget.memberId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'add member' : 'edit member'),
        actions: [
          if (!isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
              tooltip: 'Delete',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SilatSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Photo ────────────────────────────────────────────────────
              Center(child: _PhotoPicker(
                photoUrl: _photoUrl,
                isDark: isDark,
                onPick: _pickPhoto,
                onRemove: () => setState(() => _photoUrl = null),
              )),
              const SizedBox(height: SilatSpacing.lg),

              // ── Identity ─────────────────────────────────────────────────
              _sectionLabel('identity', isDark),
              const SizedBox(height: SilatSpacing.sm),
              _field(controller: _firstName, label: 'first name *', isDark: isDark,
                  validator: (v) => v == null || v.trim().isEmpty ? 'required' : null),
              const SizedBox(height: SilatSpacing.md),
              _field(controller: _lastName, label: 'last name', isDark: isDark),
              const SizedBox(height: SilatSpacing.md),
              Text('gender', style: SilatTypography.label(dark: isDark)),
              const SizedBox(height: SilatSpacing.sm),
              Wrap(
                spacing: SilatSpacing.sm,
                children: Gender.values.map((g) => ChoiceChip(
                  label: Text(g.displayLabel),
                  selected: _gender == g,
                  onSelected: (_) => setState(() => _gender = g),
                )).toList(),
              ),
              const SizedBox(height: SilatSpacing.lg),

              // ── Contact ───────────────────────────────────────────────────
              _sectionLabel('contact', isDark),
              const SizedBox(height: SilatSpacing.sm),
              _field(controller: _phone, label: 'phone', isDark: isDark, keyboardType: TextInputType.phone),
              const SizedBox(height: SilatSpacing.md),
              _field(controller: _whatsapp, label: 'whatsapp', isDark: isDark, keyboardType: TextInputType.phone),
              const SizedBox(height: SilatSpacing.lg),

              // ── Dates ─────────────────────────────────────────────────────
              _sectionLabel('dates', isDark),
              const SizedBox(height: SilatSpacing.sm),
              Row(children: [
                Expanded(child: _DateTile(
                  label: 'date of birth',
                  date: _birthDate,
                  isDark: isDark,
                  onTap: () => _pickDate(
                    current: _birthDate,
                    onPicked: (d) => setState(() => _birthDate = d),
                  ),
                  onClear: _birthDate != null
                      ? () => setState(() => _birthDate = null)
                      : null,
                )),
                const SizedBox(width: SilatSpacing.md),
                Expanded(child: _DateTile(
                  label: 'date of death',
                  date: _deathDate,
                  isDark: isDark,
                  onTap: () => _pickDate(
                    current: _deathDate,
                    onPicked: (d) => setState(() => _deathDate = d),
                  ),
                  onClear: _deathDate != null
                      ? () => setState(() => _deathDate = null)
                      : null,
                )),
              ]),
              const SizedBox(height: SilatSpacing.lg),

              // ── Residence ─────────────────────────────────────────────────
              _sectionLabel('residence', isDark),
              const SizedBox(height: SilatSpacing.sm),
              _field(controller: _residenceLabel, label: 'place name', isDark: isDark),
              const SizedBox(height: SilatSpacing.md),
              Row(children: [
                Expanded(child: _field(
                  controller: _residenceLat,
                  label: 'latitude',
                  isDark: isDark,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final d = double.tryParse(v);
                    if (d == null || d < -90 || d > 90) return 'invalid';
                    return null;
                  },
                )),
                const SizedBox(width: SilatSpacing.md),
                Expanded(child: _field(
                  controller: _residenceLon,
                  label: 'longitude',
                  isDark: isDark,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final d = double.tryParse(v);
                    if (d == null || d < -180 || d > 180) return 'invalid';
                    return null;
                  },
                )),
              ]),
              _GeoHexDisplay(
                lat: double.tryParse(_residenceLat.text),
                lon: double.tryParse(_residenceLon.text),
                isDark: isDark,
              ),
              const SizedBox(height: SilatSpacing.lg),

              // ── Birth location ────────────────────────────────────────────
              _sectionLabel('place of birth', isDark),
              const SizedBox(height: SilatSpacing.sm),
              _field(controller: _birthLabel, label: 'place name', isDark: isDark),
              const SizedBox(height: SilatSpacing.md),
              Row(children: [
                Expanded(child: _field(
                  controller: _birthLat,
                  label: 'latitude',
                  isDark: isDark,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final d = double.tryParse(v);
                    if (d == null || d < -90 || d > 90) return 'invalid';
                    return null;
                  },
                )),
                const SizedBox(width: SilatSpacing.md),
                Expanded(child: _field(
                  controller: _birthLon,
                  label: 'longitude',
                  isDark: isDark,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final d = double.tryParse(v);
                    if (d == null || d < -180 || d > 180) return 'invalid';
                    return null;
                  },
                )),
              ]),
              _GeoHexDisplay(
                lat: double.tryParse(_birthLat.text),
                lon: double.tryParse(_birthLon.text),
                isDark: isDark,
              ),
              const SizedBox(height: SilatSpacing.lg),

              // ── Notes ─────────────────────────────────────────────────────
              _sectionLabel('notes', isDark),
              const SizedBox(height: SilatSpacing.sm),
              _field(controller: _notes, label: '', isDark: isDark, maxLines: 4),
              const SizedBox(height: SilatSpacing.lg),

              // ── Status ────────────────────────────────────────────────────
              _sectionLabel('status', isDark),
              const SizedBox(height: SilatSpacing.sm),
              SwitchListTile(
                title: Text('mark as urgent', style: SilatTypography.body(dark: isDark)),
                subtitle: Text(
                  'Flags transmission-critical members — elderly, isolated, or sole holders of family history.',
                  style: SilatTypography.label(dark: isDark),
                ),
                value: _isUrgent,
                onChanged: (v) => setState(() => _isUrgent = v),
                activeColor: SilatColors.terracotta,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: SilatSpacing.xl),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(height: 18, width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isNew ? 'add member' : 'save changes'),
                ),
              ),
              const SizedBox(height: SilatSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, bool isDark) => Text(
        text,
        style: SilatTypography.label(dark: isDark).copyWith(
          color: SilatColors.terracotta,
          letterSpacing: 1.5,
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required bool isDark,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
  }) =>
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        style: SilatTypography.body(dark: isDark),
        decoration: InputDecoration(labelText: label.isEmpty ? null : label),
        onChanged: (_) => setState(() {}), // for live GeoHex update
      );

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('delete member?'),
        content: Text(
            'This will remove ${_existing?.displayName ?? ''} and all their connections.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('delete', style: TextStyle(color: SilatColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final store = ref.read(eventStoreProvider);
      final user = ref.read(currentUserProvider)!;
      await store.deleteMember(actorId: user.id, memberId: _existing!.id);
      if (mounted) context.go('/home');
    }
  }
}

// ---------------------------------------------------------------------------
// Date tile — tap to pick, shows formatted date or placeholder
// ---------------------------------------------------------------------------
class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.date,
    required this.isDark,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final DateTime? date;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SilatSpacing.md,
          vertical: SilatSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isDark ? SilatColors.bg1 : SilatColors.lbg1,
          borderRadius: BorderRadius.circular(SilatRadius.md),
          border: Border.all(
            color: isDark ? SilatColors.bg3 : SilatColors.lbg3,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: SilatTypography.label(dark: isDark)
                          .copyWith(fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    date != null ? _dateFmt.format(date!) : 'tap to set',
                    style: SilatTypography.body(dark: isDark).copyWith(
                      color: date != null
                          ? null
                          : (isDark ? SilatColors.fg3 : SilatColors.fg3),
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.clear, size: 16, color: SilatColors.fg3),
              )
            else
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: SilatColors.fg3),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Geo hex display — shows a derived H3-style cell indicator from lat/lon.
// Real H3 indices are computed server-side on sync; this is a visual preview.
// ---------------------------------------------------------------------------
class _GeoHexDisplay extends StatelessWidget {
  const _GeoHexDisplay({
    required this.lat,
    required this.lon,
    required this.isDark,
  });

  final double? lat;
  final double? lon;
  final bool isDark;

  /// Generates a human-friendly hex cell string from lat/lon at ~res-7 precision.
  /// Format: <face>-<lat-cell>-<lon-cell> in hex, matching H3 visual style.
  String _cell(double lat, double lon) {
    // Approximate H3 res-7 cell size ~1.22km edge → ~0.023° per cell
    const cellDeg = 0.023;
    final iLat = ((lat + 90) / cellDeg).floor();
    final iLon = ((lon + 180) / cellDeg).floor();
    // Combine into a 64-bit-style hex string (15 chars like real H3)
    final raw = (iLat * 100000 + iLon).toRadixString(16).padLeft(10, '0');
    return '87${raw}fffff';
  }

  @override
  Widget build(BuildContext context) {
    if (lat == null || lon == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: SilatSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.hexagon_outlined, size: 12, color: SilatColors.slate),
          const SizedBox(width: 4),
          Text(
            _cell(lat!, lon!),
            style: SilatTypography.mono(dark: isDark)
                .copyWith(fontSize: 11, color: SilatColors.slate),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Photo picker — circle avatar with pick/remove controls
// ---------------------------------------------------------------------------
class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.photoUrl,
    required this.isDark,
    required this.onPick,
    required this.onRemove,
  });

  final String? photoUrl;
  final bool isDark;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? SilatColors.bg2 : SilatColors.lbg2,
              border: Border.all(
                color: isDark ? SilatColors.bg3 : SilatColors.lbg3,
                width: 2,
              ),
            ),
            child: _buildImage(),
          ),
        ),
        if (photoUrl != null)
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SilatColors.error,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          )
        else
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SilatColors.terracotta,
            ),
            child: const Icon(Icons.add_a_photo_outlined,
                size: 14, color: Colors.white),
          ),
      ],
    );
  }

  Widget _buildImage() {
    if (photoUrl == null) {
      return const Icon(Icons.person_outline, size: 40, color: SilatColors.fg3);
    }
    if (photoUrl!.startsWith('data:')) {
      // base64 data URI
      final comma = photoUrl!.indexOf(',');
      if (comma != -1) {
        final bytes = base64Decode(photoUrl!.substring(comma + 1));
        return ClipOval(child: Image.memory(bytes, fit: BoxFit.cover));
      }
    }
    return ClipOval(child: Image.network(photoUrl!, fit: BoxFit.cover));
  }
}
