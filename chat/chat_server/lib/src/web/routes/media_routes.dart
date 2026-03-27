import 'package:chat_server/src/media/media_upload_store.dart';
import 'package:serverpod/serverpod.dart';

/// `PUT /media/blob/{mediaId}?token=` — append body at `X-Chunk-Start` (default 0).
class MediaBlobRoute extends Route {
  MediaBlobRoute(this._store) : super(methods: {Method.put});

  final MediaUploadStore _store;

  @override
  Future<Result> handleCall(Session session, Request request) async {
    try {
      final segments = request.url.pathSegments;
      if (segments.length < 3 ||
          segments[0] != 'media' ||
          segments[1] != 'blob') {
        return Response.badRequest(body: Body.fromString('Invalid path'));
      }
      final mediaId = segments[2];
      final token = request.url.queryParameters['token'];
      if (token == null || token.isEmpty) {
        return Response.badRequest(body: Body.fromString('Missing token'));
      }

      final startRaw = request.headers['x-chunk-start'];
      final chunkStart = startRaw == null ? 0 : int.tryParse(startRaw) ?? -1;
      if (chunkStart < 0) {
        return Response.badRequest(body: Body.fromString('Bad X-Chunk-Start'));
      }

      final stream = request.read();
      await _store.appendChunk(
        mediaId: mediaId,
        token: token,
        chunkStart: chunkStart,
        bytes: stream,
      );
      return Response.ok(body: Body.fromString('ok'));
    } on MediaUploadException catch (e) {
      return Response.badRequest(body: Body.fromString(e.message));
    } catch (e, st) {
      session.log('media blob upload error: $e\n$st');
      return Response.internalServerError(
        body: Body.fromString('upload failed'),
      );
    }
  }
}

/// `GET /media/file/{mediaId}?readToken=` — serve finalized blob.
class MediaFileRoute extends Route {
  MediaFileRoute(this._store) : super(methods: {Method.get});

  final MediaUploadStore _store;

  @override
  Future<Result> handleCall(Session session, Request request) async {
    try {
      final segments = request.url.pathSegments;
      if (segments.length < 3 ||
          segments[0] != 'media' ||
          segments[1] != 'file') {
        return Response.notFound(body: Body.fromString('Not found'));
      }
      final mediaId = segments[2];
      final token = request.url.queryParameters['readToken'] ?? '';
      final target = _store.readTargetIfValid(mediaId, token);
      if (target == null) {
        return Response.notFound(body: Body.fromString('Not found'));
      }
      final file = target.file;
      if (!file.existsSync()) {
        return Response.notFound(body: Body.fromString('Gone'));
      }
      final bytes = await file.readAsBytes();
      return Response.ok(
        body: Body.fromData(bytes),
        headers: {'content-type': target.mimeType},
      );
    } catch (e, st) {
      session.log('media file read error: $e\n$st');
      return Response.internalServerError(body: Body.fromString('read failed'));
    }
  }
}
