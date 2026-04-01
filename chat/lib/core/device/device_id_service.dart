import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Service for managing a stable device identifier.
///
/// Generates a UUID on first access and persists it in SharedPreferences
/// so the same device ID is used across app restarts.
class DeviceIdService {
  static const String _deviceIdKey = 'stable_device_id';
  static const _uuid = Uuid();

  String? _cachedDeviceId;

  /// Gets or generates a stable device ID.
  ///
  /// On first call, generates a new UUID and stores it. Subsequent calls
  /// return the same ID from cache or storage.
  Future<String> getDeviceId() async {
    // Return cached value if available
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    // Try to load from storage
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_deviceIdKey);

    if (stored != null && stored.isNotEmpty) {
      _cachedDeviceId = stored;
      return stored;
    }

    // Generate new device ID and persist it
    final newDeviceId = _uuid.v4();
    await prefs.setString(_deviceIdKey, newDeviceId);
    _cachedDeviceId = newDeviceId;

    return newDeviceId;
  }

  /// Clears the device ID (useful for testing or logout scenarios).
  Future<void> clearDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
    _cachedDeviceId = null;
  }
}
