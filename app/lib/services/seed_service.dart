// SeedService — loads the Braun family demo data (from the import template).
// Uses EventStore so CQRS invariants hold.

import '../models/member.dart';
import '../models/relationship.dart';
import 'event_store.dart';

class SeedService {
  SeedService(this._store);
  final EventStore _store;

  static const _actorId = 'dev-user-001';

  // Braun family — three generations across Germany/Switzerland.
  // Mirrors the silat-import-template.csv example data exactly.
  Future<void> loadBraunFamily() async {
    // Generation 1 — grandparents
    final heinrich = await _store.addMember(
      actorId: _actorId,
      firstName: 'Heinrich',
      lastName: 'Braun',
      birthDate: DateTime.utc(1920),
      deathDate: DateTime.utc(1995),
      gender: Gender.male,
      locationLabel: 'Munich, Germany',
      latitude: 48.1351,
      longitude: 11.5820,
      birthLocationLabel: 'Munich, Germany',
      birthLatitude: 48.1351,
      birthLongitude: 11.5820,
      notes: 'Patriarch',
    );
    final margot = await _store.addMember(
      actorId: _actorId,
      firstName: 'Margot',
      lastName: 'Braun',
      birthDate: DateTime.utc(1923),
      deathDate: DateTime.utc(2010),
      gender: Gender.female,
      locationLabel: 'Munich, Germany',
      latitude: 48.1370,
      longitude: 11.5750,
      birthLocationLabel: 'Munich, Germany',
      birthLatitude: 48.1370,
      birthLongitude: 11.5750,
    );

    // Generation 2 — Werner + Hélène
    final werner = await _store.addMember(
      actorId: _actorId,
      firstName: 'Werner',
      lastName: 'Braun',
      birthDate: DateTime.utc(1948),
      gender: Gender.male,
      locationLabel: 'Konstanz, Germany',
      latitude: 47.6779,
      longitude: 9.1732,
      birthLocationLabel: 'Munich, Germany',
      birthLatitude: 48.1351,
      birthLongitude: 11.5820,
      notes: 'Civil Engineer',
    );
    final helene = await _store.addMember(
      actorId: _actorId,
      firstName: 'Hélène',
      lastName: 'Braun',
      birthDate: DateTime.utc(1952),
      gender: Gender.female,
      locationLabel: 'Konstanz, Germany',
      latitude: 47.6800,
      longitude: 9.1750,
      notes: 'Teacher',
    );

    // Generation 3 — Alex, Nina, Sam, Mila
    final alex = await _store.addMember(
      actorId: _actorId,
      firstName: 'Alex',
      lastName: 'Braun',
      birthDate: DateTime.utc(1978),
      gender: Gender.nonBinary,
      locationLabel: 'Konstanz, Germany',
      latitude: 47.6779,
      longitude: 9.1732,
    );
    final nina = await _store.addMember(
      actorId: _actorId,
      firstName: 'Nina',
      lastName: 'Braun',
      birthDate: DateTime.utc(1981),
      gender: Gender.female,
      locationLabel: 'Zurich, Switzerland',
      latitude: 47.3769,
      longitude: 8.5417,
    );
    final sam = await _store.addMember(
      actorId: _actorId,
      firstName: 'Sam',
      lastName: 'Hoffmann',
      birthDate: DateTime.utc(1977),
      gender: Gender.male,
      locationLabel: 'Konstanz, Germany',
      latitude: 47.6780,
      longitude: 9.1720,
    );
    final mila = await _store.addMember(
      actorId: _actorId,
      firstName: 'Mila',
      lastName: 'Hoffmann',
      birthDate: DateTime.utc(2008),
      gender: Gender.female,
      locationLabel: 'Konstanz, Germany',
      latitude: 47.6779,
      longitude: 9.1732,
    );

    // --- Relationships (mirrors CSV exactly) ---

    // Margot + Heinrich are partners
    await _store.createRelationship(
        actorId: _actorId, sourceId: margot.id, targetId: heinrich.id, relType: RelType.partner);

    // Werner is child of Heinrich + Margot
    await _store.createRelationship(
        actorId: _actorId, sourceId: heinrich.id, targetId: werner.id, relType: RelType.parentChild);
    await _store.createRelationship(
        actorId: _actorId, sourceId: margot.id, targetId: werner.id, relType: RelType.parentChild);

    // Hélène is partner of Werner
    await _store.createRelationship(
        actorId: _actorId, sourceId: helene.id, targetId: werner.id, relType: RelType.partner);

    // Alex is child of Werner + Hélène
    await _store.createRelationship(
        actorId: _actorId, sourceId: werner.id, targetId: alex.id, relType: RelType.parentChild);
    await _store.createRelationship(
        actorId: _actorId, sourceId: helene.id, targetId: alex.id, relType: RelType.parentChild);

    // Nina is child of Werner + Hélène
    await _store.createRelationship(
        actorId: _actorId, sourceId: werner.id, targetId: nina.id, relType: RelType.parentChild);
    await _store.createRelationship(
        actorId: _actorId, sourceId: helene.id, targetId: nina.id, relType: RelType.parentChild);

    // Sam is partner of Alex
    await _store.createRelationship(
        actorId: _actorId, sourceId: sam.id, targetId: alex.id, relType: RelType.partner);

    // Mila is child of Alex + Sam
    await _store.createRelationship(
        actorId: _actorId, sourceId: alex.id, targetId: mila.id, relType: RelType.parentChild);
    await _store.createRelationship(
        actorId: _actorId, sourceId: sam.id, targetId: mila.id, relType: RelType.parentChild);
  }
}
