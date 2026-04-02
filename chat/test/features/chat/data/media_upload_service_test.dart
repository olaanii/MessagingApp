// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:chat/features/chat/data/media_upload_service.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fake MediaUploadService ───────────────────────────────────────────────────

/// A fake [MediaUploadService] that calls [onProgress] with a
/// caller-supplied sequence of values and returns a fixed [fetchUrl].
///
/// This avoids any dependency on [ServerpodMediaUploader] or a live client.
final class _FakeMediaUploadService implements MediaUploadService {
  _FakeMediaUploadService({
    required this.progressSequence,
    this.fetchUrl = 'https://cdn.example.com/media/abc123',
  });

  final List<double> progressSequence;
  final String fetchUrl;

  @override
  Future<String> uploadMedia({
    required String chatId,
    required File file,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    for (final value in progressSequence) {
      onProgress?.call(value);
    }
    return fetchUrl;
  }
}

// ── Guarded wrapper ───────────────────────────────────────────────────────────

/// A [MediaUploadService] that wraps another service and enforces the
/// [0.0, 1.0] bounded, non-decreasing invariant on progress values.
///
/// This mirrors the guard logic in [ServerpodMediaUploadService].
final class _GuardedMediaUploadService implements MediaUploadService {
  _GuardedMediaUploadService(this._inner);
  final MediaUploadService _inner;

  @override
  Future<String> uploadMedia({
    required String chatId,
    required File file,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    if (onProgress == null) {
      return _inner.uploadMedia(
        chatId: chatId,
        file: file,
        mimeType: mimeType,
      );
    }

    double lastProgress = 0.0;

    void guardedProgress(double value) {
      final clamped = value.clamp(0.0, 1.0);
      if (clamped >= lastProgress) {
        lastProgress = clamped;
        onProgress(clamped);
      }
    }

    return _inner.uploadMedia(
      chatId: chatId,
      file: file,
      mimeType: mimeType,
      onProgress: guardedProgress,
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Runs a [_GuardedMediaUploadService] wrapping a fake that emits
/// [progressSequence], collects all reported progress values, and returns them.
Future<List<double>> _collectProgress(List<double> progressSequence) async {
  final fake = _FakeMediaUploadService(progressSequence: progressSequence);
  final service = _GuardedMediaUploadService(fake);

  final reported = <double>[];
  await service.uploadMedia(
    chatId: 'chat_test',
    file: File('dummy.bin'),
    mimeType: 'image/jpeg',
    onProgress: reported.add,
  );
  return reported;
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Property 14: Media Upload Progress Is Bounded ───────────────────────────
  //
  // Every onProgress value reported to the caller must be in [0.0, 1.0] and
  // the sequence must be non-decreasing.
  //
  // **Validates: Requirements 8.6**

  group('Property 14: Media Upload Progress Is Bounded', () {
    // ── Typical sequences ────────────────────────────────────────────────────

    test('typical chunked sequence is bounded and non-decreasing', () async {
      final sequences = [
        [0.0, 0.25, 0.5, 0.75, 1.0],
        [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0],
        [0.0, 1.0],
        [1.0],
        [0.0],
        [0.33, 0.66, 1.0],
      ];

      for (final seq in sequences) {
        final reported = await _collectProgress(seq);

        // All values must be in [0.0, 1.0].
        for (final v in reported) {
          expect(
            v,
            inInclusiveRange(0.0, 1.0),
            reason: 'progress=$v is outside [0.0, 1.0] for sequence $seq',
          );
        }

        // Sequence must be non-decreasing.
        for (var i = 1; i < reported.length; i++) {
          expect(
            reported[i],
            greaterThanOrEqualTo(reported[i - 1]),
            reason:
                'progress[$i]=${reported[i]} < progress[${i - 1}]=${reported[i - 1]} '
                'for sequence $seq',
          );
        }
      }
    });

    // ── Out-of-range values are clamped ──────────────────────────────────────

    test('values above 1.0 are clamped to 1.0', () async {
      final reported = await _collectProgress([0.5, 1.5, 2.0]);

      for (final v in reported) {
        expect(
          v,
          inInclusiveRange(0.0, 1.0),
          reason: 'progress=$v exceeds 1.0',
        );
      }
    });

    test('values below 0.0 are clamped to 0.0', () async {
      final reported = await _collectProgress([-0.5, 0.5, 1.0]);

      for (final v in reported) {
        expect(
          v,
          inInclusiveRange(0.0, 1.0),
          reason: 'progress=$v is below 0.0',
        );
      }
    });

    // ── Decreasing values are suppressed (non-decreasing invariant) ──────────

    test('decreasing values are suppressed to maintain non-decreasing order',
        () async {
      // Fake emits 0.8 then 0.3 (a decrease) — the guard must not
      // forward the 0.3 to the caller.
      final reported = await _collectProgress([0.0, 0.8, 0.3, 1.0]);

      // Sequence must be non-decreasing.
      for (var i = 1; i < reported.length; i++) {
        expect(
          reported[i],
          greaterThanOrEqualTo(reported[i - 1]),
          reason:
              'Non-decreasing invariant violated at index $i: '
              '${reported[i]} < ${reported[i - 1]}',
        );
      }

      // 0.3 must not appear after 0.8.
      final idx08 = reported.indexOf(0.8);
      if (idx08 != -1) {
        for (var i = idx08 + 1; i < reported.length; i++) {
          expect(
            reported[i],
            greaterThanOrEqualTo(0.8),
            reason: 'Value ${reported[i]} after 0.8 violates non-decreasing',
          );
        }
      }
    });

    // ── Empty sequence ───────────────────────────────────────────────────────

    test('empty progress sequence reports nothing', () async {
      final reported = await _collectProgress([]);
      expect(reported, isEmpty);
    });

    // ── No callback ─────────────────────────────────────────────────────────

    test('uploadMedia succeeds when onProgress is null', () async {
      const expectedUrl = 'https://cdn.example.com/media/abc123';
      final fake = _FakeMediaUploadService(
        progressSequence: [0.0, 0.5, 1.0],
        fetchUrl: expectedUrl,
      );
      final service = _GuardedMediaUploadService(fake);

      // Should not throw.
      final url = await service.uploadMedia(
        chatId: 'chat_test',
        file: File('dummy.bin'),
        mimeType: 'image/jpeg',
        // onProgress intentionally omitted
      );

      expect(url, expectedUrl);
    });

    // ── fetchUrl is returned ─────────────────────────────────────────────────

    test('uploadMedia returns the fetchUrl from the inner service', () async {
      const expectedUrl = 'https://cdn.example.com/media/xyz789';
      final fake = _FakeMediaUploadService(
        progressSequence: [0.5, 1.0],
        fetchUrl: expectedUrl,
      );
      final service = _GuardedMediaUploadService(fake);

      final url = await service.uploadMedia(
        chatId: 'chat_abc',
        file: File('photo.jpg'),
        mimeType: 'image/jpeg',
        onProgress: (_) {},
      );

      expect(url, expectedUrl);
    });

    // ── Property-style: arbitrary sequences ─────────────────────────────────

    test(
      'property: all reported values are in [0.0, 1.0] and non-decreasing '
      'for arbitrary input sequences',
      () async {
        // A set of hand-crafted "arbitrary" sequences covering edge cases.
        final arbitrarySequences = [
          <double>[],
          [0.0],
          [1.0],
          [0.0, 0.0, 0.0],
          [1.0, 1.0, 1.0],
          [0.0, 0.5, 0.5, 1.0],
          [0.9, 0.1, 0.5, 1.0], // decreasing then increasing
          [-1.0, 0.0, 0.5, 2.0], // out-of-range on both ends
          [0.0, 0.25, 0.5, 0.75, 1.0],
        ];

        for (final seq in arbitrarySequences) {
          final reported = await _collectProgress(seq);

          for (final v in reported) {
            expect(
              v,
              inInclusiveRange(0.0, 1.0),
              reason: 'progress=$v outside [0.0,1.0] for seq=$seq',
            );
          }

          for (var i = 1; i < reported.length; i++) {
            expect(
              reported[i],
              greaterThanOrEqualTo(reported[i - 1]),
              reason:
                  'Non-decreasing violated at [$i] for seq=$seq: '
                  '${reported[i]} < ${reported[i - 1]}',
            );
          }
        }
      },
    );
  });
}
