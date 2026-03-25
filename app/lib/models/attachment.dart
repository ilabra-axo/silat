class Attachment {
  const Attachment({
    required this.id,
    required this.memberId,
    required this.blobUrl,
    required this.filename,
    required this.mimeType,
    this.byteSize,
    this.caption,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String memberId;
  final String blobUrl;
  final String filename;
  final String mimeType;
  final int? byteSize;
  final String? caption;
  final String createdBy;
  final DateTime createdAt;

  bool get isImage => mimeType.startsWith('image/');
  bool get isPdf => mimeType == 'application/pdf';

  factory Attachment.fromJson(Map<String, dynamic> j) => Attachment(
        id: j['id'] as String,
        memberId: j['member_id'] as String,
        blobUrl: j['blob_url'] as String,
        filename: j['filename'] as String,
        mimeType: j['mime_type'] as String,
        byteSize: j['byte_size'] as int?,
        caption: j['caption'] as String?,
        createdBy: j['created_by'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
