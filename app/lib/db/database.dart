// Drift SQLite — local-first store.
// Three tables: events (append-only log), members (read model), relationships (read model).
// All writes go through events → projector rebuilds read models.
// @DataClassName used to avoid collision with domain model classes.

import 'package:drift/drift.dart';
import 'connection/native.dart'
    if (dart.library.html) 'connection/web.dart';

part 'database.g.dart';

// ---------------------------------------------------------------------------
// Table definitions
// ---------------------------------------------------------------------------

@DataClassName('EventRow')
class Events extends Table {
  TextColumn get id => text()();
  TextColumn get streamId => text()();
  TextColumn get streamType => text()();
  TextColumn get eventType => text()();
  TextColumn get payloadJson => text()();
  TextColumn get actorId => text()();
  DateTimeColumn get occurredAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MemberRow')
class Members extends Table {
  TextColumn get id => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  DateTimeColumn get deathDate => dateTime().nullable()();
  TextColumn get gender => text().withDefault(const Constant(''))();
  // Residence
  TextColumn get locationLabel => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get residenceH3 => text().nullable()();
  // Birth location
  TextColumn get birthLocationLabel => text().nullable()();
  RealColumn get birthLatitude => real().nullable()();
  RealColumn get birthLongitude => real().nullable()();
  TextColumn get birthH3 => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get whatsapp => text().nullable()();
  BoolColumn get isUrgent => boolean().withDefault(const Constant(false))();
  // Identity claim
  TextColumn get claimState =>
      text().withDefault(const Constant('seeded'))();
  TextColumn get ownerUserId => text().nullable()();
  TextColumn get claimToken => text().nullable()();
  // Stewardship (delegate archivist — parallel to identity claim)
  TextColumn get stewardshipState =>
      text().withDefault(const Constant('none'))();
  TextColumn get stewardUserId => text().nullable()();
  TextColumn get stewardClaimToken => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RelationshipRow')
class Relationships extends Table {
  TextColumn get id => text()();
  TextColumn get sourceId => text()();
  TextColumn get targetId => text()();
  TextColumn get relType => text()();
  DateTimeColumn get lastContactAt => dateTime().nullable()();
  TextColumn get relNotes => text().nullable()();
  RealColumn get salience => real().withDefault(const Constant(0.5))();
  TextColumn get interventionMode =>
      text().withDefault(const Constant('passive'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LifeEventRow')
class LifeEvents extends Table {
  TextColumn get id => text()();
  TextColumn get memberId => text()();
  TextColumn get eventType => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [Events, Members, Relationships, LifeEvents])
class SilatDatabase extends _$SilatDatabase {
  SilatDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => await m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 4) {
            await m.drop(members);
            await m.create(members);
            await m.drop(relationships);
            await m.create(relationships);
            await m.createTable(lifeEvents);
          } else if (from < 5) {
            await m.drop(relationships);
            await m.create(relationships);
          }
          if (from < 6) {
            await m.addColumn(members, members.claimState);
            await m.addColumn(members, members.ownerUserId);
            await m.addColumn(members, members.claimToken);
          }
          if (from < 7) {
            await m.addColumn(members, members.stewardshipState);
            await m.addColumn(members, members.stewardUserId);
            await m.addColumn(members, members.stewardClaimToken);
          }
        },
      );

  static QueryExecutor _openConnection() => openConnection();

  // --- Event log ---

  Future<void> appendEvent(EventsCompanion event) =>
      into(events).insert(event, mode: InsertMode.insertOrIgnore);

  Stream<List<EventRow>> watchUnsynced() =>
      (select(events)..where((e) => e.synced.equals(false))).watch();

  Future<List<EventRow>> getUnsyncedEvents() =>
      (select(events)..where((e) => e.synced.equals(false))).get();

  Future<void> markSynced(List<String> ids) async {
    await (update(events)..where((e) => e.id.isIn(ids)))
        .write(const EventsCompanion(synced: Value(true)));
  }

  // --- Members read model ---

  Stream<List<MemberRow>> watchAllMembers() =>
      (select(members)..orderBy([(m) => OrderingTerm.asc(m.firstName)]))
          .watch();

  Future<List<MemberRow>> getAllMembers() =>
      (select(members)..orderBy([(m) => OrderingTerm.asc(m.firstName)])).get();

  Future<MemberRow?> getMemberById(String id) =>
      (select(members)..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<void> upsertMember(MembersCompanion member) =>
      into(members).insertOnConflictUpdate(member);

  Future<void> deleteMember(String id) =>
      (delete(members)..where((m) => m.id.equals(id))).go();

  // --- Relationships read model ---

  Stream<List<RelationshipRow>> watchAllRelationships() =>
      select(relationships).watch();

  Future<List<RelationshipRow>> getAllRelationships() =>
      select(relationships).get();

  Future<List<RelationshipRow>> getRelationshipsForMember(String memberId) =>
      (select(relationships)
            ..where((r) =>
                r.sourceId.equals(memberId) | r.targetId.equals(memberId)))
          .get();

  Future<void> upsertRelationship(RelationshipsCompanion rel) =>
      into(relationships).insertOnConflictUpdate(rel);

  Future<void> deleteRelationship(String id) =>
      (delete(relationships)..where((r) => r.id.equals(id))).go();

  // --- LifeEvents ---

  Stream<List<LifeEventRow>> watchLifeEventsForMember(String memberId) =>
      (select(lifeEvents)
            ..where((e) => e.memberId.equals(memberId))
            ..orderBy([(e) => OrderingTerm.desc(e.occurredAt)]))
          .watch();

  Future<void> insertLifeEvent(LifeEventsCompanion event) =>
      into(lifeEvents).insert(event);

  Future<void> deleteLifeEvent(String id) =>
      (delete(lifeEvents)..where((e) => e.id.equals(id))).go();
}
