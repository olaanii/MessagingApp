import 'dart:io';

import 'package:chat_server/src/media/media_upload_store.dart';
import 'package:test/test.dart';

void main() {
  test('startSlot rejects disallowed MIME', () {
    final store = MediaUploadStore();
    expect(
      () => store.startSlot(
        mimeType: 'application/x-executable',
        byteLength: 10,
        publicApiOrigin: Uri.parse('http://localhost:8080'),
      ),
      throwsA(isA<MediaPolicyException>()),
    );
  });

  test('finalize succeeds after full single chunk', () async {
    final dir = Directory.systemTemp.createTempSync('chat_media_test');
    final store = MediaUploadStore(uploadRoot: dir);
    addTearDown(() {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });

    const len = 42;
    final slot = store.startSlot(
      mimeType: 'image/jpeg',
      byteLength: len,
      chatId: 'c1',
      publicApiOrigin: Uri.parse('http://localhost:8080'),
    );

    final uri = Uri.parse(slot.uploadUrl);
    final token = uri.queryParameters['token']!;
    final mediaId = slot.mediaId;

    await store.appendChunk(
      mediaId: mediaId,
      token: token,
      chunkStart: 0,
      bytes: Stream.value(List<int>.generate(len, (i) => i % 256)),
    );

    final fin = store.finalize(
      mediaId: mediaId,
      finalizeToken: slot.finalizeToken,
      declaredTotalBytes: len,
      publicApiOrigin: Uri(scheme: 'http', host: 'localhost', port: 8080),
    );

    expect(fin.fetchUrl, contains('/media/file/$mediaId'));
  });
}
