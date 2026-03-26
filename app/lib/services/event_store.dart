// EventStore — writes go directly to the API.
// After each write, onDataChanged() is called to trigger Riverpod refresh.

import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import 'dart:typed_data';
import '../services/api_service.dart';
import '../models/member.dart' as m;
import '../models/relationship.dart' as r;
import '../models/attachment.dart';
import '../models/life_event.dart';
import '../db/database.dart';

class EventStore {
  EventStore(this._api, {this.onDataChanged, SilatDatabase? db}) : _db = db;

  final ApiService _api;
  final VoidCallback? onDataChanged;
  final SilatDatabase? _db;

  void _notify() => onDataChanged?.call();

  // ── Member commands ───────────────────────────────────────────────────────

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
    final member = await _api.createMember(
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
    );
    _notify();
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
    final fields = <String, dynamic>{
      if (firstName != null) 'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate?.toIso8601String(),
      'death_date': deathDate?.toIso8601String(),
      if (gender != null) 'gender': gender.code,
      'location_label': locationLabel,
      'latitude': latitude,
      'longitude': longitude,
      'residence_h3': residenceH3,
      'birth_location_label': birthLocationLabel,
      'birth_latitude': birthLatitude,
      'birth_longitude': birthLongitude,
      'birth_h3': birthH3,
      'notes': notes,
      'photo_url': photoUrl,
      'phone': phone,
      'whatsapp': whatsapp,
      if (isUrgent != null) 'is_urgent': isUrgent,
    };
    final updated = await _api.updateMember(current.id, fields);
    _notify();
    return updated;
  }

  Future<void> deleteMember({
    required String actorId,
    required String memberId,
  }) async {
    await _api.deleteMember(memberId);
    _notify();
  }

  // ── Relationship commands ─────────────────────────────────────────────────

  Future<r.Relationship?> createRelationship({
    required String actorId,
    required String sourceId,
    required String targetId,
    required r.RelType relType,
  }) async {
    final rel = await _api.createRelationship(
      sourceId: sourceId,
      targetId: targetId,
      relType: relType,
    );
    if (rel != null) _notify();
    return rel;
  }

  Future<void> deleteRelationship({
    required String actorId,
    required String relationshipId,
  }) async {
    await _api.deleteRelationship(relationshipId);
    _notify();
  }

  Future<r.Relationship> updateRelationship({
    required String actorId,
    required r.Relationship current,
    DateTime? lastContactAt,
    String? notes,
    double? salience,
    r.InterventionMode? interventionMode,
  }) async {
    final updated = await _api.updateRelationship(
      current.id,
      lastContactAt: lastContactAt,
      notes: notes,
      salience: salience,
      interventionMode: interventionMode,
    );
    _notify();
    return updated;
  }

  // ── Claim commands ────────────────────────────────────────────────────────

  Future<m.Member> sendClaimInvite({
    required String actorId,
    required m.Member member,
  }) async {
    final updated = await _api.sendClaimInvite(member.id);
    _notify();
    return updated;
  }

  Future<m.Member> claimProfile({
    required String actorId,
    required m.Member member,
    required String token,
  }) async {
    final updated = await _api.claimProfile(token);
    _notify();
    return updated;
  }

  Future<m.Member> claimSelf({
    required String actorId,
    required m.Member member,
  }) async {
    final updated = await _api.claimSelf(member.id);
    _notify();
    return updated;
  }

  Future<m.Member> revokeClaimInvite({
    required String actorId,
    required m.Member member,
  }) async {
    final updated = await _api.revokeClaimInvite(member.id);
    _notify();
    return updated;
  }

  Future<m.Member> sendStewardshipInvite({
    required String actorId,
    required m.Member member,
  }) async {
    final updated = await _api.sendStewardshipInvite(member.id);
    _notify();
    return updated;
  }

  Future<m.Member> claimStewardship({
    required String actorId,
    required m.Member member,
    required String token,
  }) async {
    final updated = await _api.claimProfile(token, steward: true);
    _notify();
    return updated;
  }

  Future<m.Member> revokeStewardship({
    required String actorId,
    required m.Member member,
  }) async {
    final updated = await _api.revokeStewardship(member.id);
    _notify();
    return updated;
  }

  // ── Attachments ───────────────────────────────────────────────────────────

  Future<List<Attachment>> getAttachments(String memberId) =>
      _api.getAttachments(memberId);

  Future<Attachment> uploadAttachment({
    required String actorId,
    required String memberId,
    required String filename,
    required String mimeType,
    required Uint8List bytes,
    String? caption,
  }) async {
    final att = await _api.uploadAttachment(
      memberId: memberId,
      filename: filename,
      mimeType: mimeType,
      bytes: bytes,
      caption: caption,
    );
    _notify();
    return att;
  }

  Future<void> deleteAttachment({
    required String actorId,
    required String attachmentId,
  }) async {
    await _api.deleteAttachment(attachmentId);
    _notify();
  }

  // ── Life events (still local Drift for now) ───────────────────────────────

  Future<void> addLifeEvent({
    required String actorId,
    required String memberId,
    required LifeEventType eventType,
    required DateTime occurredAt,
    String? notes,
  }) async {
    if (_db == null) return;
    final id = const Uuid().v4().substring(0, 8);
    final now = DateTime.now().toUtc();
    await _db.insertLifeEvent(LifeEventsCompanion(
      id: Value(id),
      memberId: Value(memberId),
      eventType: Value(eventType.code),
      occurredAt: Value(occurredAt),
      notes: Value(notes),
      createdAt: Value(now),
    ));
  }
}
