import 'package:chat/core/device/device_id_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceIdService', () {
    late DeviceIdService service;

    setUp(() {
      service = DeviceIdService();
      SharedPreferences.setMockInitialValues({});
    });

    test('generates a device ID on first call', () async {
      final deviceId = await service.getDeviceId();

      expect(deviceId, isNotEmpty);
      expect(deviceId.length, 36); // UUID v4 format
    });

    test('returns the same device ID on subsequent calls', () async {
      final firstId = await service.getDeviceId();
      final secondId = await service.getDeviceId();
      final thirdId = await service.getDeviceId();

      expect(secondId, equals(firstId));
      expect(thirdId, equals(firstId));
    });

    test('persists device ID across service instances', () async {
      final service1 = DeviceIdService();
      final id1 = await service1.getDeviceId();

      final service2 = DeviceIdService();
      final id2 = await service2.getDeviceId();

      expect(id2, equals(id1));
    });

    test('clearDeviceId removes the stored ID', () async {
      final firstId = await service.getDeviceId();
      expect(firstId, isNotEmpty);

      await service.clearDeviceId();

      final newId = await service.getDeviceId();
      expect(newId, isNotEmpty);
      expect(newId, isNot(equals(firstId)));
    });

    test('uses cached value for performance', () async {
      // First call generates and stores
      final id1 = await service.getDeviceId();

      // Clear storage but not cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('stable_device_id');

      // Should still return cached value
      final id2 = await service.getDeviceId();
      expect(id2, equals(id1));
    });
  });
}
