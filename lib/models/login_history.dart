import 'package:cloud_firestore/cloud_firestore.dart';

class LoginHistory {
  LoginHistory({
    required this.loginId,
    required this.userId,
    required this.loginTime,
  });

  final String loginId;
  final String userId;
  final Timestamp loginTime;

  Map<String, Object?> toFirestore() => {
        'loginId': loginId,
        'loginTime': loginTime,
        'userId': userId,
      };
}

