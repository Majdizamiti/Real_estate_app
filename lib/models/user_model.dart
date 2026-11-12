enum UserRole { client, propertyOwner }

extension UserRoleExtension on UserRole {
  String toShortString() {
    switch (this) {
      case UserRole.client:
        return 'client';
      case UserRole.propertyOwner:
        return 'property_owner';
    }
  }

  static UserRole fromString(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'property_owner':
      case 'propertyowner':
      case 'owner':
        return UserRole.propertyOwner;
      case 'client':
      default:
        return UserRole.client;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.client:
        return 'Client / Buyer';
      case UserRole.propertyOwner:
        return 'Property Owner';
    }
  }
}

class UserModel {
  final String uid;
  final String email;
  final String username;
  final UserRole role;
  final String? photoUrl;
  final double? minBudget;
  final double? maxBudget;
  final String? preferredLocation;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.role,
    this.photoUrl,
    this.minBudget,
    this.maxBudget,
    this.preferredLocation,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'role': role.toShortString(),
      'photoUrl': photoUrl,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'preferredLocation': preferredLocation,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      username: map['username'] ?? 'User',
      role: UserRoleExtension.fromString(map['role'] ?? 'client'),
      photoUrl: map['photoUrl'],
      minBudget: (map['minBudget'] as num?)?.toDouble(),
      maxBudget: (map['maxBudget'] as num?)?.toDouble(),
      preferredLocation: map['preferredLocation'],
    );
  }

  UserModel copyWith({
    String? username,
    UserRole? role,
    String? photoUrl,
    double? minBudget,
    double? maxBudget,
    String? preferredLocation,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      username: username ?? this.username,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      preferredLocation: preferredLocation ?? this.preferredLocation,
    );
  }
}
