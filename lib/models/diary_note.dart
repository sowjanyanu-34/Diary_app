import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryNote {
  DiaryNote({
    required this.noteId,
    required this.userId,
    required this.text,
    required this.tag,
    required this.date,
    required this.createdAt,
  });

  final String noteId;
  final String userId;
  final String text;
  final String tag;
  final Timestamp date;
  final Timestamp createdAt;

  Map<String, Object?> toFirestore() => {
        'createdAt': createdAt,
        'date': date,
        'noteId': noteId,
        'tag': tag,
        'text': text,
        'userId': userId,
      };

  static DiaryNote fromFirestore(Map<String, Object?> data) {
    return DiaryNote(
      createdAt: (data['createdAt'] as Timestamp?) ?? Timestamp.now(),
      date: (data['date'] as Timestamp?) ?? Timestamp.now(),
      noteId: (data['noteId'] ?? '') as String,
      tag: (data['tag'] ?? '') as String,
      text: (data['text'] ?? '') as String,
      userId: (data['userId'] ?? '') as String,
    );
  }
}

