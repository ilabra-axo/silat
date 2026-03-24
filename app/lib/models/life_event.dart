// LifeEvent — episodic memory attached to a member node.
// Source: §4.4 and §5.2 of the silat concept paper.

enum LifeEventType {
  relocation,
  marriage,
  divorce,
  newChild,
  career,
  health,
  reunion,
  milestone,
  other,
}

extension LifeEventTypeLabel on LifeEventType {
  String get code => switch (this) {
        LifeEventType.relocation => 'relocation',
        LifeEventType.marriage   => 'marriage',
        LifeEventType.divorce    => 'divorce',
        LifeEventType.newChild   => 'new_child',
        LifeEventType.career     => 'career',
        LifeEventType.health     => 'health',
        LifeEventType.reunion    => 'reunion',
        LifeEventType.milestone  => 'milestone',
        LifeEventType.other      => 'other',
      };

  static LifeEventType fromCode(String code) => switch (code) {
        'relocation' => LifeEventType.relocation,
        'marriage'   => LifeEventType.marriage,
        'divorce'    => LifeEventType.divorce,
        'new_child'  => LifeEventType.newChild,
        'career'     => LifeEventType.career,
        'health'     => LifeEventType.health,
        'reunion'    => LifeEventType.reunion,
        'milestone'  => LifeEventType.milestone,
        _            => LifeEventType.other,
      };

  String get displayLabel => switch (this) {
        LifeEventType.relocation => 'relocation',
        LifeEventType.marriage   => 'marriage',
        LifeEventType.divorce    => 'divorce',
        LifeEventType.newChild   => 'new child',
        LifeEventType.career     => 'career',
        LifeEventType.health     => 'health',
        LifeEventType.reunion    => 'reunion',
        LifeEventType.milestone  => 'milestone',
        LifeEventType.other      => 'other',
      };

  String get icon => switch (this) {
        LifeEventType.relocation => '📍',
        LifeEventType.marriage   => '💍',
        LifeEventType.divorce    => '📄',
        LifeEventType.newChild   => '👶',
        LifeEventType.career     => '💼',
        LifeEventType.health     => '🏥',
        LifeEventType.reunion    => '🤝',
        LifeEventType.milestone  => '⭐',
        LifeEventType.other      => '📝',
      };
}

class LifeEvent {
  const LifeEvent({
    required this.id,
    required this.memberId,
    required this.eventType,
    required this.occurredAt,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String memberId;
  final LifeEventType eventType;
  final DateTime occurredAt;
  final String? notes;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'member_id': memberId,
        'event_type': eventType.code,
        'occurred_at': occurredAt.toIso8601String(),
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };
}
