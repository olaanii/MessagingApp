import 'media_upload_store.dart';

/// Wired from [run] in `server.dart` before routes and endpoints handle traffic.
class MediaRuntime {
  MediaRuntime._();
  static final MediaRuntime instance = MediaRuntime._();

  late final MediaUploadStore store;
  late Uri publicApiOrigin;

  void init(MediaUploadStore uploadStore, Uri publicOrigin) {
    store = uploadStore;
    publicApiOrigin = publicOrigin;
  }
}
