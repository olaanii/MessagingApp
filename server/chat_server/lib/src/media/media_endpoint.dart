import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'media_runtime.dart';

/// Media upload endpoint — delegates to [MediaRuntime.store] for slot management.
class MediaEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<MediaUploadSlot> requestUpload(
    Session session,
    MediaUploadRequest request,
  ) async {
    final runtime = MediaRuntime.instance;
    final slot = runtime.store.startSlot(
      mimeType: request.mimeType,
      byteLength: request.byteLength,
      chatId: request.chatId,
      publicApiOrigin: runtime.publicApiOrigin,
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
  }

  Future<MediaFinalizeResult> finalizeUpload(
    Session session,
    String mediaId,
    String finalizeToken,
    int declaredTotalBytes,
  ) async {
    final runtime = MediaRuntime.instance;
    final data = runtime.store.finalize(
      mediaId: mediaId,
      finalizeToken: finalizeToken,
      declaredTotalBytes: declaredTotalBytes,
      publicApiOrigin: runtime.publicApiOrigin,
    );
    return MediaFinalizeResult(
      mediaId: data.mediaId,
      fetchUrl: data.fetchUrl,
    );
  }
}
