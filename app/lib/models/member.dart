// Member — core entity in the family graph
// Immutable value object. All mutations go through the event log.

// Identity claim lifecycle — tracks whether the real person has claimed
// their own profile. Token is single-use; ownerUserId is set on claim.
enum ClaimState { seeded, claimPending, claimed }

extension ClaimStateLabel on ClaimState {
  String get code => switch (this) {
        ClaimState.seeded => 'seeded',
        ClaimState.claimPending => 'claim_pending',
        ClaimState.claimed => 'claimed',
      };

  static ClaimState fromCode(String? code) => switch (code) {
        'claim_pending' => ClaimState.claimPending,
        'claimed' => ClaimState.claimed,
        _ => ClaimState.seeded,
      };
}

// Stewardship lifecycle — tracks whether an archivist-delegate has taken
// responsibility for maintaining this profile. Parallel to identity claim;
// a steward does NOT block the real person from later claiming identity.
enum StewardshipState { none, pending, active }

extension StewardshipStateLabel on StewardshipState {
  String get code => switch (this) {
        StewardshipState.none => 'none',
        StewardshipState.pending => 'pending',
        StewardshipState.active => 'active',
      };

  static StewardshipState fromCode(String? code) => switch (code) {
        'pending' => StewardshipState.pending,
        'active' => StewardshipState.active,
        _ => StewardshipState.none,
      };
}

enum Gender { male, female, nonBinary, unspecified }

extension GenderLabel on Gender {
  String get code => switch (this) {
        Gender.male => 'M',
        Gender.female => 'F',
        Gender.nonBinary => 'X',
        Gender.unspecified => '',
      };

  static Gender fromCode(String? code) => switch (code?.toUpperCase()) {
        'M' => Gender.male,
        'F' => Gender.female,
        'X' => Gender.nonBinary,
        _ => Gender.unspecified,
      };

  String get displayLabel => switch (this) {
        Gender.male => 'Male',
        Gender.female => 'Female',
        Gender.nonBinary => 'Non-binary',
        Gender.unspecified => 'Unspecified',
      };
}

class Member {
  const Member({
    required this.id,
    required this.firstName,
    this.lastName,
    this.birthDate,
    this.deathDate,
    this.gender = Gender.unspecified,
    // Residence (where the person currently lives / lived)
    this.locationLabel,
    this.latitude,
    this.longitude,
    this.residenceH3,
    // Birth location
    this.birthLocationLabel,
    this.birthLatitude,
    this.birthLongitude,
    this.birthH3,
    this.notes,
    this.photoUrl,
    this.phone,
    this.whatsapp,
    this.isUrgent = false,
    this.claimState = ClaimState.seeded,
    this.ownerUserId,
    this.claimToken,
    this.stewardshipState = StewardshipState.none,
    this.stewardUserId,
    this.stewardClaimToken,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String firstName;
  final String? lastName;

  // Full dates — year-only entries have Jan 1 as the day
  final DateTime? birthDate;
  final DateTime? deathDate;

  // Convenience getters used throughout the UI
  int? get birthYear => birthDate?.year;
  int? get deathYear => deathDate?.year;

  final Gender gender;

  // Current / last known residence
  final String? locationLabel;
  final double? latitude;
  final double? longitude;
  final String? residenceH3; // H3 resolution-7 cell, computed server-side

  // Place of birth
  final String? birthLocationLabel;
  final double? birthLatitude;
  final double? birthLongitude;
  final String? birthH3; // H3 resolution-7 cell, computed server-side

  final String? notes;
  final String? photoUrl; // https:// URL or data:image/... base64 URI
  final String? phone;    // E.164 format preferred e.g. +1234567890
  final String? whatsapp; // E.164 — may differ from phone
  final bool isUrgent;   // transmission-critical flag

  // Identity claim: the real person claims their own profile.
  // ownerUserId is set permanently after ProfileClaimed event.
  final ClaimState claimState;
  final String? ownerUserId;
  final String? claimToken;    // one-time token for identity invite link

  // Stewardship: a delegate archivist who maintains this profile.
  // Does NOT block the real person from claiming identity later.
  // stewardUserId is cleared if stewardship is revoked.
  final StewardshipState stewardshipState;
  final String? stewardUserId;
  final String? stewardClaimToken; // one-time token for stewardship invite link

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isClaimed => claimState == ClaimState.claimed;
  bool get isUnclaimed => claimState == ClaimState.seeded;
  bool get hasSteward => stewardshipState == StewardshipState.active;

  bool get isLiving => deathDate == null;
  bool get hasGeo => latitude != null && longitude != null;
  bool get hasBirthGeo => birthLatitude != null && birthLongitude != null;

  String get displayName =>
      lastName != null ? '$firstName $lastName' : firstName;

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l =
        lastName?.isNotEmpty == true ? lastName![0].toUpperCase() : '';
    return '$f$l';
  }

  Member copyWith({
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    DateTime? deathDate,
    Gender? gender,
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
    ClaimState? claimState,
    String? ownerUserId,
    String? claimToken,
    StewardshipState? stewardshipState,
    String? stewardUserId,
    String? stewardClaimToken,
    DateTime? updatedAt,
    // Sentinel for explicit null-clearing (can't distinguish null-as-clear from absent)
    bool clearClaimToken = false,
    bool clearStewardUserId = false,
    bool clearStewardClaimToken = false,
  }) =>
      Member(
        id: id,
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
        claimToken: clearClaimToken ? null : (claimToken ?? this.claimToken),
        stewardshipState: stewardshipState ?? this.stewardshipState,
        stewardUserId: clearStewardUserId ? null : (stewardUserId ?? this.stewardUserId),
        stewardClaimToken: clearStewardClaimToken ? null : (stewardClaimToken ?? this.stewardClaimToken),
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now().toUtc(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'birth_date': birthDate?.toIso8601String(),
        'death_date': deathDate?.toIso8601String(),
        'gender': gender.code,
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
        'is_urgent': isUrgent,
        'claim_state': claimState.code,
        'owner_user_id': ownerUserId,
        'claim_token': claimToken,
        'stewardship_state': stewardshipState.code,
        'steward_user_id': stewardUserId,
        'steward_claim_token': stewardClaimToken,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Member.fromJson(Map<String, dynamic> j) => Member(
        id: j['id'] as String,
        firstName: j['first_name'] as String,
        lastName: j['last_name'] as String?,
        birthDate: j['birth_date'] != null
            ? DateTime.tryParse(j['birth_date'] as String)
            : null,
        deathDate: j['death_date'] != null
            ? DateTime.tryParse(j['death_date'] as String)
            : null,
        gender: GenderLabel.fromCode(j['gender'] as String?),
        locationLabel: j['location_label'] as String?,
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        residenceH3: j['residence_h3'] as String?,
        birthLocationLabel: j['birth_location_label'] as String?,
        birthLatitude: (j['birth_latitude'] as num?)?.toDouble(),
        birthLongitude: (j['birth_longitude'] as num?)?.toDouble(),
        birthH3: j['birth_h3'] as String?,
        notes: j['notes'] as String?,
        photoUrl: j['photo_url'] as String?,
        phone: j['phone'] as String?,
        whatsapp: j['whatsapp'] as String?,
        isUrgent: (j['is_urgent'] as bool?) ?? false,
        claimState: ClaimStateLabel.fromCode(j['claim_state'] as String?),
        ownerUserId: j['owner_user_id'] as String?,
        claimToken: j['claim_token'] as String?,
        stewardshipState:
            StewardshipStateLabel.fromCode(j['stewardship_state'] as String?),
        stewardUserId: j['steward_user_id'] as String?,
        stewardClaimToken: j['steward_claim_token'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
        updatedAt: DateTime.parse(j['updated_at'] as String),
      );
}
