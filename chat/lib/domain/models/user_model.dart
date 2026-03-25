class UserModel {
  final String id;
  final String name;
  final String avatarUrl;
  final DateTime lastSeen;
  final String status;
  final List<String> blockedUsers;
  final String? fcmToken;
  final String? phoneNumber;

  UserModel({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    required this.lastSeen,
    this.status = 'offline',
    this.blockedUsers = const [],
    this.fcmToken,
    this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      status: json['status'] as String? ?? 'offline',
      blockedUsers: List<String>.from(json['blockedUsers'] as List? ?? []),
      fcmToken: json['fcmToken'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'lastSeen': lastSeen.toIso8601String(),
      'status': status,
      'blockedUsers': blockedUsers,
      'fcmToken': fcmToken,
      'phoneNumber': phoneNumber,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    DateTime? lastSeen,
    String? status,
    List<String>? blockedUsers,
    String? fcmToken,
    String? phoneNumber,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastSeen: lastSeen ?? this.lastSeen,
      status: status ?? this.status,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      fcmToken: fcmToken ?? this.fcmToken,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
