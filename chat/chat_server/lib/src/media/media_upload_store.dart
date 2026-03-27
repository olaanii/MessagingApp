import 'dart:io';
import 'dart:math';

/// In-memory upload registry + temp files. Swap for Postgres `media_objects` + S3 presign in production.
class MediaUploadStore {
  MediaUploadStore({Directory? uploadRoot})
      : _root = uploadRoot ??
            Directory(
              '${Directory.systemTemp.path}${Platform.pathSeparator}chat_media_uploads',
            ) {
    if (!_root.existsSync()) {
      _root.createSync(recursive: true);
    }
  }

  final Directory _root;
  final _pending = <String, _PendingBlob>{};
  final _completed = <String, _CompletedBlob>{};

  static const allowedMimeTypes = <String>{
    'image/jpeg',
    'image/png',
    'image/webp',
    'video/mp4',
  };

  /// Default caps (mobile-first); override via env/config later.
  static const defaultMaxImageBytes = 8 * 1024 * 1024;
  static const defaultMaxVideoBytes = 32 * 1024 * 1024;
  static const defaultChunkSize = 512 * 1024;
  static const slotTtl = Duration(minutes: 15);

  MediaSlotData startSlot({
    required String mimeType,
    required int byteLength,
    String? chatId,
    required Uri publicApiOrigin,
  }) {
    final mime = mimeType.toLowerCase().trim();
    if (!allowedMimeTypes.contains(mime)) {
      throw MediaPolicyException('MIME type not allowed: $mime');
    }

    final maxBytes = mime.startsWith('video/')
        ? defaultMaxVideoBytes
        : defaultMaxImageBytes;
    if (byteLength > maxBytes) {
      throw MediaPolicyException(
        'Declared size $byteLength exceeds limit $maxBytes',
      );
    }
    if (byteLength <= 0) {
      throw MediaPolicyException('byteLength must be positive');
    }

    final mediaId = _randomId();
    final uploadToken = _randomId();
    final finalizeToken = _randomId();
    final expiresAt = DateTime.now().toUtc().add(slotTtl);

    final partFile = File('${_root.path}${Platform.pathSeparator}$mediaId.part');
    _pending[mediaId] = _PendingBlob(
      mediaId: mediaId,
      uploadToken: uploadToken,
      finalizeToken: finalizeToken,
      mimeType: mime,
      declaredLength: byteLength,
      maxBytes: maxBytes,
      expiresAt: expiresAt,
      partFile: partFile,
      chatId: chatId,
    );

    final uploadUrl = publicApiOrigin.replace(
      path: '/media/blob/$mediaId',
      queryParameters: {'token': uploadToken},
    );

    return MediaSlotData(
      mediaId: mediaId,
      uploadUrl: uploadUrl.toString(),
      expiresAt: expiresAt,
      maxBytes: maxBytes,
      chunkSizeBytes: defaultChunkSize,
      allowedMimeTypes: allowedMimeTypes.toList()..sort(),
      finalizeToken: finalizeToken,
    );
  }

  _PendingBlob? pending(String mediaId) => _pending[mediaId];

  Future<int> appendChunk({
    required String mediaId,
    required String token,
    required int chunkStart,
    required Stream<List<int>> bytes,
  }) async {
    final p = _pending[mediaId];
    if (p == null) {
      throw MediaUploadException('Unknown or expired media id');
    }
    if (DateTime.now().toUtc().isAfter(p.expiresAt)) {
      _pending.remove(mediaId);
      try {
        if (p.partFile.existsSync()) p.partFile.deleteSync();
      } catch (_) {}
      throw MediaUploadException('Upload slot expired');
    }
    if (token != p.uploadToken) {
      throw MediaUploadException('Invalid upload token');
    }
    if (chunkStart != p.receivedBytes) {
      throw MediaUploadException(
        'Chunk offset mismatch: expected ${p.receivedBytes}, got $chunkStart',
      );
    }

    final IOSink sink = p.partFile.openWrite(mode: FileMode.append);
    try {
      await for (final chunk in bytes) {
        p.receivedBytes += chunk.length;
        if (p.receivedBytes > p.maxBytes) {
          throw MediaUploadException('File exceeds maxBytes');
        }
        sink.add(chunk);
      }
    } finally {
      await sink.close();
    }

    return p.receivedBytes;
  }

  /// For GET handler; returns null if id/token invalid.
  MediaReadTarget? readTargetIfValid(String mediaId, String readToken) {
    final c = _completed[mediaId];
    if (c == null || c.readToken != readToken) return null;
    return MediaReadTarget(file: c.file, mimeType: c.mimeType);
  }

  MediaFinalizeData finalize({
    required String mediaId,
    required String finalizeToken,
    required int declaredTotalBytes,
    required Uri publicApiOrigin,
  }) {
    final p = _pending.remove(mediaId);
    if (p == null) {
      throw MediaUploadException('Unknown media id or already finalized');
    }
    if (finalizeToken != p.finalizeToken) {
      _pending[mediaId] = p;
      throw MediaUploadException('Invalid finalize token');
    }
    if (declaredTotalBytes != p.declaredLength) {
      _pending[mediaId] = p;
      throw MediaUploadException(
        'Declared total does not match session ($declaredTotalBytes vs ${p.declaredLength})',
      );
    }
    if (p.receivedBytes != p.declaredLength) {
      _pending[mediaId] = p;
      throw MediaUploadException(
        'Received bytes (${p.receivedBytes}) != declared (${p.declaredLength})',
      );
    }

    final readToken = _randomId();
    final dest = File('${_root.path}${Platform.pathSeparator}$mediaId.bin');
    if (dest.existsSync()) dest.deleteSync();
    p.partFile.renameSync(dest.path);

    _completed[mediaId] = _CompletedBlob(
      mediaId: mediaId,
      file: dest,
      mimeType: p.mimeType,
      readToken: readToken,
    );

    final fetchUrl = publicApiOrigin.replace(
      path: '/media/file/$mediaId',
      queryParameters: {'readToken': readToken},
    );

    return MediaFinalizeData(
      mediaId: mediaId,
      fetchUrl: fetchUrl.toString(),
    );
  }
}

class MediaSlotData {
  MediaSlotData({
    required this.mediaId,
    required this.uploadUrl,
    required this.expiresAt,
    required this.maxBytes,
    required this.chunkSizeBytes,
    required this.allowedMimeTypes,
    required this.finalizeToken,
  });

  final String mediaId;
  final String uploadUrl;
  final DateTime expiresAt;
  final int maxBytes;
  final int chunkSizeBytes;
  final List<String> allowedMimeTypes;
  final String finalizeToken;
}

class MediaFinalizeData {
  MediaFinalizeData({
    required this.mediaId,
    required this.fetchUrl,
  });

  final String mediaId;
  final String fetchUrl;
}

class MediaReadTarget {
  MediaReadTarget({
    required this.file,
    required this.mimeType,
  });

  final File file;
  final String mimeType;
}

class _PendingBlob {
  _PendingBlob({
    required this.mediaId,
    required this.uploadToken,
    required this.finalizeToken,
    required this.mimeType,
    required this.declaredLength,
    required this.maxBytes,
    required this.expiresAt,
    required this.partFile,
    this.chatId,
  });

  final String mediaId;
  final String uploadToken;
  final String finalizeToken;
  final String mimeType;
  final int declaredLength;
  final int maxBytes;
  final DateTime expiresAt;
  final File partFile;
  final String? chatId;
  int receivedBytes = 0;
}

class _CompletedBlob {
  _CompletedBlob({
    required this.mediaId,
    required this.file,
    required this.mimeType,
    required this.readToken,
  });

  final String mediaId;
  final File file;
  final String mimeType;
  final String readToken;
}

class MediaPolicyException implements Exception {
  MediaPolicyException(this.message);
  final String message;
  @override
  String toString() => message;
}

class MediaUploadException implements Exception {
  MediaUploadException(this.message);
  final String message;
  @override
  String toString() => message;
}

String _randomId() {
  final r = Random.secure();
  final bytes = List<int>.generate(16, (_) => r.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
