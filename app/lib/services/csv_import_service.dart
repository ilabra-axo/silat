// CsvImportService — parses the silat CSV format and loads via EventStore.
//
// Format (mirrors silat-import-template.csv):
//   id, first_name, last_name, birth_year, death_year, gender,
//   location_label, latitude, longitude, notes, rel_type, rel_target_id
//
// Rules:
//   - Lines starting with '#' are comments — skipped.
//   - First row is the header — skipped.
//   - A member's data is taken from its FIRST row only.
//   - Repeat a member's id to add additional relationships.
//   - Relationships are resolved within the batch and against existing members.

import '../models/member.dart';
import '../models/relationship.dart';
import 'event_store.dart';

class ImportResult {
  const ImportResult({
    required this.membersAdded,
    required this.relationshipsAdded,
    required this.rowsTotal,
    required this.errors,
  });

  final int membersAdded;
  final int relationshipsAdded;
  final int rowsTotal;
  final List<String> errors;

  int get rowsFailed => errors.length;
  bool get hasErrors => errors.isNotEmpty;
}

class CsvImportService {
  CsvImportService(this._store);
  final EventStore _store;

  Future<ImportResult> importCsv({
    required String csvContent,
    required String actorId,
  }) async {
    final lines = csvContent.split('\n');
    final errors = <String>[];
    int memberCount = 0;
    int relCount = 0;
    int dataRowCount = 0;

    // id → id in our store (CSV ids are user-assigned shorts like 'p001')
    final idMap = <String, String>{}; // csvId → storedId
    final seenIds = <String>{};       // csvIds already processed as members

    for (int i = 0; i < lines.length; i++) {
      final raw = lines[i].trim();
      if (raw.isEmpty) continue;
      if (raw.startsWith('#')) continue;         // comment
      if (i == 0 && raw.startsWith('id,')) continue; // header row

      final cols = _parseCsvRow(raw);
      if (cols.isEmpty) continue;
      if (cols.length < 2) {
        errors.add('Row ${i + 1}: too few columns');
        continue;
      }

      final csvId = cols[0].trim();
      if (csvId.isEmpty) {
        errors.add('Row ${i + 1}: missing id');
        continue;
      }

      dataRowCount++;

      // --- Member data (first row for this id only) ---
      if (!seenIds.contains(csvId)) {
        seenIds.add(csvId);

        final firstName = _col(cols, 1);
        if (firstName.isEmpty) {
          errors.add('Row ${i + 1}: missing first_name for id "$csvId"');
          continue;
        }

        final lastName  = _colOrNull(cols, 2);
        final birthDate = _parseYear(_col(cols, 3));
        final deathDate = _parseYear(_col(cols, 4));
        final gender    = GenderLabel.fromCode(_colOrNull(cols, 5));
        final location  = _colOrNull(cols, 6);
        final lat       = double.tryParse(_col(cols, 7));
        final lon       = double.tryParse(_col(cols, 8));
        final notes     = _colOrNull(cols, 9);

        try {
          final member = await _store.addMember(
            actorId: actorId,
            firstName: firstName,
            lastName: lastName,
            birthDate: birthDate,
            deathDate: deathDate,
            gender: gender,
            locationLabel: location,
            latitude: lat,
            longitude: lon,
            notes: notes,
          );
          idMap[csvId] = member.id;
          memberCount++;
        } catch (e) {
          errors.add('Row ${i + 1}: failed to add member "$firstName" — $e');
        }
      }

      // --- Relationship (any row that has rel_type + rel_target_id) ---
      final relTypeStr   = _colOrNull(cols, 10);
      final relTargetCsv = _colOrNull(cols, 11);

      if (relTypeStr != null && relTargetCsv != null) {
        RelType relType;
        try {
          relType = RelTypeLabel.fromCode(relTypeStr);
        } catch (_) {
          errors.add('Row ${i + 1}: unknown rel_type "$relTypeStr"');
          continue;
        }

        final sourceStored  = idMap[csvId];
        final targetStored  = idMap[relTargetCsv];

        if (sourceStored == null) {
          errors.add('Row ${i + 1}: source id "$csvId" not yet resolved');
          continue;
        }
        if (targetStored == null) {
          // Target might not have been processed yet — defer or skip
          errors.add(
            'Row ${i + 1}: target id "$relTargetCsv" not found. '
            'Ensure the target member appears before or in the same file.',
          );
          continue;
        }

        try {
          final rel = await _store.createRelationship(
            actorId: actorId,
            sourceId: sourceStored,
            targetId: targetStored,
            relType: relType,
          );
          if (rel != null) relCount++;
        } catch (e) {
          errors.add('Row ${i + 1}: failed to create relationship — $e');
        }
      }
    }

    return ImportResult(
      membersAdded: memberCount,
      relationshipsAdded: relCount,
      rowsTotal: dataRowCount,
      errors: errors,
    );
  }

  // ---------------------------------------------------------------------------
  // CSV parsing — handles quoted fields with commas and escaped quotes
  // ---------------------------------------------------------------------------

  List<String> _parseCsvRow(String row) {
    final fields = <String>[];
    final buf = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < row.length; i++) {
      final ch = row[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < row.length && row[i + 1] == '"') {
          buf.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ',' && !inQuotes) {
        fields.add(buf.toString().trim());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    fields.add(buf.toString().trim());
    return fields;
  }

  String _col(List<String> cols, int i) =>
      i < cols.length ? cols[i].trim() : '';

  String? _colOrNull(List<String> cols, int i) {
    final v = _col(cols, i);
    return v.isEmpty ? null : v;
  }

  DateTime? _parseYear(String s) {
    final y = int.tryParse(s);
    return y != null ? DateTime.utc(y) : null;
  }
}
