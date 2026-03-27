import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Single entry for UI: gallery / camera image & video plus generic files.
///
/// Returns [XFile] for camera/gallery picks (works across mobile/desktop/web
/// where the plugin supports it). Generic [FilePicker] results expose
/// [PlatformFile.path] on IO platforms; on **web**, paths are often null—use
/// [PlatformFile.bytes] in the upload pipeline instead.
///
/// Compression stays in [MediaService] so uploads stay size-capped.
class PlatformMediaPicker {
  PlatformMediaPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<XFile?> pickImageFromGallery() =>
      _picker.pickImage(source: ImageSource.gallery);

  Future<XFile?> pickImageFromCamera() =>
      _picker.pickImage(source: ImageSource.camera);

  Future<XFile?> pickVideoFromGallery() =>
      _picker.pickVideo(source: ImageSource.gallery);

  Future<XFile?> pickVideoFromCamera() =>
      _picker.pickVideo(source: ImageSource.camera);

  /// Arbitrary files (documents, etc.).
  Future<List<PlatformFile>> pickFiles({bool allowMultiple = false}) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
    );
    if (result == null || result.files.isEmpty) {
      return [];
    }
    if (kIsWeb && result.files.any((f) => f.bytes == null && f.path == null)) {
      debugPrint(
        'PlatformMediaPicker: verify bytes are present for web uploads.',
      );
    }
    return result.files;
  }
}
