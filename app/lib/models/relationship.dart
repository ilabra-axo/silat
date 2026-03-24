// Relationship — directed edge in the family graph
// source → target with typed semantics.

enum RelType { parentChild, partner }

extension RelTypeLabel on RelType {
  String get code => switch (this) {
        RelType.parentChild => 'parent-child',
        RelType.partner => 'partner',
      };

  static RelType fromCode(String code) => switch (code) {
        'parent-child' => RelType.parentChild,
        'partner' => RelType.partner,
        _ => throw ArgumentError('Unknown rel_type: $code'),
      };

  String get displayLabel => switch (this) {
        RelType.parentChild => 'Parent → Child',
        RelType.partner => 'Partner',
      };
}

// How proactively the serendipity engine intervenes for this relationship.
enum InterventionMode { passive, ambient, active }

extension InterventionModeLabel on InterventionMode {
  String get code => switch (this) {
        InterventionMode.passive => 'passive',
        InterventionMode.ambient => 'ambient',
        InterventionMode.active => 'active',
      };

  static InterventionMode fromCode(String? code) => switch (code) {
        'ambient' => InterventionMode.ambient,
        'active' => InterventionMode.active,
        _ => InterventionMode.passive,
      };

  String get displayLabel => switch (this) {
        InterventionMode.passive => 'passive',
        InterventionMode.ambient => 'ambient',
        InterventionMode.active => 'active',
      };

  String get description => switch (this) {
        InterventionMode.passive => 'score visible, no nudges',
        InterventionMode.ambient => 'subtle reminder when score rises',
        InterventionMode.active => 'proactive scheduling suggestions',
      };
}

class Relationship {
  const Relationship({
    required this.id,
    required this.sourceId,
    required this.targetId,
    required this.relType,
    this.lastContactAt,
    this.notes,
    this.salience = 0.5,
    this.interventionMode = InterventionMode.passive,
    required this.createdAt,
  });

  final String id;
  final String sourceId; // parent (for parent-child) or either partner
  final String targetId; // child (for parent-child) or other partner
  final RelType relType;
  final DateTime? lastContactAt; // last meaningful contact between the two members
  final String? notes;           // relationship-specific notes
  final double salience;         // 0.0–1.0 relational weight (R in serendipity formula)
  final InterventionMode interventionMode;
  final DateTime createdAt;

  /// Days since last contact. Null if never logged.
  int? get silenceGapDays {
    if (lastContactAt == null) return null;
    return DateTime.now().difference(lastContactAt!).inDays;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'source_id': sourceId,
        'target_id': targetId,
        'rel_type': relType.code,
        'last_contact_at': lastContactAt?.toIso8601String(),
        'notes': notes,
        'salience': salience,
        'intervention_mode': interventionMode.code,
        'created_at': createdAt.toIso8601String(),
      };

  factory Relationship.fromJson(Map<String, dynamic> j) => Relationship(
        id: j['id'] as String,
        sourceId: j['source_id'] as String,
        targetId: j['target_id'] as String,
        relType: RelTypeLabel.fromCode(j['rel_type'] as String),
        lastContactAt: j['last_contact_at'] != null
            ? DateTime.tryParse(j['last_contact_at'] as String)
            : null,
        notes: j['notes'] as String?,
        salience: (j['salience'] as num?)?.toDouble() ?? 0.5,
        interventionMode:
            InterventionModeLabel.fromCode(j['intervention_mode'] as String?),
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
