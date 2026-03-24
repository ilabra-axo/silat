// EventStore — command side of CQRS.
// All writes pass through here: create event → project onto read model → queue sync.

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../models/member.dart' as m;
import '../models/relationship.dart' as r;
import '../models/life_event.dart';
import '../models/event.dart';

class EventStore {
  EventStore(this._db);

  final SilatDatabase _db;

  // -------------------------------------------------------------------------
  // Member commands
  // -------------------------------------------------------------------------

  Future<m.Member> addMember({
    required String actorId,
    required String firstName,
    String? lastName,
    DateTime? birthDate,
    DateTime? deathDate,
    m.Gender gender = m.Gender.unspecified,
    String? locationLabel,
    double? latitude,
    double? longitude,
    String? residenceH3,
    String? birthLocationLabel,
    double? birthLatitude,
    double? birthLongitude,
    String? birthH3,
    String? notes,
    String? photoUrl,
    String? phone,
    String? whatsapp,
    bool isUrgent = false,
  }) async {
    final id = const Uuid().v4().substring(0, 7);
    final now = DateTime.now().toUtc();

    final member = m.Member(
      id: id,
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      deathDate: deathDate,
      gender: gender,
      locationLabel: locationLabel,
      latitude: latitude,
      longitude: longitude,
      residenceH3: residenceH3,
      birthLocationLabel: birthLocationLabel,
      birthLatitude: birthLatitude,
      birthLongitude: birthLongitude,
      birthH3: birthH3,
      notes: notes,
      photoUrl: photoUrl,
      phone: phone,
      whatsapp: whatsapp,
      isUrgent: isUrgent,
      createdAt: now,
      updatedAt: now,
    );

    await _append(
      streamId: id,
      streamType: StreamType.member,
      eventType: EventType.memberAdded,
      payload: member.toJson(),
      actorId: actorId,
      occurredAt: now,
    );

    await _db.upsertMember(_memberToCompanion(member));
    return member;
  }

  Future<m.Member> updateMember({
    required String actorId,
    required m.Member current,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    DateTime? deathDate,
    m.Gender? gender,
    String? locationLabel,
    double? latitude,
    double? longitude,
    String? residenceH3,
    String? birthLocationLabel,
    double? birthLatitude,
    double? birthLongitude,
    String? birthH3,
    String? notes,
    String? photoUrl,
    String? phone,
    String? whatsapp,
    bool? isUrgent,
  }) async {
    final now = DateTime.now().toUtc();
    final updated = current.copyWith(
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      deathDate: deathDate,
      gender: gender,
      locationLabel: locationLabel,
      latitude: latitude,
      longitude: longitude,
      residenceH3: residenceH3,
      birthLocationLabel: birthLocationLabel,
      birthLatitude: birthLatitude,
      birthLongitude: birthLongitude,
      birthH3: birthH3,
      notes: notes,
      photoUrl: photoUrl,
      phone: phone,
      whatsapp: whatsapp,
      isUrgent: isUrgent,
      updatedAt: now,
    );

    final delta = <String, dynamic>{
      'id': current.id,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (birthDate != null) 'birth_date': birthDate.toIso8601String(),
      if (deathDate != null) 'death_date': deathDate.toIso8601String(),
      if (gender != null) 'gender': gender.code,
      if (locationLabel != null) 'location_label': locationLabel,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (residenceH3 != null) 'residence_h3': residenceH3,
      if (birthLocationLabel != null) 'birth_location_label': birthLocationLabel,
      if (birthLatitude != null) 'birth_latitude': birthLatitude,
      if (birthLongitude != null) 'birth_longitude': birthLongitude,
      if (birthH3 != null) 'birth_h3': birthH3,
      if (notes != null) 'notes': notes,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (isUrgent != null && isUrgent != current.isUrgent) 'is_urgent': isUrgent,
      'updated_at': now.toIso8601String(),
    };

    await _append(
      streamId: current.id,
      streamType: StreamType.member,
      eventType: EventType.memberUpdated,
      payload: delta,
      actorId: actorId,
      occurredAt: now,
    );

    await _db.upsertMember(_memberToCompanion(updated));
    return updated;
  }

  Future<void> deleteMember({
    required String actorId,
    required String memberId,
  }) async {
    final now = DateTime.now().toUtc();

    await _append(
      streamId: memberId,
      streamType: StreamType.member,
      eventType: EventType.memberDeleted,
      payload: {'id': memberId},
      actorId: actorId,
      occurredAt: now,
    );

    final rels = await _db.getRelationshipsForMember(memberId);
    for (final rel in rels) {
      await _db.deleteRelationship(rel.id);
    }
    await _db.deleteMember(memberId);
  }

  // -------------------------------------------------------------------------
  // Relationship commands
  // -------------------------------------------------------------------------

  Future<r.Relationship?> createRelationship({
    required String actorId,
    required String sourceId,
    required String targetId,
    required r.RelType relType,
  }) async {
    final existing = await _db.getAllRelationships();
    final duplicate = existing.any((rel) =>
        rel.sourceId == sourceId &&
        rel.targetId == targetId &&
        rel.relType == relType.code);

    if (duplicate) return null;

    final id = const Uuid().v4().substring(0, 7);
    final now = DateTime.now().toUtc();

    final relationship = r.Relationship(
      id: id,
      sourceId: sourceId,
      targetId: targetId,
      relType: relType,
      createdAt: now,
    );

    await _append(
      streamId: id,
      streamType: StreamType.relationship,
      eventType: EventType.relationshipCreated,
      payload: relationship.toJson(),
      actorId: actorId,
      occurredAt: now,
    );

    await _db.upsertRelationship(_relToCompanion(relationship));
    return relationship;
  }

  Future<void> deleteRelationship({
    required String actorId,
    required String relationshipId,
  }) async {
    final now = DateTime.now().toUtc();

    await _append(
      streamId: relationshipId,
      streamType: StreamType.relationship,
      eventType: EventType.relationshipDeleted,
      payload: {'id': relationshipId},
      actorId: actorId,
      occurredAt: now,
    );

    await _db.deleteRelationship(relationshipId);
  }

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  Future<void> _append({
    required String streamId,
    required StreamType streamType,
    required EventType eventType,
    required Map<String, dynamic> payload,
    required String actorId,
    required DateTime occurredAt,
  }) async {
    await _db.appendEvent(EventsCompanion(
      id: Value(const Uuid().v4().replaceAll('-', '').substring(0, 12)),
      streamId: Value(streamId),
      streamType: Value(streamType.code),
      eventType: Value(eventType.code),
      payloadJson: Value(jsonEncode(payload)),
      actorId: Value(actorId),
      occurredAt: Value(occurredAt),
      synced: const Value(false),
    ));
  }

  MembersCompanion _memberToCompanion(m.Member member) => MembersCompanion(
        id: Value(member.id),
        firstName: Value(member.firstName),
        lastName: Value(member.lastName),
        birthDate: Value(member.birthDate),
        deathDate: Value(member.deathDate),
        gender: Value(member.gender.code),
        locationLabel: Value(member.locationLabel),
        latitude: Value(member.latitude),
        longitude: Value(member.longitude),
        residenceH3: Value(member.residenceH3),
        birthLocationLabel: Value(member.birthLocationLabel),
        birthLatitude: Value(member.birthLatitude),
        birthLongitude: Value(member.birthLongitude),
        birthH3: Value(member.birthH3),
        notes: Value(member.notes),
        photoUrl: Value(member.photoUrl),
        phone: Value(member.phone),
        whatsapp: Value(member.whatsapp),
        isUrgent: Value(member.isUrgent),
        createdAt: Value(member.createdAt),
        updatedAt: Value(member.updatedAt),
      );

  RelationshipsCompanion _relToCompanion(r.Relationship rel) =>
      RelationshipsCompanion(
        id: Value(rel.id),
        sourceId: Value(rel.sourceId),
        targetId: Value(rel.targetId),
        relType: Value(rel.relType.code),
        lastContactAt: Value(rel.lastContactAt),
        relNotes: Value(rel.notes),
        salience: Value(rel.salience),
        interventionMode: Value(rel.interventionMode.code),
        createdAt: Value(rel.createdAt),
      );

  Future<r.Relationship> updateRelationship({
    required String actorId,
    required r.Relationship current,
    DateTime? lastContactAt,
    String? notes,
    double? salience,
    r.InterventionMode? interventionMode,
  }) async {
    final now = DateTime.now().toUtc();
    final updated = r.Relationship(
      id: current.id,
      sourceId: current.sourceId,
      targetId: current.targetId,
      relType: current.relType,
      lastContactAt: lastContactAt ?? current.lastContactAt,
      notes: notes ?? current.notes,
      salience: salience ?? current.salience,
      interventionMode: interventionMode ?? current.interventionMode,
      createdAt: current.createdAt,
    );

    final delta = <String, dynamic>{
      'id': current.id,
      if (lastContactAt != null) 'last_contact_at': lastContactAt.toIso8601String(),
      if (notes != null) 'notes': notes,
      if (salience != null) 'salience': salience,
      if (interventionMode != null) 'intervention_mode': interventionMode.code,
      'updated_at': now.toIso8601String(),
    };

    await _append(
      streamId: current.id,
      streamType: StreamType.relationship,
      eventType: EventType.relationshipCreated, // reuse — update recorded in event log
      payload: delta,
      actorId: actorId,
      occurredAt: now,
    );

    await _db.upsertRelationship(_relToCompanion(updated));
    return updated;
  }

  Future<LifeEvent> addLifeEvent({
    required String actorId,
    required String memberId,
    required LifeEventType eventType,
    required DateTime occurredAt,
    String? notes,
  }) async {
    final id = const Uuid().v4().substring(0, 7);
    final now = DateTime.now().toUtc();

    final event = LifeEvent(
      id: id,
      memberId: memberId,
      eventType: eventType,
      occurredAt: occurredAt,
      notes: notes,
      createdAt: now,
    );

    await _append(
      streamId: memberId,
      streamType: StreamType.member,
      eventType: EventType.memberUpdated,
      payload: event.toJson(),
      actorId: actorId,
      occurredAt: now,
    );

    await _db.insertLifeEvent(LifeEventsCompanion(
      id: Value(id),
      memberId: Value(memberId),
      eventType: Value(eventType.code),
      occurredAt: Value(occurredAt),
      notes: Value(notes),
      createdAt: Value(now),
    ));

    return event;
  }
}
