import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  AppUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.lastLogin,
  });

  final String userId;
  final String email;
  final String name;
  final Timestamp createdAt;
  final Timestamp lastLogin;

  Map<String, Object?> toFirestore() => {
        'email': email,
        'createdAt': createdAt,
        'lastLogin': lastLogin,
        'name': name,
        'userId': userId,
      };

  static AppUser fromFirestore(Map<String, Object?> data) {
    return AppUser(
      userId: (data['userId'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      name: (data['name'] ?? '') as String,
      createdAt: (data['createdAt'] as Timestamp?) ?? Timestamp.now(),
      lastLogin: (data['lastLogin'] as Timestamp?) ?? Timestamp.now(),
    );
  }
}

