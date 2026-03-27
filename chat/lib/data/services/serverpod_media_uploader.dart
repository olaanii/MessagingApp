import 'dart:io';
import 'dart:typed_data';

import 'package:chat_client/chat_client.dart';
import 'package:http/http.dart' as http;

/// Chunked PUT to [MediaUploadSlot.uploadUrl] + RPC finalize (cross-functional media pipeline).
class ServerpodMediaUploader {
  ServerpodMediaUploader(
    this._client, {
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final Client _client;
  final http.Client _http;

  /// Returns [MediaFinalizeResult.fetchUrl] for attaching to messages as `media_id` / preview URL.
  Future<String> uploadFile({
    required File file,
    required String mimeType,
    String? chatId,
    void Function(double progress)? onProgress,
    bool Function()? isCancelled,
    int maxChunkRetries = 4,
  }) async {
    final length = await file.length();
    final slot = await _client.media.requestUploadSlot(
      MediaUploadRequest(
        fileName: file.path.split(Platform.pathSeparator).last,
        mimeType: mimeType,
        byteLength: length,
        chatId: chatId,
      ),
    );

    final uri = Uri.parse(slot.uploadUrl);
    final chunkSize = slot.chunkSizeBytes;
    var offset = 0;
    final raf = await file.open();

    try {
      while (offset < length) {
        if (isCancelled?.call() == true) {
          throw StateError('upload_cancelled');
        }
        final take = (offset + chunkSize > length)
            ? length - offset
            : chunkSize;
        await raf.setPosition(offset);
        final bytes = await raf.read(take);

        await _putChunkWithRetry(
          uri: uri,
          chunkStart: offset,
          body: bytes,
          maxRetries: maxChunkRetries,
          isCancelled: isCancelled,
        );

        offset += take;
        onProgress?.call(length == 0 ? 1 : offset / length);
      }
    } finally {
      await raf.close();
    }

    final fin = await _client.media.finalizeUpload(
      slot.mediaId,
      slot.finalizeToken,
      length,
    );
    return fin.fetchUrl;
  }

  Future<void> _putChunkWithRetry({
    required Uri uri,
    required int chunkStart,
    required List<int> body,
    required int maxRetries,
    bool Function()? isCancelled,
  }) async {
    var attempt = 0;
    while (true) {
      if (isCancelled?.call() == true) {
        throw StateError('upload_cancelled');
      }
      try {
        final req = http.Request('PUT', uri);
        req.headers['X-Chunk-Start'] = '$chunkStart';
        req.bodyBytes = body is Uint8List ? body : Uint8List.fromList(body);
        final streamed = await _http.send(req);
        final resp = await http.Response.fromStream(streamed);
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          return;
        }
        throw MediaChunkHttpException('HTTP ${resp.statusCode}', uri: uri);
      } catch (_) {
        attempt++;
        if (attempt >= maxRetries) {
          rethrow;
        }
        await Future<void>.delayed(Duration(milliseconds: 150 * attempt));
      }
    }
  }

  void close() {
    _http.close();
  }
}

class MediaChunkHttpException implements Exception {
  MediaChunkHttpException(this.message, {this.uri});
  final String message;
  final Uri? uri;
  @override
  String toString() => message;
}
