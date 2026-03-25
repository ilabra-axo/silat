// ApiService — all reads and writes go through here.
// Remote-only: no local SQLite. Riverpod holds data in memory.

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/member.dart';
import '../models/relationship.dart';
import '../models/attachment.dart';
import '../services/auth_service.dart';

class ApiService {
  ApiService(this._auth);

  static const _base = 'https://silat-api.vercel.app';
  final AuthService _auth;

  Map<String, String> get _headers => _auth.authHeaders;

  // ── Members ──────────────────────────────────────────────────────────────

  Future<({List<Member> members, List<Relationship> relationships})>
      fetchAll() async {
    final res = await http.get(
      Uri.parse('$_base/api/members'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('fetchAll failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final members = (body['members'] as List<dynamic>)
        .map((j) => Member.fromJson(j as Map<String, dynamic>))
        .toList();
    final rels = (body['relationships'] as List<dynamic>)
        .map((j) => Relationship.fromJson(j as Map<String, dynamic>))
        .toList();
    return (members: members, relationships: rels);
  }

  Future<Member> createMember({
    required String firstName,
    String? lastName,
    DateTime? birthDate,
    DateTime? deathDate,
    Gender gender = Gender.unspecified,
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
    final now = DateTime.now().toUtc().toIso8601String();
    final body = <String, dynamic>{
      'id': id,
      'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (birthDate != null) 'birth_date': birthDate.toIso8601String(),
      if (deathDate != null) 'death_date': deathDate.toIso8601String(),
      'gender': gender.code,
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
      'is_urgent': isUrgent,
      'created_at': now,
      'updated_at': now,
    };
    final res = await http.post(
      Uri.parse('$_base/api/members'),
      headers: _headers,
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception('createMember failed: ${res.statusCode} ${res.body}');
    }
    return Member.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Member> updateMember(String id, Map<String, dynamic> fields) async {
    final res = await http.put(
      Uri.parse('$_base/api/members/$id'),
      headers: _headers,
      body: jsonEncode(fields),
    );
    if (res.statusCode != 200) {
      throw Exception('updateMember failed: ${res.statusCode} ${res.body}');
    }
    return Member.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteMember(String id) async {
    final res = await http.delete(
      Uri.parse('$_base/api/members/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('deleteMember failed: ${res.statusCode} ${res.body}');
    }
  }

  // ── Relationships ─────────────────────────────────────────────────────────

  Future<Relationship?> createRelationship({
    required String sourceId,
    required String targetId,
    required RelType relType,
  }) async {
    final id = const Uuid().v4().substring(0, 7);
    final now = DateTime.now().toUtc().toIso8601String();
    final res = await http.post(
      Uri.parse('$_base/api/relationships'),
      headers: _headers,
      body: jsonEncode({
        'id': id,
        'source_id': sourceId,
        'target_id': targetId,
        'rel_type': relType.code,
        'created_at': now,
      }),
    );
    if (res.statusCode == 409) return null; // duplicate
    if (res.statusCode != 200) {
      throw Exception('createRelationship failed: ${res.statusCode} ${res.body}');
    }
    return Relationship.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Relationship> updateRelationship(
    String id, {
    DateTime? lastContactAt,
    String? notes,
    double? salience,
    InterventionMode? interventionMode,
  }) async {
    final res = await http.put(
      Uri.parse('$_base/api/relationships/$id'),
      headers: _headers,
      body: jsonEncode({
        if (lastContactAt != null) 'last_contact_at': lastContactAt.toIso8601String(),
        if (notes != null) 'notes': notes,
        if (salience != null) 'salience': salience,
        if (interventionMode != null) 'intervention_mode': interventionMode.code,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('updateRelationship failed: ${res.statusCode} ${res.body}');
    }
    return Relationship.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteRelationship(String id) async {
    final res = await http.delete(
      Uri.parse('$_base/api/relationships/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('deleteRelationship failed: ${res.statusCode} ${res.body}');
    }
  }

  // ── Claim ─────────────────────────────────────────────────────────────────

  Future<Member> claimProfile(String token, {bool steward = false}) async {
    final res = await http.post(
      Uri.parse('$_base/api/claim'),
      headers: _headers,
      body: jsonEncode({
        'token': token,
        if (steward) 'type': 'steward',
      }),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? 'Claim failed');
    }
    return Member.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── Claim self (direct — no token) ────────────────────────────────────────

  Future<Member> claimSelf(String memberId) async {
    final res = await http.put(
      Uri.parse('$_base/api/members/$memberId'),
      headers: _headers,
      body: jsonEncode({
        'claim_state': 'claimed',
        'owner_user_id': _auth.currentUser?.id,
        'claim_token': null,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('claimSelf failed: ${res.statusCode} ${res.body}');
    }
    return Member.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── Invite tokens ─────────────────────────────────────────────────────────

  Future<Member> sendClaimInvite(String memberId) async {
    final token = const Uuid().v4();
    return updateMember(memberId, {
      'claim_state': 'claim_pending',
      'claim_token': token,
    });
  }

  Future<Member> revokeClaimInvite(String memberId) async {
    return updateMember(memberId, {
      'claim_state': 'seeded',
      'claim_token': null,
    });
  }

  Future<Member> sendStewardshipInvite(String memberId) async {
    final token = const Uuid().v4();
    return updateMember(memberId, {
      'stewardship_state': 'pending',
      'steward_claim_token': token,
    });
  }

  Future<Member> revokeStewardship(String memberId) async {
    return updateMember(memberId, {
      'stewardship_state': 'none',
      'steward_user_id': null,
      'steward_claim_token': null,
    });
  }

  // ── Attachments ───────────────────────────────────────────────────────────

  Future<List<Attachment>> getAttachments(String memberId) async {
    final res = await http.get(
      Uri.parse('$_base/api/attachments').replace(
        queryParameters: {'member_id': memberId},
      ),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('getAttachments failed: ${res.statusCode}');
    }
    return (jsonDecode(res.body) as List<dynamic>)
        .map((j) => Attachment.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<Attachment> uploadAttachment({
    required String memberId,
    required String filename,
    required String mimeType,
    required Uint8List bytes,
    String? caption,
  }) async {
    final boundary = 'silat${const Uuid().v4().replaceAll('-', '')}';
    final bodyBytes = _buildMultipart(
      boundary: boundary,
      memberId: memberId,
      filename: filename,
      mimeType: mimeType,
      bytes: bytes,
      caption: caption,
    );
    final res = await http.post(
      Uri.parse('$_base/api/attachments'),
      headers: {
        ..._headers,
        'Content-Type': 'multipart/form-data; boundary=$boundary',
      },
      body: bodyBytes,
    );
    if (res.statusCode != 201) {
      throw Exception('uploadAttachment failed: ${res.statusCode} ${res.body}');
    }
    return Attachment.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteAttachment(String attachmentId) async {
    final res = await http.delete(
      Uri.parse('$_base/api/attachments/$attachmentId'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('deleteAttachment failed: ${res.statusCode}');
    }
  }

  // Build minimal multipart body manually (avoids extra deps)
  Uint8List _buildMultipart({
    required String boundary,
    required String memberId,
    required String filename,
    required String mimeType,
    required Uint8List bytes,
    String? caption,
  }) {
    final parts = <int>[];
    void add(String s) => parts.addAll(s.codeUnits);
    void addField(String name, String value) {
      add('--$boundary\r\n');
      add('Content-Disposition: form-data; name="$name"\r\n\r\n');
      add(value);
      add('\r\n');
    }

    addField('member_id', memberId);
    if (caption != null && caption.isNotEmpty) addField('caption', caption);

    add('--$boundary\r\n');
    add('Content-Disposition: form-data; name="file"; filename="$filename"\r\n');
    add('Content-Type: $mimeType\r\n\r\n');
    parts.addAll(bytes);
    add('\r\n');

    add('--$boundary--\r\n');
    return Uint8List.fromList(parts);
  }
}
