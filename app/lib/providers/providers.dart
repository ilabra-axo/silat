// Central Riverpod providers.
// One file keeps the dependency graph legible.

import 'dart:math' show sin, cos, sqrt, atan2, pi;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../services/auth_service.dart';
import '../services/event_store.dart';
import '../services/kinship_engine.dart';
import '../models/member.dart';
import '../models/relationship.dart';
import '../models/kinship.dart';
import '../models/life_event.dart';

// ---------------------------------------------------------------------------
// Infrastructure
// ---------------------------------------------------------------------------

final databaseProvider = Provider<SilatDatabase>((ref) {
  final db = SilatDatabase();
  ref.onDispose(db.close);
  return db;
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final eventStoreProvider = Provider<EventStore>((ref) {
  return EventStore(ref.read(databaseProvider));
});

final kinshipEngineProvider = Provider<KinshipEngine>((_) => KinshipEngine());

// ---------------------------------------------------------------------------
// Auth state
// ---------------------------------------------------------------------------

final currentUserProvider = StateProvider<SilatUser?>((ref) => null);

// ---------------------------------------------------------------------------
// Data streams
// ---------------------------------------------------------------------------

final membersProvider = StreamProvider<List<Member>>((ref) {
  return ref
      .read(databaseProvider)
      .watchAllMembers()
      .map((rows) => rows.map(_rowToMember).toList());
});

final relationshipsProvider = StreamProvider<List<Relationship>>((ref) {
  return ref
      .read(databaseProvider)
      .watchAllRelationships()
      .map((rows) => rows.map(_rowToRelationship).toList());
});

// ---------------------------------------------------------------------------
// Ego / perspective node
// ---------------------------------------------------------------------------

final egoPerspectiveIdProvider = StateProvider<String?>((ref) => null);

// ---------------------------------------------------------------------------
// Derived kinship map (recomputed when members/relationships/ego changes)
// ---------------------------------------------------------------------------

final kinshipMapProvider =
    Provider<Map<String, KinshipResult>>((ref) {
  final egoId = ref.watch(egoPerspectiveIdProvider);
  if (egoId == null) return {};

  final membersAsync = ref.watch(membersProvider);
  final relsAsync = ref.watch(relationshipsProvider);

  return membersAsync.when(
    data: (members) => relsAsync.when(
      data: (rels) {
        final engine = ref.read(kinshipEngineProvider);
        final results = engine.derive(
          egoId: egoId,
          members: members,
          relationships: rels,
        );
        return {for (final r in results) r.alterId: r};
      },
      loading: () => {},
      error: (_, __) => {},
    ),
    loading: () => {},
    error: (_, __) => {},
  );
});

// ---------------------------------------------------------------------------
// Theme mode
// ---------------------------------------------------------------------------

final themeModeProvider = StateProvider<bool>((ref) => true); // true = dark

// ---------------------------------------------------------------------------
// Serendipity engine — S(a,b) = w1·R + w2·P + w3·T + w4·U
// ---------------------------------------------------------------------------

class SerendipitySuggestion {
  const SerendipitySuggestion({
    required this.member,
    required this.relationship,
    required this.score,
    required this.rScore,
    required this.pScore,
    required this.tScore,
    required this.uScore,
  });

  final Member member;
  final Relationship relationship;
  final double score;   // 0.0–1.0 composite
  final double rScore;  // relational salience
  final double pScore;  // proximity
  final double tScore;  // silence gap
  final double uScore;  // urgency

  /// Human-readable reasons for this score.
  List<String> get reasons {
    final out = <String>[];
    if (tScore >= 0.6) out.add('long silence');
    if (uScore >= 1.0) out.add('transmission priority');
    if (rScore >= 0.7) out.add('close bond');
    if (pScore >= 0.7) out.add('nearby');
    return out;
  }
}

/// Serendipity suggestions for the ego user, ranked by score descending.
final serendipityProvider =
    Provider<List<SerendipitySuggestion>>((ref) {
  final egoId = ref.watch(egoPerspectiveIdProvider);
  if (egoId == null) return [];

  final membersAsync = ref.watch(membersProvider);
  final relsAsync = ref.watch(relationshipsProvider);

  return membersAsync.when(
    data: (members) => relsAsync.when(
      data: (rels) {
        final memberById = {for (final m in members) m.id: m};
        final egoMember = memberById[egoId];

        final suggestions = <SerendipitySuggestion>[];

        for (final rel in rels) {
          // Only consider relationships involving ego
          final alterId = rel.sourceId == egoId
              ? rel.targetId
              : rel.targetId == egoId
                  ? rel.sourceId
                  : null;
          if (alterId == null) continue;

          final alter = memberById[alterId];
          if (alter == null) continue;

          final r = rel.salience; // R — relational salience
          final t = _silenceScore(rel.silenceGapDays); // T
          final p = _proximityScore(egoMember, alter); // P
          final u = alter.isUrgent ? 1.0 : 0.0; // U

          const w1 = 0.30; // salience
          const w2 = 0.15; // proximity
          const w3 = 0.35; // silence
          const w4 = 0.20; // urgency

          final score = w1 * r + w2 * p + w3 * t + w4 * u;

          suggestions.add(SerendipitySuggestion(
            member: alter,
            relationship: rel,
            score: score,
            rScore: r,
            pScore: p,
            tScore: t,
            uScore: u,
          ));
        }

        suggestions.sort((a, b) => b.score.compareTo(a.score));
        return suggestions;
      },
      loading: () => [],
      error: (_, __) => [],
    ),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Normalize silence gap to 0–1. Higher = more overdue.
double _silenceScore(int? days) {
  if (days == null) return 0.5; // never logged — moderate score
  if (days <= 30) return 0.0;
  if (days <= 90) return 0.25;
  if (days <= 180) return 0.5;
  if (days <= 365) return 0.75;
  return 1.0;
}

/// Proximity decay 0–1. Higher = closer.
double _proximityScore(Member? ego, Member alter) {
  if (ego == null) return 0.5;
  if (!ego.hasGeo || !alter.hasGeo) return 0.5;

  final km = _haversineKm(
    ego.latitude!, ego.longitude!,
    alter.latitude!, alter.longitude!,
  );

  if (km < 10) return 1.0;
  if (km < 50) return 0.7;
  if (km < 200) return 0.4;
  if (km < 1000) return 0.2;
  return 0.05;
}

double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  final dLat = (lat2 - lat1) * pi / 180;
  final dLon = (lon2 - lon1) * pi / 180;
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
          sin(dLon / 2) * sin(dLon / 2);
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}

// ---------------------------------------------------------------------------
// Converters — Drift row → domain model
// ---------------------------------------------------------------------------

Member _rowToMember(dynamic row) => Member(
      id: row.id as String,
      firstName: row.firstName as String,
      lastName: row.lastName as String?,
      birthDate: row.birthDate as DateTime?,
      deathDate: row.deathDate as DateTime?,
      gender: GenderLabel.fromCode(row.gender as String?),
      locationLabel: row.locationLabel as String?,
      latitude: row.latitude as double?,
      longitude: row.longitude as double?,
      residenceH3: row.residenceH3 as String?,
      birthLocationLabel: row.birthLocationLabel as String?,
      birthLatitude: row.birthLatitude as double?,
      birthLongitude: row.birthLongitude as double?,
      birthH3: row.birthH3 as String?,
      notes: row.notes as String?,
      photoUrl: row.photoUrl as String?,
      phone: row.phone as String?,
      whatsapp: row.whatsapp as String?,
      isUrgent: (row.isUrgent as bool?) ?? false,
      createdAt: row.createdAt as DateTime,
      updatedAt: row.updatedAt as DateTime,
    );

Relationship _rowToRelationship(dynamic row) => Relationship(
      id: row.id as String,
      sourceId: row.sourceId as String,
      targetId: row.targetId as String,
      relType: RelTypeLabel.fromCode(row.relType as String),
      lastContactAt: row.lastContactAt as DateTime?,
      notes: row.relNotes as String?,
      salience: (row.salience as double?) ?? 0.5,
      interventionMode:
          InterventionModeLabel.fromCode(row.interventionMode as String?),
      createdAt: row.createdAt as DateTime,
    );

final lifeEventsProvider =
    StreamProvider.family<List<LifeEvent>, String>((ref, memberId) {
  return ref
      .read(databaseProvider)
      .watchLifeEventsForMember(memberId)
      .map((rows) => rows
          .map((r) => LifeEvent(
                id: r.id,
                memberId: r.memberId,
                eventType: LifeEventTypeLabel.fromCode(r.eventType),
                occurredAt: r.occurredAt,
                notes: r.notes,
                createdAt: r.createdAt,
              ))
          .toList());
});
