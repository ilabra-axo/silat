// Central Riverpod providers — remote-only, API-backed.
// All data lives in Neon Postgres. No local SQLite on read path.

import 'dart:math' show sin, cos, sqrt, atan2, pi;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
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

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.read(authServiceProvider));
});

final eventStoreProvider = Provider<EventStore>((ref) {
  return EventStore(
    ref.read(apiServiceProvider),
    onDataChanged: () {
      ref.invalidate(familyDataProvider);
    },
  );
});

final kinshipEngineProvider = Provider<KinshipEngine>((_) => KinshipEngine());

// ---------------------------------------------------------------------------
// Auth state
// ---------------------------------------------------------------------------

final currentUserProvider = StateProvider<SilatUser?>((ref) => null);

// ---------------------------------------------------------------------------
// Remote data — single fetch for members + relationships together
// ---------------------------------------------------------------------------

class _FamilyData {
  const _FamilyData({required this.members, required this.relationships});
  final List<Member> members;
  final List<Relationship> relationships;
}

class _FamilyDataNotifier extends AsyncNotifier<_FamilyData> {
  @override
  Future<_FamilyData> build() async {
    // Keep data alive across navigation — avoids re-fetch on every tab switch.
    // Invalidated explicitly after every write via onDataChanged.
    ref.keepAlive();

    final user = ref.watch(currentUserProvider);
    if (user == null) return const _FamilyData(members: [], relationships: []);
    final result = await ref.read(apiServiceProvider).fetchAll();
    return _FamilyData(members: result.members, relationships: result.relationships);
  }
}

final familyDataProvider =
    AsyncNotifierProvider<_FamilyDataNotifier, _FamilyData>(
  _FamilyDataNotifier.new,
);

/// Maps to List<Member> from the combined fetch.
final membersProvider = Provider<AsyncValue<List<Member>>>((ref) {
  return ref.watch(familyDataProvider).whenData((d) => d.members);
});

/// Maps to List<Relationship> from the combined fetch.
final relationshipsProvider = Provider<AsyncValue<List<Relationship>>>((ref) {
  return ref.watch(familyDataProvider).whenData((d) => d.relationships);
});

// ---------------------------------------------------------------------------
// Life events — still local (Drift) for now; not cross-user critical
// ---------------------------------------------------------------------------

final lifeEventsProvider =
    StreamProvider.family<List<LifeEvent>, String>((ref, memberId) {
  return ref
      .read(databaseProvider)
      .watchLifeEventsForMember(memberId)
      .map((rows) => rows.map(_rowToLifeEvent).toList());
});

// ---------------------------------------------------------------------------
// Ego / perspective node
// ---------------------------------------------------------------------------

final egoPerspectiveIdProvider = StateProvider<String?>((ref) => null);

// ---------------------------------------------------------------------------
// Kinship map from ego perspective
// ---------------------------------------------------------------------------

final kinshipMapProvider = Provider<Map<String, KinshipResult>>((ref) {
  final egoId = ref.watch(egoPerspectiveIdProvider);
  if (egoId == null) return {};

  final membersValue = ref.watch(membersProvider);
  final relsValue = ref.watch(relationshipsProvider);

  return membersValue.when(
    data: (members) => relsValue.when(
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

/// Kinship map from a specific member's perspective (for profile connections).
final memberKinshipProvider =
    Provider.family<Map<String, KinshipResult>, String>((ref, memberId) {
  final membersValue = ref.watch(membersProvider);
  final relsValue = ref.watch(relationshipsProvider);

  return membersValue.when(
    data: (members) => relsValue.when(
      data: (rels) {
        final engine = ref.read(kinshipEngineProvider);
        final results = engine.derive(
          egoId: memberId,
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
  final double score;
  final double rScore;
  final double pScore;
  final double tScore;
  final double uScore;

  List<String> get reasons {
    final out = <String>[];
    if (tScore >= 0.6) out.add('long silence');
    if (uScore >= 1.0) out.add('transmission priority');
    if (rScore >= 0.7) out.add('close bond');
    if (pScore >= 0.7) out.add('nearby');
    return out;
  }
}

final serendipityProvider = Provider<List<SerendipitySuggestion>>((ref) {
  final egoId = ref.watch(egoPerspectiveIdProvider);
  if (egoId == null) return [];

  final membersValue = ref.watch(membersProvider);
  final relsValue = ref.watch(relationshipsProvider);

  return membersValue.when(
    data: (members) => relsValue.when(
      data: (rels) {
        final memberById = {for (final m in members) m.id: m};
        final egoMember = memberById[egoId];

        final suggestions = <SerendipitySuggestion>[];

        for (final rel in rels) {
          final alterId = rel.sourceId == egoId
              ? rel.targetId
              : rel.targetId == egoId
                  ? rel.sourceId
                  : null;
          if (alterId == null) continue;

          final alter = memberById[alterId];
          if (alter == null) continue;

          final r = rel.salience;
          final t = _silenceScore(rel.silenceGapDays);
          final p = _proximityScore(egoMember, alter);
          final u = alter.isUrgent ? 1.0 : 0.0;

          const w1 = 0.30;
          const w2 = 0.15;
          const w3 = 0.35;
          const w4 = 0.20;

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
  if (days == null) return 0.5;
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
// Row mappers (still used for lifeEvents from local Drift)
// ---------------------------------------------------------------------------

LifeEvent _rowToLifeEvent(LifeEventRow row) => LifeEvent(
      id: row.id,
      memberId: row.memberId,
      eventType: LifeEventTypeLabel.fromCode(row.eventType),
      occurredAt: row.occurredAt,
      notes: row.notes,
      createdAt: row.createdAt,
    );
