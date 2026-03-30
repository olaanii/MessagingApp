import 'dart:io';

import '../../../data/services/serverpod_media_uploader.dart';

// ── Interface ─────────────────────────────────────────────────────────────────

/// Abstract interface for uploading media files in a chat.
///
/// Requirements: 8.1, 8.2, 8.3, 8.4, 8.6
abstract interface class MediaUploadService {
  /// Uploads [file] with [mimeType] for the given [chatId].
  ///
  /// Returns the `fetchUrl` that can be attached to a message payload.
  ///
  /// [onProgress] is called with values in `[0.0, 1.0]` non-decreasingly
  /// as each chunk completes (Requirement 8.6).
  Future<String> uploadMedia({
    required String chatId,
    required File file,
    required String mimeType,
    void Function(double progress)? onProgress,
  });
}

// ── Serverpod implementation ──────────────────────────────────────────────────

/// [MediaUploadService] backed by [ServerpodMediaUploader].
///
/// Delegates chunked PUT + finalize to [ServerpodMediaUploader.uploadFile]
/// and returns the resulting `fetchUrl`.
///
/// Requirements: 8.1, 8.2, 8.3, 8.4, 8.6
final class ServerpodMediaUploadService implements MediaUploadService {
  ServerpodMediaUploadService(this._uploader);

  final ServerpodMediaUploader _uploader;

  @override
  Future<String> uploadMedia({
    required String chatId,
    required File file,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    double _lastProgress = 0.0;

    void _guardedProgress(double value) {
      // Clamp to [0.0, 1.0] and enforce non-decreasing invariant.
      final clamped = value.clamp(0.0, 1.0);
      if (clamped >= _lastProgress) {
        _lastProgress = clamped;
        onProgress?.call(clamped);
      }
    }

    final fetchUrl = await _uploader.uploadFile(
      file: file,
      mimeType: mimeType,
      chatId: chatId,
      onProgress: onProgress != null ? _guardedProgress : null,
    );

    return fetchUrl;
  }
}
