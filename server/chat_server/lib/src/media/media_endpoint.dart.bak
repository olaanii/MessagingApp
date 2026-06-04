import '../generated/protocol.dart';
import 'package:chat_server/src/security/security_guards.dart';
import 'media_runtime.dart';
import 'media_upload_store.dart';
import 'package:serverpod/serverpod.dart';

/// RPC for media slots + finalize. Binary bytes use [MediaBlobRoute] (presign-style URL).
class MediaEndpoint extends Endpoint {
  /// MVP: open like [GreetingEndpoint] until Firebase → Serverpod session (ADR-0003).
  @override
  bool get requireLogin => false;

  Future<MediaUploadSlot> requestUploadSlot(
    Session session,
    MediaUploadRequest request,
  ) async {
    try {
      final rt = MediaRuntime.instance;
      final slot = rt.store.startSlot(
        mimeType: request.mimeType,
        byteLength: request.byteLength,
        chatId: request.chatId,
        publicApiOrigin: rt.publicApiOrigin,
      );
      return MediaUploadSlot(
        mediaId: slot.mediaId,
        uploadUrl: slot.uploadUrl,
        expiresAt: slot.expiresAt,
        maxBytes: slot.maxBytes,
        chunkSizeBytes: slot.chunkSizeBytes,
        allowedMimeTypes: slot.allowedMimeTypes,
        finalizeToken: slot.finalizeToken,
      );
    } on MediaPolicyException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<MediaFinalizeResult> finalizeUpload(
    Session session,
    String mediaId,
    String finalizeToken,
    int declaredTotalBytes,
  ) async {
    SecurityGuards.requireMediaFinalizeAllowed(session);
    try {
      final rt = MediaRuntime.instance;
      final result = rt.store.finalize(
        mediaId: mediaId,
        finalizeToken: finalizeToken,
        declaredTotalBytes: declaredTotalBytes,
        publicApiOrigin: rt.publicApiOrigin,
      );
      return MediaFinalizeResult(
        mediaId: result.mediaId,
        fetchUrl: result.fetchUrl,
      );
    } on MediaUploadException catch (e) {
      throw Exception(e.message);
    }
  }
}
