// SyncService — pushes local unsynced events to the cloud, pulls server state.
// Designed to run silently in the background after auth.

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;

import '../db/database.dart';
import 'auth_service.dart';

class SyncService {
  static const _apiBase = 'https://silat-api.vercel.app';
  static const _batchSize = 50;

  final SilatDatabase _db;
  final AuthService _authService;
  bool _syncing = false;

  SyncService(this._db, this._authService);

  // ---------------------------------------------------------------------------
  // Push — send unsynced local events to the server
  // ---------------------------------------------------------------------------

  Future<void> push() async {
    final unsynced = await _db.getUnsyncedEvents();
    if (unsynced.isEmpty) return;

    // Process in batches of 50
    for (var i = 0; i < unsynced.length; i += _batchSize) {
      final batch = unsynced.skip(i).take(_batchSize).toList();

      final payload = batch.map((e) => {
            'id': e.id,
            'stream_id': e.streamId,
            'stream_type': e.streamType,
            'event_type': e.eventType,
            'payload': jsonDecode(e.payloadJson) as Object,
            'actor_id': e.actorId,
            'occurred_at': e.occurredAt.toIso8601String(),
          }).toList();

      try {
        final response = await http.post(
          Uri.parse('$_apiBase/api/events'),
          headers: {
            'Authorization': 'Bearer ${_authService.token}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'events': payload}),
        );

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final applied = (body['applied'] as List<dynamic>)
              .map((id) => id as String)
              .toList();
          if (applied.isNotEmpty) {
            await _db.markSynced(applied);
          }
        }
      } catch (_) {
        // Offline-first: silently ignore network errors
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Pull — fetch server state and upsert into local DB
  // ---------------------------------------------------------------------------

  Future<void> pull() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBase/api/members'),
        headers: {
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      if (response.statusCode != 200) return;

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      final members =
          (body['members'] as List<dynamic>).cast<Map<String, dynamic>>();
      for (final m in members) {
        await _db.upsertMember(_memberToCompanion(m));
      }

      final relationships =
          (body['relationships'] as List<dynamic>).cast<Map<String, dynamic>>();
      for (final r in relationships) {
        await _db.upsertRelationship(_relToCompanion(r));
      }
    } catch (_) {
      // Offline-first: silently ignore network errors
    }
  }

  // ---------------------------------------------------------------------------
  // Sync — push then pull, with guard against concurrent runs
  // ---------------------------------------------------------------------------

  Future<void> sync() async {
    if (_syncing) return;
    _syncing = true;
    try {
      await push();
      await pull();
    } finally {
      _syncing = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Periodic sync
  // ---------------------------------------------------------------------------

  void startPeriodicSync({
    Duration interval = const Duration(minutes: 5),
  }) {
    Timer.periodic(interval, (_) => sync());
  }

  // ---------------------------------------------------------------------------
  // Row mappers — Postgres snake_case → Drift companions
  // ---------------------------------------------------------------------------

  MembersCompanion _memberToCompanion(Map<String, dynamic> m) {
    DateTime? parseDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v as String);

    return MembersCompanion(
      id: Value(m['id'] as String),
      firstName: Value(m['first_name'] as String),
      lastName: Value(m['last_name'] as String?),
      birthDate: Value(parseDate(m['birth_date'])),
      deathDate: Value(parseDate(m['death_date'])),
      gender: Value((m['gender'] as String?) ?? ''),
      locationLabel: Value(m['location_label'] as String?),
      latitude: Value(m['latitude'] as double?),
      longitude: Value(m['longitude'] as double?),
      residenceH3: Value(m['residence_h3'] as String?),
      birthLocationLabel: Value(m['birth_location_label'] as String?),
      birthLatitude: Value(m['birth_latitude'] as double?),
      birthLongitude: Value(m['birth_longitude'] as double?),
      birthH3: Value(m['birth_h3'] as String?),
      notes: Value(m['notes'] as String?),
      photoUrl: Value(m['photo_url'] as String?),
      phone: Value(m['phone'] as String?),
      whatsapp: Value(m['whatsapp'] as String?),
      isUrgent: Value((m['is_urgent'] as bool?) ?? false),
      claimState: Value((m['claim_state'] as String?) ?? 'seeded'),
      ownerUserId: Value(m['owner_user_id'] as String?),
      claimToken: Value(m['claim_token'] as String?),
      stewardshipState: Value((m['stewardship_state'] as String?) ?? 'none'),
      stewardUserId: Value(m['steward_user_id'] as String?),
      stewardClaimToken: Value(m['steward_claim_token'] as String?),
      createdAt: Value(
        parseDate(m['created_at']) ?? DateTime.now(),
      ),
      updatedAt: Value(
        parseDate(m['updated_at']) ?? DateTime.now(),
      ),
    );
  }

  RelationshipsCompanion _relToCompanion(Map<String, dynamic> r) {
    DateTime? parseDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v as String);

    return RelationshipsCompanion(
      id: Value(r['id'] as String),
      sourceId: Value(r['source_id'] as String),
      targetId: Value(r['target_id'] as String),
      relType: Value(r['rel_type'] as String),
      lastContactAt: Value(parseDate(r['last_contact_at'])),
      relNotes: Value(r['rel_notes'] as String?),
      salience: Value((r['salience'] as num?)?.toDouble() ?? 0.5),
      interventionMode:
          Value((r['intervention_mode'] as String?) ?? 'passive'),
      createdAt: Value(
        parseDate(r['created_at']) ?? DateTime.now(),
      ),
    );
  }
}
