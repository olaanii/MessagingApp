import 'package:serverpod/serverpod.dart';

import '../generated/streaming/chat_stream_envelope.dart';
import '../security/security_guards.dart';
import '../streaming/chat_stream_hub.dart';
import 'story_model.dart';

/// Ephemeral stories / posts endpoint (ADR-0002).
///
/// Stories are encrypted before leaving the client; the server only stores
/// ciphertext and enforces the 24-hour TTL.
///
/// Requirements: 7.1, 7.2, 7.3, 7.4, 7.9
class StoryEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  // ── createStory ────────────────────────────────────────────────────────────

  /// Upload a new encrypted story.
  ///
  /// [mediaType]  – `"image"`, `"video"`, or `"text"`.
  /// [encryptedPayload]  – base64 ciphertext from the E2EE module.
  /// [nonce]  – base64 nonce used for encryption.
  /// [privacy]  – `"all_contacts"`, `"selected"`, or `"public"`.
  /// [selectedViewerIds]  – comma-separated auth-user UUIDs when [privacy]="selected".
  ///
  /// Expires 24 h after creation.
  Future<Story> createStory(
    Session session, {
    required String mediaType,
    required String encryptedPayload,
    required String nonce,
    String? thumbnailCiphertext,
    String privacy = 'all_contacts',
    String? selectedViewerIds,
  }) async {
    SecurityGuards.requireRpcAllowed(session);

    final authorId = _requireAuth(session);
    final storyId = Uuid().v4();
    final now = DateTime.now().toUtc();
    final expiresAt = now.add(const Duration(hours: 24));

    // Validate media type.
    if (!{'image', 'video', 'text'}.contains(mediaType)) {
      throw ArgumentError('mediaType must be image, video, or text');
    }
    // Validate privacy.
    if (!{'all_contacts', 'selected', 'public'}.contains(privacy)) {
      throw ArgumentError('privacy must be all_contacts, selected, or public');
    }
    if (privacy == 'selected' &&
        (selectedViewerIds == null || selectedViewerIds.trim().isEmpty)) {
      throw ArgumentError(
        'selectedViewerIds required when privacy is "selected"',
      );
    }

    await session.db.unsafeQuery(
      '''
      INSERT INTO story
             (id, "authorAuthUserId", "mediaType", "encryptedPayload", "nonce",
              "thumbnailCiphertext", "privacy", "selectedViewerIds",
              "expiresAt", "createdAt")
      VALUES (
        @id::uuid, @author::uuid, @mediaType, @payload, @nonce,
        @thumb, @privacy, @selected, @expiresAt, @createdAt
      )
      ''',
      parameters: QueryParameters.named({
        'id': storyId,
        'author': authorId,
        'mediaType': mediaType,
        'payload': encryptedPayload,
        'nonce': nonce,
        'thumb': thumbnailCiphertext,
        'privacy': privacy,
        'selected': selectedViewerIds?.trim().isEmpty ?? true
            ? null
            : selectedViewerIds!.trim(),
        'expiresAt': expiresAt,
        'createdAt': now,
      }),
    );

    final row = await session.db.unsafeQuery(
      'SELECT id, "authorAuthUserId", "mediaType", "encryptedPayload", '
      '"nonce", "thumbnailCiphertext", "privacy", "selectedViewerIds", '
      '"expiresAt", "createdAt" '
      'FROM story WHERE id = @id::uuid',
      parameters: QueryParameters.named({'id': storyId}),
    );

    final story = _storyFromRow(row.first);

    // Notify contacts about the new story via streaming hub so the feed
    // updates in real time.
    await ChatStreamHub.instance.broadcast(
      session,
      '__system__',
      ChatStreamEnvelope(
        type: 'story_new',
        deviceId: '',
        chatId: '__stories__',
        ts: DateTime.now().toUtc(),
        payloadJson: '{"storyId":"${story.id.uuid}",'
            '"authorId":"$authorId",'
            '"expiresAt":"${expiresAt.toIso8601String()}"}',
      ),
      senderAuthUserId: UuidValue.fromString(authorId),
    );

    return story;
  }

  // ── listStories ────────────────────────────────────────────────────────────

  /// List non-expired stories from contacts (reverse-chronological).
  ///
  /// Returns only stories whose `expiresAt` is in the future.
  /// The [limit] is clamped to [1..50].
  Future<List<Story>> listStories(
    Session session, {
    String? forAuthUserId,
    int limit = 50,
  }) async {
    SecurityGuards.requireRpcAllowed(session);

    final me = _requireAuth(session);
    final take = limit.clamp(1, 50);

    final rows = await session.db.unsafeQuery(
      '''
      SELECT s.id, s."authorAuthUserId", s."mediaType",
             s."encryptedPayload", s."nonce", s."thumbnailCiphertext",
             s."privacy", s."selectedViewerIds", s."expiresAt", s."createdAt"
      FROM   story s
      WHERE  s."expiresAt" > now()
        AND  (
              s."privacy" = 'public'
           OR  s."authorAuthUserId" = @me::uuid
           OR  s."privacy" = 'all_contacts'
           OR  (s."privacy" = 'selected'
                AND s."selectedViewerIds" ILIKE @meLike)
             )
        AND  (\$authorFilter::text IS NULL
              OR s."authorAuthUserId" = \$authorFilter::uuid)
      ORDER  BY s."createdAt" DESC
      LIMIT  @take
      ''',
      parameters: QueryParameters.named({
        'me': me,
        'meLike': '%$me%',
        'take': take,
        'authorFilter': forAuthUserId,
      }),
    );

    return rows.map(_storyFromRow).toList();
  }

  // ── viewStory ──────────────────────────────────────────────────────────────

  /// Mark [storyId] as viewed by the caller.
  ///
  /// Idempotent – duplicate calls are silently ignored (unique constraint).
  Future<void> viewStory(
    Session session, {
    required String storyId,
  }) async {
    SecurityGuards.requireRpcAllowed(session);

    final viewerId = _requireAuth(session);

    await session.db.unsafeQuery(
      '''
      INSERT INTO story_view (id, "storyId", "viewerAuthUserId", "viewedAt")
      VALUES (gen_random_uuid_v7(), @storyId::uuid, @viewer::uuid, now())
      ON CONFLICT ("storyId", "viewerAuthUserId")
      DO UPDATE SET "viewedAt" = now()
      ''',
      parameters: QueryParameters.named({
        'storyId': storyId,
        'viewer': viewerId,
      }),
    );
  }

  // ── getViewers ─────────────────────────────────────────────────────────────

  /// Return the list of viewer IDs for [storyId] (author only).
  Future<List<String>> getViewers(
    Session session, {
    required String storyId,
  }) async {
    SecurityGuards.requireRpcAllowed(session);

    final me = _requireAuth(session);

    // Verify the caller is the author.
    final check = await session.db.unsafeQuery(
      '''
      SELECT 1 FROM story
      WHERE id = @storyId::uuid AND "authorAuthUserId" = @me::uuid
      LIMIT 1
      ''',
      parameters: QueryParameters.named({'storyId': storyId, 'me': me}),
    );
    if (check.isEmpty) {
      throw StateError('Only the story author can view the viewer list');
    }

    final rows = await session.db.unsafeQuery(
      '''
      SELECT sv."viewerAuthUserId"
      FROM   story_view sv
      WHERE  sv."storyId" = @storyId::uuid
      ORDER  BY sv."viewedAt" DESC
      ''',
      parameters: QueryParameters.named({'storyId': storyId}),
    );

    return rows.map((r) => r[0] as String).toList();
  }

  // ── deleteStory ────────────────────────────────────────────────────────────

  /// Delete [storyId] – only the author may do this.
  Future<void> deleteStory(
    Session session, {
    required String storyId,
  }) async {
    SecurityGuards.requireRpcAllowed(session);

    final me = _requireAuth(session);

    final result = await session.db.unsafeQuery(
      '''
      DELETE FROM story
      WHERE id = @storyId::uuid AND "authorAuthUserId" = @me::uuid
      RETURNING id
      ''',
      parameters: QueryParameters.named({'storyId': storyId, 'me': me}),
    );

    if (result.isEmpty) {
      throw StateError('Story not found or you are not the author');
    }

    // Clean up views for the deleted story (cascade not in schema).
    await session.db.unsafeQuery(
      'DELETE FROM story_view WHERE "storyId" = @storyId::uuid',
      parameters: QueryParameters.named({'storyId': storyId}),
    );
  }

  // ── cleanupExpired ─────────────────────────────────────────────────────────

  /// Server-side cleanup for expired stories.
  ///
  /// Intended to be called by [StoryExpirationScheduler] every hour.
  Future<int> cleanupExpired(Session session) async {
    final rows = await session.db.unsafeQuery(
      '''
      DELETE FROM story WHERE "expiresAt" < now()
      RETURNING id
      ''',
    );
    return rows.length;
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _requireAuth(Session session) {
    final auth = session.authenticated;
    if (auth == null) {
      throw Exception('Unauthenticated');
    }
    return auth.userIdentifier;
  }

  static Story _storyFromRow(dynamic row) {
    final c = (row as DatabaseResultRow).toColumnMap();
    return Story(
      id: UuidValue.fromString(c['id'].toString()),
      authorAuthUserId: UuidValue.fromString(c['authorAuthUserId'].toString()),
      mediaType: c['mediaType'] as String,
      encryptedPayload: c['encryptedPayload'] as String,
      nonce: c['nonce'] as String,
      thumbnailCiphertext: c['thumbnailCiphertext'] as String?,
      privacy: c['privacy'] as String,
      selectedViewerIds: c['selectedViewerIds'] as String?,
      expiresAt: (c['expiresAt'] as DateTime).toUtc(),
      createdAt: (c['createdAt'] as DateTime).toUtc(),
    );
  }
}
