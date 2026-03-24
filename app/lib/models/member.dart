// Member — core entity in the family graph
// Immutable value object. All mutations go through the event log.

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

  final DateTime createdAt;
  final DateTime updatedAt;

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
    DateTime? updatedAt,
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
        createdAt: DateTime.parse(j['created_at'] as String),
        updatedAt: DateTime.parse(j['updated_at'] as String),
      );
}
