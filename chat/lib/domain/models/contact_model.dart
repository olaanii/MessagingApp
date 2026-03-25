class ContactModel {
  final String id;
  final String displayName;
  final String phoneNumber;
  final String? uid;
  final String? avatarUrl;
  final String? status;
  final bool isOnApp;

  ContactModel({
    required this.id,
    required this.displayName,
    required this.phoneNumber,
    this.uid,
    this.avatarUrl,
    this.status,
    this.isOnApp = false,
  });

  ContactModel copyWith({
    String? id,
    String? displayName,
    String? phoneNumber,
    String? uid,
    String? avatarUrl,
    String? status,
    bool? isOnApp,
  }) {
    return ContactModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      uid: uid ?? this.uid,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      isOnApp: isOnApp ?? this.isOnApp,
    );
  }
}
