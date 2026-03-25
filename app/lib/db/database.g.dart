// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $EventsTable extends Events with TableInfo<$EventsTable, EventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _streamIdMeta =
      const VerificationMeta('streamId');
  @override
  late final GeneratedColumn<String> streamId = GeneratedColumn<String>(
      'stream_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _streamTypeMeta =
      const VerificationMeta('streamType');
  @override
  late final GeneratedColumn<String> streamType = GeneratedColumn<String>(
      'stream_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actorIdMeta =
      const VerificationMeta('actorId');
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
      'actor_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _occurredAtMeta =
      const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
      'occurred_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        streamId,
        streamType,
        eventType,
        payloadJson,
        actorId,
        occurredAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(Insertable<EventRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('stream_id')) {
      context.handle(_streamIdMeta,
          streamId.isAcceptableOrUnknown(data['stream_id']!, _streamIdMeta));
    } else if (isInserting) {
      context.missing(_streamIdMeta);
    }
    if (data.containsKey('stream_type')) {
      context.handle(
          _streamTypeMeta,
          streamType.isAcceptableOrUnknown(
              data['stream_type']!, _streamTypeMeta));
    } else if (isInserting) {
      context.missing(_streamTypeMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(_actorIdMeta,
          actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta));
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
          _occurredAtMeta,
          occurredAt.isAcceptableOrUnknown(
              data['occurred_at']!, _occurredAtMeta));
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      streamId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stream_id'])!,
      streamType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stream_type'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      actorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}actor_id'])!,
      occurredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class EventRow extends DataClass implements Insertable<EventRow> {
  final String id;
  final String streamId;
  final String streamType;
  final String eventType;
  final String payloadJson;
  final String actorId;
  final DateTime occurredAt;
  final bool synced;
  const EventRow(
      {required this.id,
      required this.streamId,
      required this.streamType,
      required this.eventType,
      required this.payloadJson,
      required this.actorId,
      required this.occurredAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['stream_id'] = Variable<String>(streamId);
    map['stream_type'] = Variable<String>(streamType);
    map['event_type'] = Variable<String>(eventType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['actor_id'] = Variable<String>(actorId);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      streamId: Value(streamId),
      streamType: Value(streamType),
      eventType: Value(eventType),
      payloadJson: Value(payloadJson),
      actorId: Value(actorId),
      occurredAt: Value(occurredAt),
      synced: Value(synced),
    );
  }

  factory EventRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventRow(
      id: serializer.fromJson<String>(json['id']),
      streamId: serializer.fromJson<String>(json['streamId']),
      streamType: serializer.fromJson<String>(json['streamType']),
      eventType: serializer.fromJson<String>(json['eventType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      actorId: serializer.fromJson<String>(json['actorId']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'streamId': serializer.toJson<String>(streamId),
      'streamType': serializer.toJson<String>(streamType),
      'eventType': serializer.toJson<String>(eventType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'actorId': serializer.toJson<String>(actorId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  EventRow copyWith(
          {String? id,
          String? streamId,
          String? streamType,
          String? eventType,
          String? payloadJson,
          String? actorId,
          DateTime? occurredAt,
          bool? synced}) =>
      EventRow(
        id: id ?? this.id,
        streamId: streamId ?? this.streamId,
        streamType: streamType ?? this.streamType,
        eventType: eventType ?? this.eventType,
        payloadJson: payloadJson ?? this.payloadJson,
        actorId: actorId ?? this.actorId,
        occurredAt: occurredAt ?? this.occurredAt,
        synced: synced ?? this.synced,
      );
  EventRow copyWithCompanion(EventsCompanion data) {
    return EventRow(
      id: data.id.present ? data.id.value : this.id,
      streamId: data.streamId.present ? data.streamId.value : this.streamId,
      streamType:
          data.streamType.present ? data.streamType.value : this.streamType,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventRow(')
          ..write('id: $id, ')
          ..write('streamId: $streamId, ')
          ..write('streamType: $streamType, ')
          ..write('eventType: $eventType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('actorId: $actorId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, streamId, streamType, eventType,
      payloadJson, actorId, occurredAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventRow &&
          other.id == this.id &&
          other.streamId == this.streamId &&
          other.streamType == this.streamType &&
          other.eventType == this.eventType &&
          other.payloadJson == this.payloadJson &&
          other.actorId == this.actorId &&
          other.occurredAt == this.occurredAt &&
          other.synced == this.synced);
}

class EventsCompanion extends UpdateCompanion<EventRow> {
  final Value<String> id;
  final Value<String> streamId;
  final Value<String> streamType;
  final Value<String> eventType;
  final Value<String> payloadJson;
  final Value<String> actorId;
  final Value<DateTime> occurredAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.streamId = const Value.absent(),
    this.streamType = const Value.absent(),
    this.eventType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.actorId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String streamId,
    required String streamType,
    required String eventType,
    required String payloadJson,
    required String actorId,
    required DateTime occurredAt,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        streamId = Value(streamId),
        streamType = Value(streamType),
        eventType = Value(eventType),
        payloadJson = Value(payloadJson),
        actorId = Value(actorId),
        occurredAt = Value(occurredAt);
  static Insertable<EventRow> custom({
    Expression<String>? id,
    Expression<String>? streamId,
    Expression<String>? streamType,
    Expression<String>? eventType,
    Expression<String>? payloadJson,
    Expression<String>? actorId,
    Expression<DateTime>? occurredAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (streamId != null) 'stream_id': streamId,
      if (streamType != null) 'stream_type': streamType,
      if (eventType != null) 'event_type': eventType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (actorId != null) 'actor_id': actorId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? streamId,
      Value<String>? streamType,
      Value<String>? eventType,
      Value<String>? payloadJson,
      Value<String>? actorId,
      Value<DateTime>? occurredAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return EventsCompanion(
      id: id ?? this.id,
      streamId: streamId ?? this.streamId,
      streamType: streamType ?? this.streamType,
      eventType: eventType ?? this.eventType,
      payloadJson: payloadJson ?? this.payloadJson,
      actorId: actorId ?? this.actorId,
      occurredAt: occurredAt ?? this.occurredAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (streamId.present) {
      map['stream_id'] = Variable<String>(streamId.value);
    }
    if (streamType.present) {
      map['stream_type'] = Variable<String>(streamType.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('streamId: $streamId, ')
          ..write('streamType: $streamType, ')
          ..write('eventType: $eventType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('actorId: $actorId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembersTable extends Members with TableInfo<$MembersTable, MemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
      'birth_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deathDateMeta =
      const VerificationMeta('deathDate');
  @override
  late final GeneratedColumn<DateTime> deathDate = GeneratedColumn<DateTime>(
      'death_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _locationLabelMeta =
      const VerificationMeta('locationLabel');
  @override
  late final GeneratedColumn<String> locationLabel = GeneratedColumn<String>(
      'location_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _residenceH3Meta =
      const VerificationMeta('residenceH3');
  @override
  late final GeneratedColumn<String> residenceH3 = GeneratedColumn<String>(
      'residence_h3', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _birthLocationLabelMeta =
      const VerificationMeta('birthLocationLabel');
  @override
  late final GeneratedColumn<String> birthLocationLabel =
      GeneratedColumn<String>('birth_location_label', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _birthLatitudeMeta =
      const VerificationMeta('birthLatitude');
  @override
  late final GeneratedColumn<double> birthLatitude = GeneratedColumn<double>(
      'birth_latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _birthLongitudeMeta =
      const VerificationMeta('birthLongitude');
  @override
  late final GeneratedColumn<double> birthLongitude = GeneratedColumn<double>(
      'birth_longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _birthH3Meta =
      const VerificationMeta('birthH3');
  @override
  late final GeneratedColumn<String> birthH3 = GeneratedColumn<String>(
      'birth_h3', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoUrlMeta =
      const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
      'photo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _whatsappMeta =
      const VerificationMeta('whatsapp');
  @override
  late final GeneratedColumn<String> whatsapp = GeneratedColumn<String>(
      'whatsapp', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isUrgentMeta =
      const VerificationMeta('isUrgent');
  @override
  late final GeneratedColumn<bool> isUrgent = GeneratedColumn<bool>(
      'is_urgent', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_urgent" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _claimStateMeta =
      const VerificationMeta('claimState');
  @override
  late final GeneratedColumn<String> claimState = GeneratedColumn<String>(
      'claim_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('seeded'));
  static const VerificationMeta _ownerUserIdMeta =
      const VerificationMeta('ownerUserId');
  @override
  late final GeneratedColumn<String> ownerUserId = GeneratedColumn<String>(
      'owner_user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _claimTokenMeta =
      const VerificationMeta('claimToken');
  @override
  late final GeneratedColumn<String> claimToken = GeneratedColumn<String>(
      'claim_token', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stewardshipStateMeta =
      const VerificationMeta('stewardshipState');
  @override
  late final GeneratedColumn<String> stewardshipState = GeneratedColumn<String>(
      'stewardship_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _stewardUserIdMeta =
      const VerificationMeta('stewardUserId');
  @override
  late final GeneratedColumn<String> stewardUserId = GeneratedColumn<String>(
      'steward_user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stewardClaimTokenMeta =
      const VerificationMeta('stewardClaimToken');
  @override
  late final GeneratedColumn<String> stewardClaimToken =
      GeneratedColumn<String>('steward_claim_token', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        firstName,
        lastName,
        birthDate,
        deathDate,
        gender,
        locationLabel,
        latitude,
        longitude,
        residenceH3,
        birthLocationLabel,
        birthLatitude,
        birthLongitude,
        birthH3,
        notes,
        photoUrl,
        phone,
        whatsapp,
        isUrgent,
        claimState,
        ownerUserId,
        claimToken,
        stewardshipState,
        stewardUserId,
        stewardClaimToken,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(Insertable<MemberRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    }
    if (data.containsKey('death_date')) {
      context.handle(_deathDateMeta,
          deathDate.isAcceptableOrUnknown(data['death_date']!, _deathDateMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('location_label')) {
      context.handle(
          _locationLabelMeta,
          locationLabel.isAcceptableOrUnknown(
              data['location_label']!, _locationLabelMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('residence_h3')) {
      context.handle(
          _residenceH3Meta,
          residenceH3.isAcceptableOrUnknown(
              data['residence_h3']!, _residenceH3Meta));
    }
    if (data.containsKey('birth_location_label')) {
      context.handle(
          _birthLocationLabelMeta,
          birthLocationLabel.isAcceptableOrUnknown(
              data['birth_location_label']!, _birthLocationLabelMeta));
    }
    if (data.containsKey('birth_latitude')) {
      context.handle(
          _birthLatitudeMeta,
          birthLatitude.isAcceptableOrUnknown(
              data['birth_latitude']!, _birthLatitudeMeta));
    }
    if (data.containsKey('birth_longitude')) {
      context.handle(
          _birthLongitudeMeta,
          birthLongitude.isAcceptableOrUnknown(
              data['birth_longitude']!, _birthLongitudeMeta));
    }
    if (data.containsKey('birth_h3')) {
      context.handle(_birthH3Meta,
          birthH3.isAcceptableOrUnknown(data['birth_h3']!, _birthH3Meta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('whatsapp')) {
      context.handle(_whatsappMeta,
          whatsapp.isAcceptableOrUnknown(data['whatsapp']!, _whatsappMeta));
    }
    if (data.containsKey('is_urgent')) {
      context.handle(_isUrgentMeta,
          isUrgent.isAcceptableOrUnknown(data['is_urgent']!, _isUrgentMeta));
    }
    if (data.containsKey('claim_state')) {
      context.handle(
          _claimStateMeta,
          claimState.isAcceptableOrUnknown(
              data['claim_state']!, _claimStateMeta));
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(
          _ownerUserIdMeta,
          ownerUserId.isAcceptableOrUnknown(
              data['owner_user_id']!, _ownerUserIdMeta));
    }
    if (data.containsKey('claim_token')) {
      context.handle(
          _claimTokenMeta,
          claimToken.isAcceptableOrUnknown(
              data['claim_token']!, _claimTokenMeta));
    }
    if (data.containsKey('stewardship_state')) {
      context.handle(
          _stewardshipStateMeta,
          stewardshipState.isAcceptableOrUnknown(
              data['stewardship_state']!, _stewardshipStateMeta));
    }
    if (data.containsKey('steward_user_id')) {
      context.handle(
          _stewardUserIdMeta,
          stewardUserId.isAcceptableOrUnknown(
              data['steward_user_id']!, _stewardUserIdMeta));
    }
    if (data.containsKey('steward_claim_token')) {
      context.handle(
          _stewardClaimTokenMeta,
          stewardClaimToken.isAcceptableOrUnknown(
              data['steward_claim_token']!, _stewardClaimTokenMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemberRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name']),
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date']),
      deathDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}death_date']),
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!,
      locationLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_label']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      residenceH3: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}residence_h3']),
      birthLocationLabel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}birth_location_label']),
      birthLatitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}birth_latitude']),
      birthLongitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}birth_longitude']),
      birthH3: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}birth_h3']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      whatsapp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}whatsapp']),
      isUrgent: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_urgent'])!,
      claimState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}claim_state'])!,
      ownerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_user_id']),
      claimToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}claim_token']),
      stewardshipState: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}stewardship_state'])!,
      stewardUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}steward_user_id']),
      stewardClaimToken: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}steward_claim_token']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class MemberRow extends DataClass implements Insertable<MemberRow> {
  final String id;
  final String firstName;
  final String? lastName;
  final DateTime? birthDate;
  final DateTime? deathDate;
  final String gender;
  final String? locationLabel;
  final double? latitude;
  final double? longitude;
  final String? residenceH3;
  final String? birthLocationLabel;
  final double? birthLatitude;
  final double? birthLongitude;
  final String? birthH3;
  final String? notes;
  final String? photoUrl;
  final String? phone;
  final String? whatsapp;
  final bool isUrgent;
  final String claimState;
  final String? ownerUserId;
  final String? claimToken;
  final String stewardshipState;
  final String? stewardUserId;
  final String? stewardClaimToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MemberRow(
      {required this.id,
      required this.firstName,
      this.lastName,
      this.birthDate,
      this.deathDate,
      required this.gender,
      this.locationLabel,
      this.latitude,
      this.longitude,
      this.residenceH3,
      this.birthLocationLabel,
      this.birthLatitude,
      this.birthLongitude,
      this.birthH3,
      this.notes,
      this.photoUrl,
      this.phone,
      this.whatsapp,
      required this.isUrgent,
      required this.claimState,
      this.ownerUserId,
      this.claimToken,
      required this.stewardshipState,
      this.stewardUserId,
      this.stewardClaimToken,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['first_name'] = Variable<String>(firstName);
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || deathDate != null) {
      map['death_date'] = Variable<DateTime>(deathDate);
    }
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || locationLabel != null) {
      map['location_label'] = Variable<String>(locationLabel);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || residenceH3 != null) {
      map['residence_h3'] = Variable<String>(residenceH3);
    }
    if (!nullToAbsent || birthLocationLabel != null) {
      map['birth_location_label'] = Variable<String>(birthLocationLabel);
    }
    if (!nullToAbsent || birthLatitude != null) {
      map['birth_latitude'] = Variable<double>(birthLatitude);
    }
    if (!nullToAbsent || birthLongitude != null) {
      map['birth_longitude'] = Variable<double>(birthLongitude);
    }
    if (!nullToAbsent || birthH3 != null) {
      map['birth_h3'] = Variable<String>(birthH3);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || whatsapp != null) {
      map['whatsapp'] = Variable<String>(whatsapp);
    }
    map['is_urgent'] = Variable<bool>(isUrgent);
    map['claim_state'] = Variable<String>(claimState);
    if (!nullToAbsent || ownerUserId != null) {
      map['owner_user_id'] = Variable<String>(ownerUserId);
    }
    if (!nullToAbsent || claimToken != null) {
      map['claim_token'] = Variable<String>(claimToken);
    }
    map['stewardship_state'] = Variable<String>(stewardshipState);
    if (!nullToAbsent || stewardUserId != null) {
      map['steward_user_id'] = Variable<String>(stewardUserId);
    }
    if (!nullToAbsent || stewardClaimToken != null) {
      map['steward_claim_token'] = Variable<String>(stewardClaimToken);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      firstName: Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      deathDate: deathDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deathDate),
      gender: Value(gender),
      locationLabel: locationLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(locationLabel),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      residenceH3: residenceH3 == null && nullToAbsent
          ? const Value.absent()
          : Value(residenceH3),
      birthLocationLabel: birthLocationLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(birthLocationLabel),
      birthLatitude: birthLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(birthLatitude),
      birthLongitude: birthLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(birthLongitude),
      birthH3: birthH3 == null && nullToAbsent
          ? const Value.absent()
          : Value(birthH3),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      whatsapp: whatsapp == null && nullToAbsent
          ? const Value.absent()
          : Value(whatsapp),
      isUrgent: Value(isUrgent),
      claimState: Value(claimState),
      ownerUserId: ownerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUserId),
      claimToken: claimToken == null && nullToAbsent
          ? const Value.absent()
          : Value(claimToken),
      stewardshipState: Value(stewardshipState),
      stewardUserId: stewardUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(stewardUserId),
      stewardClaimToken: stewardClaimToken == null && nullToAbsent
          ? const Value.absent()
          : Value(stewardClaimToken),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MemberRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemberRow(
      id: serializer.fromJson<String>(json['id']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      deathDate: serializer.fromJson<DateTime?>(json['deathDate']),
      gender: serializer.fromJson<String>(json['gender']),
      locationLabel: serializer.fromJson<String?>(json['locationLabel']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      residenceH3: serializer.fromJson<String?>(json['residenceH3']),
      birthLocationLabel:
          serializer.fromJson<String?>(json['birthLocationLabel']),
      birthLatitude: serializer.fromJson<double?>(json['birthLatitude']),
      birthLongitude: serializer.fromJson<double?>(json['birthLongitude']),
      birthH3: serializer.fromJson<String?>(json['birthH3']),
      notes: serializer.fromJson<String?>(json['notes']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      phone: serializer.fromJson<String?>(json['phone']),
      whatsapp: serializer.fromJson<String?>(json['whatsapp']),
      isUrgent: serializer.fromJson<bool>(json['isUrgent']),
      claimState: serializer.fromJson<String>(json['claimState']),
      ownerUserId: serializer.fromJson<String?>(json['ownerUserId']),
      claimToken: serializer.fromJson<String?>(json['claimToken']),
      stewardshipState: serializer.fromJson<String>(json['stewardshipState']),
      stewardUserId: serializer.fromJson<String?>(json['stewardUserId']),
      stewardClaimToken:
          serializer.fromJson<String?>(json['stewardClaimToken']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'deathDate': serializer.toJson<DateTime?>(deathDate),
      'gender': serializer.toJson<String>(gender),
      'locationLabel': serializer.toJson<String?>(locationLabel),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'residenceH3': serializer.toJson<String?>(residenceH3),
      'birthLocationLabel': serializer.toJson<String?>(birthLocationLabel),
      'birthLatitude': serializer.toJson<double?>(birthLatitude),
      'birthLongitude': serializer.toJson<double?>(birthLongitude),
      'birthH3': serializer.toJson<String?>(birthH3),
      'notes': serializer.toJson<String?>(notes),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'phone': serializer.toJson<String?>(phone),
      'whatsapp': serializer.toJson<String?>(whatsapp),
      'isUrgent': serializer.toJson<bool>(isUrgent),
      'claimState': serializer.toJson<String>(claimState),
      'ownerUserId': serializer.toJson<String?>(ownerUserId),
      'claimToken': serializer.toJson<String?>(claimToken),
      'stewardshipState': serializer.toJson<String>(stewardshipState),
      'stewardUserId': serializer.toJson<String?>(stewardUserId),
      'stewardClaimToken': serializer.toJson<String?>(stewardClaimToken),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MemberRow copyWith(
          {String? id,
          String? firstName,
          Value<String?> lastName = const Value.absent(),
          Value<DateTime?> birthDate = const Value.absent(),
          Value<DateTime?> deathDate = const Value.absent(),
          String? gender,
          Value<String?> locationLabel = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<String?> residenceH3 = const Value.absent(),
          Value<String?> birthLocationLabel = const Value.absent(),
          Value<double?> birthLatitude = const Value.absent(),
          Value<double?> birthLongitude = const Value.absent(),
          Value<String?> birthH3 = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> photoUrl = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> whatsapp = const Value.absent(),
          bool? isUrgent,
          String? claimState,
          Value<String?> ownerUserId = const Value.absent(),
          Value<String?> claimToken = const Value.absent(),
          String? stewardshipState,
          Value<String?> stewardUserId = const Value.absent(),
          Value<String?> stewardClaimToken = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      MemberRow(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName.present ? lastName.value : this.lastName,
        birthDate: birthDate.present ? birthDate.value : this.birthDate,
        deathDate: deathDate.present ? deathDate.value : this.deathDate,
        gender: gender ?? this.gender,
        locationLabel:
            locationLabel.present ? locationLabel.value : this.locationLabel,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        residenceH3: residenceH3.present ? residenceH3.value : this.residenceH3,
        birthLocationLabel: birthLocationLabel.present
            ? birthLocationLabel.value
            : this.birthLocationLabel,
        birthLatitude:
            birthLatitude.present ? birthLatitude.value : this.birthLatitude,
        birthLongitude:
            birthLongitude.present ? birthLongitude.value : this.birthLongitude,
        birthH3: birthH3.present ? birthH3.value : this.birthH3,
        notes: notes.present ? notes.value : this.notes,
        photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
        phone: phone.present ? phone.value : this.phone,
        whatsapp: whatsapp.present ? whatsapp.value : this.whatsapp,
        isUrgent: isUrgent ?? this.isUrgent,
        claimState: claimState ?? this.claimState,
        ownerUserId: ownerUserId.present ? ownerUserId.value : this.ownerUserId,
        claimToken: claimToken.present ? claimToken.value : this.claimToken,
        stewardshipState: stewardshipState ?? this.stewardshipState,
        stewardUserId:
            stewardUserId.present ? stewardUserId.value : this.stewardUserId,
        stewardClaimToken: stewardClaimToken.present
            ? stewardClaimToken.value
            : this.stewardClaimToken,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MemberRow copyWithCompanion(MembersCompanion data) {
    return MemberRow(
      id: data.id.present ? data.id.value : this.id,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      deathDate: data.deathDate.present ? data.deathDate.value : this.deathDate,
      gender: data.gender.present ? data.gender.value : this.gender,
      locationLabel: data.locationLabel.present
          ? data.locationLabel.value
          : this.locationLabel,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      residenceH3:
          data.residenceH3.present ? data.residenceH3.value : this.residenceH3,
      birthLocationLabel: data.birthLocationLabel.present
          ? data.birthLocationLabel.value
          : this.birthLocationLabel,
      birthLatitude: data.birthLatitude.present
          ? data.birthLatitude.value
          : this.birthLatitude,
      birthLongitude: data.birthLongitude.present
          ? data.birthLongitude.value
          : this.birthLongitude,
      birthH3: data.birthH3.present ? data.birthH3.value : this.birthH3,
      notes: data.notes.present ? data.notes.value : this.notes,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      phone: data.phone.present ? data.phone.value : this.phone,
      whatsapp: data.whatsapp.present ? data.whatsapp.value : this.whatsapp,
      isUrgent: data.isUrgent.present ? data.isUrgent.value : this.isUrgent,
      claimState:
          data.claimState.present ? data.claimState.value : this.claimState,
      ownerUserId:
          data.ownerUserId.present ? data.ownerUserId.value : this.ownerUserId,
      claimToken:
          data.claimToken.present ? data.claimToken.value : this.claimToken,
      stewardshipState: data.stewardshipState.present
          ? data.stewardshipState.value
          : this.stewardshipState,
      stewardUserId: data.stewardUserId.present
          ? data.stewardUserId.value
          : this.stewardUserId,
      stewardClaimToken: data.stewardClaimToken.present
          ? data.stewardClaimToken.value
          : this.stewardClaimToken,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemberRow(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('birthDate: $birthDate, ')
          ..write('deathDate: $deathDate, ')
          ..write('gender: $gender, ')
          ..write('locationLabel: $locationLabel, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('residenceH3: $residenceH3, ')
          ..write('birthLocationLabel: $birthLocationLabel, ')
          ..write('birthLatitude: $birthLatitude, ')
          ..write('birthLongitude: $birthLongitude, ')
          ..write('birthH3: $birthH3, ')
          ..write('notes: $notes, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('phone: $phone, ')
          ..write('whatsapp: $whatsapp, ')
          ..write('isUrgent: $isUrgent, ')
          ..write('claimState: $claimState, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('claimToken: $claimToken, ')
          ..write('stewardshipState: $stewardshipState, ')
          ..write('stewardUserId: $stewardUserId, ')
          ..write('stewardClaimToken: $stewardClaimToken, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        firstName,
        lastName,
        birthDate,
        deathDate,
        gender,
        locationLabel,
        latitude,
        longitude,
        residenceH3,
        birthLocationLabel,
        birthLatitude,
        birthLongitude,
        birthH3,
        notes,
        photoUrl,
        phone,
        whatsapp,
        isUrgent,
        claimState,
        ownerUserId,
        claimToken,
        stewardshipState,
        stewardUserId,
        stewardClaimToken,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemberRow &&
          other.id == this.id &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.birthDate == this.birthDate &&
          other.deathDate == this.deathDate &&
          other.gender == this.gender &&
          other.locationLabel == this.locationLabel &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.residenceH3 == this.residenceH3 &&
          other.birthLocationLabel == this.birthLocationLabel &&
          other.birthLatitude == this.birthLatitude &&
          other.birthLongitude == this.birthLongitude &&
          other.birthH3 == this.birthH3 &&
          other.notes == this.notes &&
          other.photoUrl == this.photoUrl &&
          other.phone == this.phone &&
          other.whatsapp == this.whatsapp &&
          other.isUrgent == this.isUrgent &&
          other.claimState == this.claimState &&
          other.ownerUserId == this.ownerUserId &&
          other.claimToken == this.claimToken &&
          other.stewardshipState == this.stewardshipState &&
          other.stewardUserId == this.stewardUserId &&
          other.stewardClaimToken == this.stewardClaimToken &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MembersCompanion extends UpdateCompanion<MemberRow> {
  final Value<String> id;
  final Value<String> firstName;
  final Value<String?> lastName;
  final Value<DateTime?> birthDate;
  final Value<DateTime?> deathDate;
  final Value<String> gender;
  final Value<String?> locationLabel;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> residenceH3;
  final Value<String?> birthLocationLabel;
  final Value<double?> birthLatitude;
  final Value<double?> birthLongitude;
  final Value<String?> birthH3;
  final Value<String?> notes;
  final Value<String?> photoUrl;
  final Value<String?> phone;
  final Value<String?> whatsapp;
  final Value<bool> isUrgent;
  final Value<String> claimState;
  final Value<String?> ownerUserId;
  final Value<String?> claimToken;
  final Value<String> stewardshipState;
  final Value<String?> stewardUserId;
  final Value<String?> stewardClaimToken;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.deathDate = const Value.absent(),
    this.gender = const Value.absent(),
    this.locationLabel = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.residenceH3 = const Value.absent(),
    this.birthLocationLabel = const Value.absent(),
    this.birthLatitude = const Value.absent(),
    this.birthLongitude = const Value.absent(),
    this.birthH3 = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.phone = const Value.absent(),
    this.whatsapp = const Value.absent(),
    this.isUrgent = const Value.absent(),
    this.claimState = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.claimToken = const Value.absent(),
    this.stewardshipState = const Value.absent(),
    this.stewardUserId = const Value.absent(),
    this.stewardClaimToken = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembersCompanion.insert({
    required String id,
    required String firstName,
    this.lastName = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.deathDate = const Value.absent(),
    this.gender = const Value.absent(),
    this.locationLabel = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.residenceH3 = const Value.absent(),
    this.birthLocationLabel = const Value.absent(),
    this.birthLatitude = const Value.absent(),
    this.birthLongitude = const Value.absent(),
    this.birthH3 = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.phone = const Value.absent(),
    this.whatsapp = const Value.absent(),
    this.isUrgent = const Value.absent(),
    this.claimState = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.claimToken = const Value.absent(),
    this.stewardshipState = const Value.absent(),
    this.stewardUserId = const Value.absent(),
    this.stewardClaimToken = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        firstName = Value(firstName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<MemberRow> custom({
    Expression<String>? id,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<DateTime>? birthDate,
    Expression<DateTime>? deathDate,
    Expression<String>? gender,
    Expression<String>? locationLabel,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? residenceH3,
    Expression<String>? birthLocationLabel,
    Expression<double>? birthLatitude,
    Expression<double>? birthLongitude,
    Expression<String>? birthH3,
    Expression<String>? notes,
    Expression<String>? photoUrl,
    Expression<String>? phone,
    Expression<String>? whatsapp,
    Expression<bool>? isUrgent,
    Expression<String>? claimState,
    Expression<String>? ownerUserId,
    Expression<String>? claimToken,
    Expression<String>? stewardshipState,
    Expression<String>? stewardUserId,
    Expression<String>? stewardClaimToken,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (birthDate != null) 'birth_date': birthDate,
      if (deathDate != null) 'death_date': deathDate,
      if (gender != null) 'gender': gender,
      if (locationLabel != null) 'location_label': locationLabel,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (residenceH3 != null) 'residence_h3': residenceH3,
      if (birthLocationLabel != null)
        'birth_location_label': birthLocationLabel,
      if (birthLatitude != null) 'birth_latitude': birthLatitude,
      if (birthLongitude != null) 'birth_longitude': birthLongitude,
      if (birthH3 != null) 'birth_h3': birthH3,
      if (notes != null) 'notes': notes,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (isUrgent != null) 'is_urgent': isUrgent,
      if (claimState != null) 'claim_state': claimState,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (claimToken != null) 'claim_token': claimToken,
      if (stewardshipState != null) 'stewardship_state': stewardshipState,
      if (stewardUserId != null) 'steward_user_id': stewardUserId,
      if (stewardClaimToken != null) 'steward_claim_token': stewardClaimToken,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembersCompanion copyWith(
      {Value<String>? id,
      Value<String>? firstName,
      Value<String?>? lastName,
      Value<DateTime?>? birthDate,
      Value<DateTime?>? deathDate,
      Value<String>? gender,
      Value<String?>? locationLabel,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String?>? residenceH3,
      Value<String?>? birthLocationLabel,
      Value<double?>? birthLatitude,
      Value<double?>? birthLongitude,
      Value<String?>? birthH3,
      Value<String?>? notes,
      Value<String?>? photoUrl,
      Value<String?>? phone,
      Value<String?>? whatsapp,
      Value<bool>? isUrgent,
      Value<String>? claimState,
      Value<String?>? ownerUserId,
      Value<String?>? claimToken,
      Value<String>? stewardshipState,
      Value<String?>? stewardUserId,
      Value<String?>? stewardClaimToken,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return MembersCompanion(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      deathDate: deathDate ?? this.deathDate,
      gender: gender ?? this.gender,
      locationLabel: locationLabel ?? this.locationLabel,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      residenceH3: residenceH3 ?? this.residenceH3,
      birthLocationLabel: birthLocationLabel ?? this.birthLocationLabel,
      birthLatitude: birthLatitude ?? this.birthLatitude,
      birthLongitude: birthLongitude ?? this.birthLongitude,
      birthH3: birthH3 ?? this.birthH3,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      isUrgent: isUrgent ?? this.isUrgent,
      claimState: claimState ?? this.claimState,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      claimToken: claimToken ?? this.claimToken,
      stewardshipState: stewardshipState ?? this.stewardshipState,
      stewardUserId: stewardUserId ?? this.stewardUserId,
      stewardClaimToken: stewardClaimToken ?? this.stewardClaimToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (deathDate.present) {
      map['death_date'] = Variable<DateTime>(deathDate.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (locationLabel.present) {
      map['location_label'] = Variable<String>(locationLabel.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (residenceH3.present) {
      map['residence_h3'] = Variable<String>(residenceH3.value);
    }
    if (birthLocationLabel.present) {
      map['birth_location_label'] = Variable<String>(birthLocationLabel.value);
    }
    if (birthLatitude.present) {
      map['birth_latitude'] = Variable<double>(birthLatitude.value);
    }
    if (birthLongitude.present) {
      map['birth_longitude'] = Variable<double>(birthLongitude.value);
    }
    if (birthH3.present) {
      map['birth_h3'] = Variable<String>(birthH3.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (whatsapp.present) {
      map['whatsapp'] = Variable<String>(whatsapp.value);
    }
    if (isUrgent.present) {
      map['is_urgent'] = Variable<bool>(isUrgent.value);
    }
    if (claimState.present) {
      map['claim_state'] = Variable<String>(claimState.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<String>(ownerUserId.value);
    }
    if (claimToken.present) {
      map['claim_token'] = Variable<String>(claimToken.value);
    }
    if (stewardshipState.present) {
      map['stewardship_state'] = Variable<String>(stewardshipState.value);
    }
    if (stewardUserId.present) {
      map['steward_user_id'] = Variable<String>(stewardUserId.value);
    }
    if (stewardClaimToken.present) {
      map['steward_claim_token'] = Variable<String>(stewardClaimToken.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('birthDate: $birthDate, ')
          ..write('deathDate: $deathDate, ')
          ..write('gender: $gender, ')
          ..write('locationLabel: $locationLabel, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('residenceH3: $residenceH3, ')
          ..write('birthLocationLabel: $birthLocationLabel, ')
          ..write('birthLatitude: $birthLatitude, ')
          ..write('birthLongitude: $birthLongitude, ')
          ..write('birthH3: $birthH3, ')
          ..write('notes: $notes, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('phone: $phone, ')
          ..write('whatsapp: $whatsapp, ')
          ..write('isUrgent: $isUrgent, ')
          ..write('claimState: $claimState, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('claimToken: $claimToken, ')
          ..write('stewardshipState: $stewardshipState, ')
          ..write('stewardUserId: $stewardUserId, ')
          ..write('stewardClaimToken: $stewardClaimToken, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RelationshipsTable extends Relationships
    with TableInfo<$RelationshipsTable, RelationshipRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelationshipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetIdMeta =
      const VerificationMeta('targetId');
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
      'target_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _relTypeMeta =
      const VerificationMeta('relType');
  @override
  late final GeneratedColumn<String> relType = GeneratedColumn<String>(
      'rel_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastContactAtMeta =
      const VerificationMeta('lastContactAt');
  @override
  late final GeneratedColumn<DateTime> lastContactAt =
      GeneratedColumn<DateTime>('last_contact_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _relNotesMeta =
      const VerificationMeta('relNotes');
  @override
  late final GeneratedColumn<String> relNotes = GeneratedColumn<String>(
      'rel_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _salienceMeta =
      const VerificationMeta('salience');
  @override
  late final GeneratedColumn<double> salience = GeneratedColumn<double>(
      'salience', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.5));
  static const VerificationMeta _interventionModeMeta =
      const VerificationMeta('interventionMode');
  @override
  late final GeneratedColumn<String> interventionMode = GeneratedColumn<String>(
      'intervention_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('passive'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sourceId,
        targetId,
        relType,
        lastContactAt,
        relNotes,
        salience,
        interventionMode,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'relationships';
  @override
  VerificationContext validateIntegrity(Insertable<RelationshipRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(_targetIdMeta,
          targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta));
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('rel_type')) {
      context.handle(_relTypeMeta,
          relType.isAcceptableOrUnknown(data['rel_type']!, _relTypeMeta));
    } else if (isInserting) {
      context.missing(_relTypeMeta);
    }
    if (data.containsKey('last_contact_at')) {
      context.handle(
          _lastContactAtMeta,
          lastContactAt.isAcceptableOrUnknown(
              data['last_contact_at']!, _lastContactAtMeta));
    }
    if (data.containsKey('rel_notes')) {
      context.handle(_relNotesMeta,
          relNotes.isAcceptableOrUnknown(data['rel_notes']!, _relNotesMeta));
    }
    if (data.containsKey('salience')) {
      context.handle(_salienceMeta,
          salience.isAcceptableOrUnknown(data['salience']!, _salienceMeta));
    }
    if (data.containsKey('intervention_mode')) {
      context.handle(
          _interventionModeMeta,
          interventionMode.isAcceptableOrUnknown(
              data['intervention_mode']!, _interventionModeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RelationshipRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RelationshipRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      targetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_id'])!,
      relType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rel_type'])!,
      lastContactAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_contact_at']),
      relNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rel_notes']),
      salience: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}salience'])!,
      interventionMode: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}intervention_mode'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RelationshipsTable createAlias(String alias) {
    return $RelationshipsTable(attachedDatabase, alias);
  }
}

class RelationshipRow extends DataClass implements Insertable<RelationshipRow> {
  final String id;
  final String sourceId;
  final String targetId;
  final String relType;
  final DateTime? lastContactAt;
  final String? relNotes;
  final double salience;
  final String interventionMode;
  final DateTime createdAt;
  const RelationshipRow(
      {required this.id,
      required this.sourceId,
      required this.targetId,
      required this.relType,
      this.lastContactAt,
      this.relNotes,
      required this.salience,
      required this.interventionMode,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['target_id'] = Variable<String>(targetId);
    map['rel_type'] = Variable<String>(relType);
    if (!nullToAbsent || lastContactAt != null) {
      map['last_contact_at'] = Variable<DateTime>(lastContactAt);
    }
    if (!nullToAbsent || relNotes != null) {
      map['rel_notes'] = Variable<String>(relNotes);
    }
    map['salience'] = Variable<double>(salience);
    map['intervention_mode'] = Variable<String>(interventionMode);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RelationshipsCompanion toCompanion(bool nullToAbsent) {
    return RelationshipsCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      targetId: Value(targetId),
      relType: Value(relType),
      lastContactAt: lastContactAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastContactAt),
      relNotes: relNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(relNotes),
      salience: Value(salience),
      interventionMode: Value(interventionMode),
      createdAt: Value(createdAt),
    );
  }

  factory RelationshipRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RelationshipRow(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      targetId: serializer.fromJson<String>(json['targetId']),
      relType: serializer.fromJson<String>(json['relType']),
      lastContactAt: serializer.fromJson<DateTime?>(json['lastContactAt']),
      relNotes: serializer.fromJson<String?>(json['relNotes']),
      salience: serializer.fromJson<double>(json['salience']),
      interventionMode: serializer.fromJson<String>(json['interventionMode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'targetId': serializer.toJson<String>(targetId),
      'relType': serializer.toJson<String>(relType),
      'lastContactAt': serializer.toJson<DateTime?>(lastContactAt),
      'relNotes': serializer.toJson<String?>(relNotes),
      'salience': serializer.toJson<double>(salience),
      'interventionMode': serializer.toJson<String>(interventionMode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RelationshipRow copyWith(
          {String? id,
          String? sourceId,
          String? targetId,
          String? relType,
          Value<DateTime?> lastContactAt = const Value.absent(),
          Value<String?> relNotes = const Value.absent(),
          double? salience,
          String? interventionMode,
          DateTime? createdAt}) =>
      RelationshipRow(
        id: id ?? this.id,
        sourceId: sourceId ?? this.sourceId,
        targetId: targetId ?? this.targetId,
        relType: relType ?? this.relType,
        lastContactAt:
            lastContactAt.present ? lastContactAt.value : this.lastContactAt,
        relNotes: relNotes.present ? relNotes.value : this.relNotes,
        salience: salience ?? this.salience,
        interventionMode: interventionMode ?? this.interventionMode,
        createdAt: createdAt ?? this.createdAt,
      );
  RelationshipRow copyWithCompanion(RelationshipsCompanion data) {
    return RelationshipRow(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      relType: data.relType.present ? data.relType.value : this.relType,
      lastContactAt: data.lastContactAt.present
          ? data.lastContactAt.value
          : this.lastContactAt,
      relNotes: data.relNotes.present ? data.relNotes.value : this.relNotes,
      salience: data.salience.present ? data.salience.value : this.salience,
      interventionMode: data.interventionMode.present
          ? data.interventionMode.value
          : this.interventionMode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipRow(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('targetId: $targetId, ')
          ..write('relType: $relType, ')
          ..write('lastContactAt: $lastContactAt, ')
          ..write('relNotes: $relNotes, ')
          ..write('salience: $salience, ')
          ..write('interventionMode: $interventionMode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sourceId, targetId, relType,
      lastContactAt, relNotes, salience, interventionMode, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RelationshipRow &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.targetId == this.targetId &&
          other.relType == this.relType &&
          other.lastContactAt == this.lastContactAt &&
          other.relNotes == this.relNotes &&
          other.salience == this.salience &&
          other.interventionMode == this.interventionMode &&
          other.createdAt == this.createdAt);
}

class RelationshipsCompanion extends UpdateCompanion<RelationshipRow> {
  final Value<String> id;
  final Value<String> sourceId;
  final Value<String> targetId;
  final Value<String> relType;
  final Value<DateTime?> lastContactAt;
  final Value<String?> relNotes;
  final Value<double> salience;
  final Value<String> interventionMode;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RelationshipsCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.targetId = const Value.absent(),
    this.relType = const Value.absent(),
    this.lastContactAt = const Value.absent(),
    this.relNotes = const Value.absent(),
    this.salience = const Value.absent(),
    this.interventionMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RelationshipsCompanion.insert({
    required String id,
    required String sourceId,
    required String targetId,
    required String relType,
    this.lastContactAt = const Value.absent(),
    this.relNotes = const Value.absent(),
    this.salience = const Value.absent(),
    this.interventionMode = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sourceId = Value(sourceId),
        targetId = Value(targetId),
        relType = Value(relType),
        createdAt = Value(createdAt);
  static Insertable<RelationshipRow> custom({
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? targetId,
    Expression<String>? relType,
    Expression<DateTime>? lastContactAt,
    Expression<String>? relNotes,
    Expression<double>? salience,
    Expression<String>? interventionMode,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (targetId != null) 'target_id': targetId,
      if (relType != null) 'rel_type': relType,
      if (lastContactAt != null) 'last_contact_at': lastContactAt,
      if (relNotes != null) 'rel_notes': relNotes,
      if (salience != null) 'salience': salience,
      if (interventionMode != null) 'intervention_mode': interventionMode,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RelationshipsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sourceId,
      Value<String>? targetId,
      Value<String>? relType,
      Value<DateTime?>? lastContactAt,
      Value<String?>? relNotes,
      Value<double>? salience,
      Value<String>? interventionMode,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return RelationshipsCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      relType: relType ?? this.relType,
      lastContactAt: lastContactAt ?? this.lastContactAt,
      relNotes: relNotes ?? this.relNotes,
      salience: salience ?? this.salience,
      interventionMode: interventionMode ?? this.interventionMode,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (relType.present) {
      map['rel_type'] = Variable<String>(relType.value);
    }
    if (lastContactAt.present) {
      map['last_contact_at'] = Variable<DateTime>(lastContactAt.value);
    }
    if (relNotes.present) {
      map['rel_notes'] = Variable<String>(relNotes.value);
    }
    if (salience.present) {
      map['salience'] = Variable<double>(salience.value);
    }
    if (interventionMode.present) {
      map['intervention_mode'] = Variable<String>(interventionMode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipsCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('targetId: $targetId, ')
          ..write('relType: $relType, ')
          ..write('lastContactAt: $lastContactAt, ')
          ..write('relNotes: $relNotes, ')
          ..write('salience: $salience, ')
          ..write('interventionMode: $interventionMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeEventsTable extends LifeEvents
    with TableInfo<$LifeEventsTable, LifeEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _memberIdMeta =
      const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
      'member_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _occurredAtMeta =
      const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
      'occurred_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, memberId, eventType, occurredAt, notes, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'life_events';
  @override
  VerificationContext validateIntegrity(Insertable<LifeEventRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta,
          memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
          _occurredAtMeta,
          occurredAt.isAcceptableOrUnknown(
              data['occurred_at']!, _occurredAtMeta));
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LifeEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeEventRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      memberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_id'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      occurredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_at'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LifeEventsTable createAlias(String alias) {
    return $LifeEventsTable(attachedDatabase, alias);
  }
}

class LifeEventRow extends DataClass implements Insertable<LifeEventRow> {
  final String id;
  final String memberId;
  final String eventType;
  final DateTime occurredAt;
  final String? notes;
  final DateTime createdAt;
  const LifeEventRow(
      {required this.id,
      required this.memberId,
      required this.eventType,
      required this.occurredAt,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['member_id'] = Variable<String>(memberId);
    map['event_type'] = Variable<String>(eventType);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LifeEventsCompanion toCompanion(bool nullToAbsent) {
    return LifeEventsCompanion(
      id: Value(id),
      memberId: Value(memberId),
      eventType: Value(eventType),
      occurredAt: Value(occurredAt),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory LifeEventRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeEventRow(
      id: serializer.fromJson<String>(json['id']),
      memberId: serializer.fromJson<String>(json['memberId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memberId': serializer.toJson<String>(memberId),
      'eventType': serializer.toJson<String>(eventType),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LifeEventRow copyWith(
          {String? id,
          String? memberId,
          String? eventType,
          DateTime? occurredAt,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      LifeEventRow(
        id: id ?? this.id,
        memberId: memberId ?? this.memberId,
        eventType: eventType ?? this.eventType,
        occurredAt: occurredAt ?? this.occurredAt,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  LifeEventRow copyWithCompanion(LifeEventsCompanion data) {
    return LifeEventRow(
      id: data.id.present ? data.id.value : this.id,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventRow(')
          ..write('id: $id, ')
          ..write('memberId: $memberId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, memberId, eventType, occurredAt, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeEventRow &&
          other.id == this.id &&
          other.memberId == this.memberId &&
          other.eventType == this.eventType &&
          other.occurredAt == this.occurredAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class LifeEventsCompanion extends UpdateCompanion<LifeEventRow> {
  final Value<String> id;
  final Value<String> memberId;
  final Value<String> eventType;
  final Value<DateTime> occurredAt;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LifeEventsCompanion({
    this.id = const Value.absent(),
    this.memberId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeEventsCompanion.insert({
    required String id,
    required String memberId,
    required String eventType,
    required DateTime occurredAt,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        memberId = Value(memberId),
        eventType = Value(eventType),
        occurredAt = Value(occurredAt),
        createdAt = Value(createdAt);
  static Insertable<LifeEventRow> custom({
    Expression<String>? id,
    Expression<String>? memberId,
    Expression<String>? eventType,
    Expression<DateTime>? occurredAt,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memberId != null) 'member_id': memberId,
      if (eventType != null) 'event_type': eventType,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? memberId,
      Value<String>? eventType,
      Value<DateTime>? occurredAt,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return LifeEventsCompanion(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      eventType: eventType ?? this.eventType,
      occurredAt: occurredAt ?? this.occurredAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeEventsCompanion(')
          ..write('id: $id, ')
          ..write('memberId: $memberId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$SilatDatabase extends GeneratedDatabase {
  _$SilatDatabase(QueryExecutor e) : super(e);
  $SilatDatabaseManager get managers => $SilatDatabaseManager(this);
  late final $EventsTable events = $EventsTable(this);
  late final $MembersTable members = $MembersTable(this);
  late final $RelationshipsTable relationships = $RelationshipsTable(this);
  late final $LifeEventsTable lifeEvents = $LifeEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [events, members, relationships, lifeEvents];
}

typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  required String id,
  required String streamId,
  required String streamType,
  required String eventType,
  required String payloadJson,
  required String actorId,
  required DateTime occurredAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<String> id,
  Value<String> streamId,
  Value<String> streamType,
  Value<String> eventType,
  Value<String> payloadJson,
  Value<String> actorId,
  Value<DateTime> occurredAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$EventsTableFilterComposer
    extends Composer<_$SilatDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get streamId => $composableBuilder(
      column: $table.streamId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get streamType => $composableBuilder(
      column: $table.streamType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actorId => $composableBuilder(
      column: $table.actorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$EventsTableOrderingComposer
    extends Composer<_$SilatDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get streamId => $composableBuilder(
      column: $table.streamId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get streamType => $composableBuilder(
      column: $table.streamType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actorId => $composableBuilder(
      column: $table.actorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$EventsTableAnnotationComposer
    extends Composer<_$SilatDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get streamId =>
      $composableBuilder(column: $table.streamId, builder: (column) => column);

  GeneratedColumn<String> get streamType => $composableBuilder(
      column: $table.streamType, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$EventsTableTableManager extends RootTableManager<
    _$SilatDatabase,
    $EventsTable,
    EventRow,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (EventRow, BaseReferences<_$SilatDatabase, $EventsTable, EventRow>),
    EventRow,
    PrefetchHooks Function()> {
  $$EventsTableTableManager(_$SilatDatabase db, $EventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> streamId = const Value.absent(),
            Value<String> streamType = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String> actorId = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion(
            id: id,
            streamId: streamId,
            streamType: streamType,
            eventType: eventType,
            payloadJson: payloadJson,
            actorId: actorId,
            occurredAt: occurredAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String streamId,
            required String streamType,
            required String eventType,
            required String payloadJson,
            required String actorId,
            required DateTime occurredAt,
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion.insert(
            id: id,
            streamId: streamId,
            streamType: streamType,
            eventType: eventType,
            payloadJson: payloadJson,
            actorId: actorId,
            occurredAt: occurredAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EventsTableProcessedTableManager = ProcessedTableManager<
    _$SilatDatabase,
    $EventsTable,
    EventRow,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (EventRow, BaseReferences<_$SilatDatabase, $EventsTable, EventRow>),
    EventRow,
    PrefetchHooks Function()>;
typedef $$MembersTableCreateCompanionBuilder = MembersCompanion Function({
  required String id,
  required String firstName,
  Value<String?> lastName,
  Value<DateTime?> birthDate,
  Value<DateTime?> deathDate,
  Value<String> gender,
  Value<String?> locationLabel,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> residenceH3,
  Value<String?> birthLocationLabel,
  Value<double?> birthLatitude,
  Value<double?> birthLongitude,
  Value<String?> birthH3,
  Value<String?> notes,
  Value<String?> photoUrl,
  Value<String?> phone,
  Value<String?> whatsapp,
  Value<bool> isUrgent,
  Value<String> claimState,
  Value<String?> ownerUserId,
  Value<String?> claimToken,
  Value<String> stewardshipState,
  Value<String?> stewardUserId,
  Value<String?> stewardClaimToken,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$MembersTableUpdateCompanionBuilder = MembersCompanion Function({
  Value<String> id,
  Value<String> firstName,
  Value<String?> lastName,
  Value<DateTime?> birthDate,
  Value<DateTime?> deathDate,
  Value<String> gender,
  Value<String?> locationLabel,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> residenceH3,
  Value<String?> birthLocationLabel,
  Value<double?> birthLatitude,
  Value<double?> birthLongitude,
  Value<String?> birthH3,
  Value<String?> notes,
  Value<String?> photoUrl,
  Value<String?> phone,
  Value<String?> whatsapp,
  Value<bool> isUrgent,
  Value<String> claimState,
  Value<String?> ownerUserId,
  Value<String?> claimToken,
  Value<String> stewardshipState,
  Value<String?> stewardUserId,
  Value<String?> stewardClaimToken,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$MembersTableFilterComposer
    extends Composer<_$SilatDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deathDate => $composableBuilder(
      column: $table.deathDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationLabel => $composableBuilder(
      column: $table.locationLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get residenceH3 => $composableBuilder(
      column: $table.residenceH3, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get birthLocationLabel => $composableBuilder(
      column: $table.birthLocationLabel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get birthLatitude => $composableBuilder(
      column: $table.birthLatitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get birthLongitude => $composableBuilder(
      column: $table.birthLongitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get birthH3 => $composableBuilder(
      column: $table.birthH3, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get whatsapp => $composableBuilder(
      column: $table.whatsapp, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUrgent => $composableBuilder(
      column: $table.isUrgent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get claimState => $composableBuilder(
      column: $table.claimState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get claimToken => $composableBuilder(
      column: $table.claimToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stewardshipState => $composableBuilder(
      column: $table.stewardshipState,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stewardUserId => $composableBuilder(
      column: $table.stewardUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stewardClaimToken => $composableBuilder(
      column: $table.stewardClaimToken,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MembersTableOrderingComposer
    extends Composer<_$SilatDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deathDate => $composableBuilder(
      column: $table.deathDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationLabel => $composableBuilder(
      column: $table.locationLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get residenceH3 => $composableBuilder(
      column: $table.residenceH3, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get birthLocationLabel => $composableBuilder(
      column: $table.birthLocationLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get birthLatitude => $composableBuilder(
      column: $table.birthLatitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get birthLongitude => $composableBuilder(
      column: $table.birthLongitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get birthH3 => $composableBuilder(
      column: $table.birthH3, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get whatsapp => $composableBuilder(
      column: $table.whatsapp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUrgent => $composableBuilder(
      column: $table.isUrgent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get claimState => $composableBuilder(
      column: $table.claimState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get claimToken => $composableBuilder(
      column: $table.claimToken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stewardshipState => $composableBuilder(
      column: $table.stewardshipState,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stewardUserId => $composableBuilder(
      column: $table.stewardUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stewardClaimToken => $composableBuilder(
      column: $table.stewardClaimToken,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MembersTableAnnotationComposer
    extends Composer<_$SilatDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<DateTime> get deathDate =>
      $composableBuilder(column: $table.deathDate, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get locationLabel => $composableBuilder(
      column: $table.locationLabel, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get residenceH3 => $composableBuilder(
      column: $table.residenceH3, builder: (column) => column);

  GeneratedColumn<String> get birthLocationLabel => $composableBuilder(
      column: $table.birthLocationLabel, builder: (column) => column);

  GeneratedColumn<double> get birthLatitude => $composableBuilder(
      column: $table.birthLatitude, builder: (column) => column);

  GeneratedColumn<double> get birthLongitude => $composableBuilder(
      column: $table.birthLongitude, builder: (column) => column);

  GeneratedColumn<String> get birthH3 =>
      $composableBuilder(column: $table.birthH3, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get whatsapp =>
      $composableBuilder(column: $table.whatsapp, builder: (column) => column);

  GeneratedColumn<bool> get isUrgent =>
      $composableBuilder(column: $table.isUrgent, builder: (column) => column);

  GeneratedColumn<String> get claimState => $composableBuilder(
      column: $table.claimState, builder: (column) => column);

  GeneratedColumn<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => column);

  GeneratedColumn<String> get claimToken => $composableBuilder(
      column: $table.claimToken, builder: (column) => column);

  GeneratedColumn<String> get stewardshipState => $composableBuilder(
      column: $table.stewardshipState, builder: (column) => column);

  GeneratedColumn<String> get stewardUserId => $composableBuilder(
      column: $table.stewardUserId, builder: (column) => column);

  GeneratedColumn<String> get stewardClaimToken => $composableBuilder(
      column: $table.stewardClaimToken, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MembersTableTableManager extends RootTableManager<
    _$SilatDatabase,
    $MembersTable,
    MemberRow,
    $$MembersTableFilterComposer,
    $$MembersTableOrderingComposer,
    $$MembersTableAnnotationComposer,
    $$MembersTableCreateCompanionBuilder,
    $$MembersTableUpdateCompanionBuilder,
    (MemberRow, BaseReferences<_$SilatDatabase, $MembersTable, MemberRow>),
    MemberRow,
    PrefetchHooks Function()> {
  $$MembersTableTableManager(_$SilatDatabase db, $MembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> firstName = const Value.absent(),
            Value<String?> lastName = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<DateTime?> deathDate = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<String?> locationLabel = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> residenceH3 = const Value.absent(),
            Value<String?> birthLocationLabel = const Value.absent(),
            Value<double?> birthLatitude = const Value.absent(),
            Value<double?> birthLongitude = const Value.absent(),
            Value<String?> birthH3 = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> whatsapp = const Value.absent(),
            Value<bool> isUrgent = const Value.absent(),
            Value<String> claimState = const Value.absent(),
            Value<String?> ownerUserId = const Value.absent(),
            Value<String?> claimToken = const Value.absent(),
            Value<String> stewardshipState = const Value.absent(),
            Value<String?> stewardUserId = const Value.absent(),
            Value<String?> stewardClaimToken = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MembersCompanion(
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
            claimState: claimState,
            ownerUserId: ownerUserId,
            claimToken: claimToken,
            stewardshipState: stewardshipState,
            stewardUserId: stewardUserId,
            stewardClaimToken: stewardClaimToken,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String firstName,
            Value<String?> lastName = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<DateTime?> deathDate = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<String?> locationLabel = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> residenceH3 = const Value.absent(),
            Value<String?> birthLocationLabel = const Value.absent(),
            Value<double?> birthLatitude = const Value.absent(),
            Value<double?> birthLongitude = const Value.absent(),
            Value<String?> birthH3 = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> whatsapp = const Value.absent(),
            Value<bool> isUrgent = const Value.absent(),
            Value<String> claimState = const Value.absent(),
            Value<String?> ownerUserId = const Value.absent(),
            Value<String?> claimToken = const Value.absent(),
            Value<String> stewardshipState = const Value.absent(),
            Value<String?> stewardUserId = const Value.absent(),
            Value<String?> stewardClaimToken = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MembersCompanion.insert(
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
            claimState: claimState,
            ownerUserId: ownerUserId,
            claimToken: claimToken,
            stewardshipState: stewardshipState,
            stewardUserId: stewardUserId,
            stewardClaimToken: stewardClaimToken,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MembersTableProcessedTableManager = ProcessedTableManager<
    _$SilatDatabase,
    $MembersTable,
    MemberRow,
    $$MembersTableFilterComposer,
    $$MembersTableOrderingComposer,
    $$MembersTableAnnotationComposer,
    $$MembersTableCreateCompanionBuilder,
    $$MembersTableUpdateCompanionBuilder,
    (MemberRow, BaseReferences<_$SilatDatabase, $MembersTable, MemberRow>),
    MemberRow,
    PrefetchHooks Function()>;
typedef $$RelationshipsTableCreateCompanionBuilder = RelationshipsCompanion
    Function({
  required String id,
  required String sourceId,
  required String targetId,
  required String relType,
  Value<DateTime?> lastContactAt,
  Value<String?> relNotes,
  Value<double> salience,
  Value<String> interventionMode,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$RelationshipsTableUpdateCompanionBuilder = RelationshipsCompanion
    Function({
  Value<String> id,
  Value<String> sourceId,
  Value<String> targetId,
  Value<String> relType,
  Value<DateTime?> lastContactAt,
  Value<String?> relNotes,
  Value<double> salience,
  Value<String> interventionMode,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$RelationshipsTableFilterComposer
    extends Composer<_$SilatDatabase, $RelationshipsTable> {
  $$RelationshipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relType => $composableBuilder(
      column: $table.relType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastContactAt => $composableBuilder(
      column: $table.lastContactAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relNotes => $composableBuilder(
      column: $table.relNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get salience => $composableBuilder(
      column: $table.salience, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get interventionMode => $composableBuilder(
      column: $table.interventionMode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$RelationshipsTableOrderingComposer
    extends Composer<_$SilatDatabase, $RelationshipsTable> {
  $$RelationshipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relType => $composableBuilder(
      column: $table.relType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastContactAt => $composableBuilder(
      column: $table.lastContactAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relNotes => $composableBuilder(
      column: $table.relNotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get salience => $composableBuilder(
      column: $table.salience, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get interventionMode => $composableBuilder(
      column: $table.interventionMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$RelationshipsTableAnnotationComposer
    extends Composer<_$SilatDatabase, $RelationshipsTable> {
  $$RelationshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get relType =>
      $composableBuilder(column: $table.relType, builder: (column) => column);

  GeneratedColumn<DateTime> get lastContactAt => $composableBuilder(
      column: $table.lastContactAt, builder: (column) => column);

  GeneratedColumn<String> get relNotes =>
      $composableBuilder(column: $table.relNotes, builder: (column) => column);

  GeneratedColumn<double> get salience =>
      $composableBuilder(column: $table.salience, builder: (column) => column);

  GeneratedColumn<String> get interventionMode => $composableBuilder(
      column: $table.interventionMode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RelationshipsTableTableManager extends RootTableManager<
    _$SilatDatabase,
    $RelationshipsTable,
    RelationshipRow,
    $$RelationshipsTableFilterComposer,
    $$RelationshipsTableOrderingComposer,
    $$RelationshipsTableAnnotationComposer,
    $$RelationshipsTableCreateCompanionBuilder,
    $$RelationshipsTableUpdateCompanionBuilder,
    (
      RelationshipRow,
      BaseReferences<_$SilatDatabase, $RelationshipsTable, RelationshipRow>
    ),
    RelationshipRow,
    PrefetchHooks Function()> {
  $$RelationshipsTableTableManager(
      _$SilatDatabase db, $RelationshipsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RelationshipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RelationshipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RelationshipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sourceId = const Value.absent(),
            Value<String> targetId = const Value.absent(),
            Value<String> relType = const Value.absent(),
            Value<DateTime?> lastContactAt = const Value.absent(),
            Value<String?> relNotes = const Value.absent(),
            Value<double> salience = const Value.absent(),
            Value<String> interventionMode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RelationshipsCompanion(
            id: id,
            sourceId: sourceId,
            targetId: targetId,
            relType: relType,
            lastContactAt: lastContactAt,
            relNotes: relNotes,
            salience: salience,
            interventionMode: interventionMode,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sourceId,
            required String targetId,
            required String relType,
            Value<DateTime?> lastContactAt = const Value.absent(),
            Value<String?> relNotes = const Value.absent(),
            Value<double> salience = const Value.absent(),
            Value<String> interventionMode = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RelationshipsCompanion.insert(
            id: id,
            sourceId: sourceId,
            targetId: targetId,
            relType: relType,
            lastContactAt: lastContactAt,
            relNotes: relNotes,
            salience: salience,
            interventionMode: interventionMode,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RelationshipsTableProcessedTableManager = ProcessedTableManager<
    _$SilatDatabase,
    $RelationshipsTable,
    RelationshipRow,
    $$RelationshipsTableFilterComposer,
    $$RelationshipsTableOrderingComposer,
    $$RelationshipsTableAnnotationComposer,
    $$RelationshipsTableCreateCompanionBuilder,
    $$RelationshipsTableUpdateCompanionBuilder,
    (
      RelationshipRow,
      BaseReferences<_$SilatDatabase, $RelationshipsTable, RelationshipRow>
    ),
    RelationshipRow,
    PrefetchHooks Function()>;
typedef $$LifeEventsTableCreateCompanionBuilder = LifeEventsCompanion Function({
  required String id,
  required String memberId,
  required String eventType,
  required DateTime occurredAt,
  Value<String?> notes,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$LifeEventsTableUpdateCompanionBuilder = LifeEventsCompanion Function({
  Value<String> id,
  Value<String> memberId,
  Value<String> eventType,
  Value<DateTime> occurredAt,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$LifeEventsTableFilterComposer
    extends Composer<_$SilatDatabase, $LifeEventsTable> {
  $$LifeEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$LifeEventsTableOrderingComposer
    extends Composer<_$SilatDatabase, $LifeEventsTable> {
  $$LifeEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$LifeEventsTableAnnotationComposer
    extends Composer<_$SilatDatabase, $LifeEventsTable> {
  $$LifeEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LifeEventsTableTableManager extends RootTableManager<
    _$SilatDatabase,
    $LifeEventsTable,
    LifeEventRow,
    $$LifeEventsTableFilterComposer,
    $$LifeEventsTableOrderingComposer,
    $$LifeEventsTableAnnotationComposer,
    $$LifeEventsTableCreateCompanionBuilder,
    $$LifeEventsTableUpdateCompanionBuilder,
    (
      LifeEventRow,
      BaseReferences<_$SilatDatabase, $LifeEventsTable, LifeEventRow>
    ),
    LifeEventRow,
    PrefetchHooks Function()> {
  $$LifeEventsTableTableManager(_$SilatDatabase db, $LifeEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LifeEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LifeEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> memberId = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LifeEventsCompanion(
            id: id,
            memberId: memberId,
            eventType: eventType,
            occurredAt: occurredAt,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String memberId,
            required String eventType,
            required DateTime occurredAt,
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LifeEventsCompanion.insert(
            id: id,
            memberId: memberId,
            eventType: eventType,
            occurredAt: occurredAt,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LifeEventsTableProcessedTableManager = ProcessedTableManager<
    _$SilatDatabase,
    $LifeEventsTable,
    LifeEventRow,
    $$LifeEventsTableFilterComposer,
    $$LifeEventsTableOrderingComposer,
    $$LifeEventsTableAnnotationComposer,
    $$LifeEventsTableCreateCompanionBuilder,
    $$LifeEventsTableUpdateCompanionBuilder,
    (
      LifeEventRow,
      BaseReferences<_$SilatDatabase, $LifeEventsTable, LifeEventRow>
    ),
    LifeEventRow,
    PrefetchHooks Function()>;

class $SilatDatabaseManager {
  final _$SilatDatabase _db;
  $SilatDatabaseManager(this._db);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$RelationshipsTableTableManager get relationships =>
      $$RelationshipsTableTableManager(_db, _db.relationships);
  $$LifeEventsTableTableManager get lifeEvents =>
      $$LifeEventsTableTableManager(_db, _db.lifeEvents);
}
