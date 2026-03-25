// CQRS Event — append-only record of every mutation.
// The read model (members, relationships) is derived from this log.

enum EventType {
  memberAdded,
  memberUpdated,
  memberDeleted,
  relationshipCreated,
  relationshipDeleted,
  profileClaimed,
  claimInviteSent,
  claimRevoked,
  stewardshipInviteSent,
  stewardshipClaimed,
  stewardshipRevoked,
  photoUpdated,
}

extension EventTypeLabel on EventType {
  String get code => switch (this) {
        EventType.memberAdded => 'MemberAdded',
        EventType.memberUpdated => 'MemberUpdated',
        EventType.memberDeleted => 'MemberDeleted',
        EventType.relationshipCreated => 'RelationshipCreated',
        EventType.relationshipDeleted => 'RelationshipDeleted',
        EventType.profileClaimed => 'ProfileClaimed',
        EventType.claimInviteSent => 'ClaimInviteSent',
        EventType.claimRevoked => 'ClaimRevoked',
        EventType.stewardshipInviteSent => 'StewardshipInviteSent',
        EventType.stewardshipClaimed => 'StewardshipClaimed',
        EventType.stewardshipRevoked => 'StewardshipRevoked',
        EventType.photoUpdated => 'PhotoUpdated',
      };

  static EventType fromCode(String code) {
    return EventType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => throw ArgumentError('Unknown event type: $code'),
    );
  }
}

enum StreamType { member, relationship }

extension StreamTypeLabel on StreamType {
  String get code => switch (this) {
        StreamType.member => 'member',
        StreamType.relationship => 'relationship',
      };

  static StreamType fromCode(String code) => switch (code) {
        'member' => StreamType.member,
        'relationship' => StreamType.relationship,
        _ => throw ArgumentError('Unknown stream type: $code'),
      };
}

class SilatEvent {
  const SilatEvent({
    required this.id,
    required this.streamId,
    required this.streamType,
    required this.eventType,
    required this.payload,
    required this.actorId,
    required this.occurredAt,
    this.synced = false,
  });

  final String id;
  final String streamId;       // member.id or relationship.id
  final StreamType streamType;
  final EventType eventType;
  final Map<String, dynamic> payload;
  final String actorId;        // user.id who triggered the event
  final DateTime occurredAt;
  final bool synced;           // has this been pushed to the server?

  Map<String, dynamic> toJson() => {
        'id': id,
        'stream_id': streamId,
        'stream_type': streamType.code,
        'event_type': eventType.code,
        'payload': payload,
        'actor_id': actorId,
        'occurred_at': occurredAt.toIso8601String(),
        'synced': synced,
      };

  factory SilatEvent.fromJson(Map<String, dynamic> j) => SilatEvent(
        id: j['id'] as String,
        streamId: j['stream_id'] as String,
        streamType: StreamTypeLabel.fromCode(j['stream_type'] as String),
        eventType: EventTypeLabel.fromCode(j['event_type'] as String),
        payload: Map<String, dynamic>.from(j['payload'] as Map),
        actorId: j['actor_id'] as String,
        occurredAt: DateTime.parse(j['occurred_at'] as String),
        synced: j['synced'] as bool? ?? false,
      );
}
