import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart' hide PermissionStatus;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/contact_model.dart';
import '../../domain/models/user_model.dart';

class ContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> requestPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  Future<List<ContactModel>> getLocalContacts() async {
    final status = await FlutterContacts.permissions.request(PermissionType.read);
    if (status != PermissionStatus.granted && status != PermissionStatus.limited) {
      return [];
    }

    final contacts = await FlutterContacts.getAll(
      properties: {ContactProperty.phone},
    );
    return contacts.map((c) {
      final phone = c.phones.isNotEmpty 
          ? _normalizePhoneNumber(c.phones.first.number) 
          : '';
      return ContactModel(
        id: c.id ?? '',
        displayName: c.displayName ?? 'Unknown',
        phoneNumber: phone,
      );
    }).where((c) => c.phoneNumber.isNotEmpty).toList();
  }

  Future<List<ContactModel>> syncWithFirestore(List<ContactModel> localContacts) async {
    if (localContacts.isEmpty) return [];

    final phoneNumbers = localContacts.map((c) => c.phoneNumber).toList();
    
    // Firestore has a limit of 10 for 'whereIn' queries. 
    // For MVP, we'll chunk the requests.
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
          doc.data()['phoneNumber'] as String: UserModel.fromJson(doc.data())
      };

      for (var local in localContacts.sublist(i, i + chunk.length)) {
        if (usersMap.containsKey(local.phoneNumber)) {
          final user = usersMap[local.phoneNumber]!;
          syncedContacts.add(local.copyWith(
            uid: user.id,
            avatarUrl: user.avatarUrl,
            status: user.status,
            isOnApp: true,
          ));
        } else {
          syncedContacts.add(local);
        }
      }
    }

    return syncedContacts;
  }

  String _normalizePhoneNumber(String phone) {
    // Remove all non-digit characters except '+'
    String normalized = phone.replaceAll(RegExp(r'[^\d+]'), '');
    // If it doesn't start with '+', it might be a local number. 
    // In a real app we'd need the country code. For MVP we assume international format is preferred.
    return normalized;
  }
}
