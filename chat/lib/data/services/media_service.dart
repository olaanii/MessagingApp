import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

class MediaService {
  MediaService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage;

  /// Targets aligned with Serverpod [MediaUploadStore] defaults (images).
  static const int maxCompressedImageBytes = 8 * 1024 * 1024;
  static const int maxCompressedVideoBytes = 32 * 1024 * 1024;

  Future<File?> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// JPEG output; tightens quality and dimensions until under [maxOutputBytes] when possible.
  Future<File?> compressImage(
    File file, {
    int minSide = 1080,
    int quality = 70,
    int maxOutputBytes = maxCompressedImageBytes,
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(0);
    final dir = await getTemporaryDirectory();
    var q = quality;
    var side = minSide;

    for (var round = 0; round < 12; round++) {
      final targetPath =
          '${dir.absolute.path}/compressed_${DateTime.now().millisecondsSinceEpoch}_$round.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: q,
        minWidth: side,
        minHeight: side,
      );

      if (result == null) {
        onProgress?.call(1);
        return null;
      }

      final out = File(result.path);
      final len = await out.length();
      onProgress?.call((round + 1) / 12);

      if (len <= maxOutputBytes || q <= 35) {
        if (len > maxOutputBytes && kDebugMode) {
          debugPrint(
            'MediaService: image still ${len}b > cap $maxOutputBytes after compression',
          );
        }
        return out;
      }

      q = (q - 7).clamp(35, 85);
      side = (side * 0.85).round().clamp(480, 4096);
    }

    onProgress?.call(1);
    return null;
  }

  Future<String> uploadFile(File file, String path) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    return snapshot.ref.getDownloadURL();
  }

  Future<File?> pickVideo(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickVideo(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<File?> compressVideo(
    File file, {
    VideoQuality quality = VideoQuality.DefaultQuality,
    int maxOutputBytes = maxCompressedVideoBytes,
  }) async {
    try {
      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        file.path,
        quality: quality,
        deleteOrigin: false,
      );
      if (mediaInfo != null && mediaInfo.file != null) {
        final out = mediaInfo.file!;
        if (await out.length() > maxOutputBytes && kDebugMode) {
          debugPrint(
            'MediaService: video still exceeds cap $maxOutputBytes; '
            'tighten [VideoQuality] or trim before upload.',
          );
        }
        return out;
      }
    } catch (e) {
      debugPrint('Video compression failed: $e');
    }
    return null;
  }

  /// Best-effort MIME for slot requests (Serverpod allowlist).
  static String guessMimeType(File file) {
    final ext = p.extension(file.path).toLowerCase();
    return switch (ext) {
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.png' => 'image/png',
      '.webp' => 'image/webp',
      '.mp4' => 'video/mp4',
      _ => 'application/octet-stream',
    };
  }
}
