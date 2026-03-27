import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../core/contacts/contacts_permission_state.dart';
import '../../domain/models/contact_model.dart';
import '../../domain/models/user_model.dart';

class ContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Maps platform permission to app state ([ContactsPermissionState.unsupported] on web).
  Future<ContactsPermissionState> readContactsPermissionState() async {
    if (kIsWeb) {
      return ContactsPermissionState.unsupported;
    }
    final status = await ph.Permission.contacts.status;
    return _mapPermissionStatus(status);
  }

  /// Shows the system contacts dialog (call after an in-app rationale).
  Future<ContactsPermissionState> requestContactsAccess() async {
    if (kIsWeb) {
      return ContactsPermissionState.unsupported;
    }
    final result = await ph.Permission.contacts.request();
    return _mapPermissionStatus(result);
  }

  ContactsPermissionState _mapPermissionStatus(ph.PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return ContactsPermissionState.granted;
    }
    if (status.isPermanentlyDenied) {
      return ContactsPermissionState.permanentlyDenied;
    }
    if (status.isDenied || status.isRestricted) {
      return ContactsPermissionState.denied;
    }
    return ContactsPermissionState.notDetermined;
  }

  Future<bool> isContactsAccessGranted() async {
    final s = await readContactsPermissionState();
    return s == ContactsPermissionState.granted;
  }

  /// Local address book entries with a phone number. Requires [ContactsPermissionState.granted].
  Future<List<ContactModel>> getLocalContacts() async {
    if (kIsWeb) {
      return [];
    }
    final state = await readContactsPermissionState();
    if (state != ContactsPermissionState.granted) {
      return [];
    }

    final contacts = await FlutterContacts.getAll(
      properties: {ContactProperty.phone},
    );
    return contacts
        .map((c) {
          final phone = c.phones.isEmpty
              ? ''
              : _normalizePhoneNumber(
                  c.phones.first.normalizedNumber ?? c.phones.first.number,
                );
          return ContactModel(
            id: c.id ?? '',
            displayName: c.displayName ?? 'Unknown',
            phoneNumber: phone,
          );
        })
        .where((c) => c.phoneNumber.isNotEmpty)
        .toList();
  }

  Future<List<ContactModel>> syncWithFirestore(
    List<ContactModel> localContacts,
  ) async {
    if (localContacts.isEmpty) return [];

    final phoneNumbers = localContacts.map((c) => c.phoneNumber).toList();

    List<ContactModel> syncedContacts = [];

    for (var i = 0; i < phoneNumbers.length; i += 10) {
      final chunk = phoneNumbers.sublist(
        i,
        i + 10 > phoneNumbers.length ? phoneNumbers.length : i + 10,
      );

      final snapshot = await _firestore
          .collection('users')
          .where('phoneNumber', whereIn: chunk)
          .get();

      final Map<String, UserModel> usersMap = {
        for (var doc in snapshot.docs)
          doc.data()['phoneNumber'] as String: UserModel.fromJson(doc.data()),
      };

      for (var local in localContacts.sublist(i, i + chunk.length)) {
        if (usersMap.containsKey(local.phoneNumber)) {
          final user = usersMap[local.phoneNumber]!;
          syncedContacts.add(
            local.copyWith(
              uid: user.id,
              avatarUrl: user.avatarUrl,
              status: user.status,
              isOnApp: true,
            ),
          );
        } else {
          syncedContacts.add(local);
        }
      }
    }

    return syncedContacts;
  }

  String _normalizePhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }
}
