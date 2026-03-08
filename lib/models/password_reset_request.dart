import 'package:cloud_firestore/cloud_firestore.dart';

class PasswordResetRequest {
  PasswordResetRequest({
    required this.resetId,
    required this.email,
    required this.userId,
    required this.otpSent,
    required this.requestTime,
    required this.status,
  });

  final String resetId;
  final String email;
  final String userId;
  final bool otpSent;
  final Timestamp requestTime;
  final String status;

  Map<String, Object?> toFirestore() => {
        'email': email,
        'otpSent': otpSent,
        'requestTime': requestTime,
        'resetId': resetId,
        'status': status,
        'userId': userId,
      };
}

