/// Policy notes for reading **long-lived secrets** (e.g. E2EE keys) via
/// `flutter_secure_storage`.
///
/// **Biometric re-prompt (optional product feature):** Use `local_auth` before
/// decrypting or restoring a session on sensitive surfaces. Add a cooldown so
/// every keystroke does not trigger a prompt.
///
/// **Scope:** Biometrics gate **UI-level** access to keys already on device;
/// they complement—never replace—disk encryption, OS lock screen, and server
/// session revocation.
final class SecureStorageAccessPolicy {
  const SecureStorageAccessPolicy._();
}
