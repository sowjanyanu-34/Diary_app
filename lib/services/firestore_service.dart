import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/app_user.dart';
import '../models/diary_note.dart';
import '../models/login_history.dart';
import '../models/password_reset_request.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  static const _uuid = Uuid();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, Object?>> get _users =>
      _db.collection('users').withConverter<Map<String, Object?>>(
            fromFirestore: (snap, _) => (snap.data() ?? <String, Object?>{}),
            toFirestore: (value, _) => value,
          );

  CollectionReference<Map<String, Object?>> get _diaryNotes =>
      _db.collection('diary_notes').withConverter<Map<String, Object?>>(
            fromFirestore: (snap, _) => (snap.data() ?? <String, Object?>{}),
            toFirestore: (value, _) => value,
          );

  CollectionReference<Map<String, Object?>> get _loginHistory =>
      _db.collection('login_history').withConverter<Map<String, Object?>>(
            fromFirestore: (snap, _) => (snap.data() ?? <String, Object?>{}),
            toFirestore: (value, _) => value,
          );

  CollectionReference<Map<String, Object?>> get _passwordReset =>
      _db.collection('password_reset').withConverter<Map<String, Object?>>(
            fromFirestore: (snap, _) => (snap.data() ?? <String, Object?>{}),
            toFirestore: (value, _) => value,
          );

  Future<void> upsertUser(AppUser user) async {
    await _users.doc(user.userId).set(user.toFirestore(), SetOptions(merge: true));
  }

  Future<void> updateUserLastLogin({
    required String userId,
    required Timestamp lastLogin,
  }) async {
    await _users.doc(userId).set({'lastLogin': lastLogin}, SetOptions(merge: true));
  }

  Future<void> addLoginHistory(String userId) async {
    final loginId = _uuid.v4();
    final entry = LoginHistory(
      loginId: loginId,
      userId: userId,
      loginTime: Timestamp.now(),
    );
    await _loginHistory.doc(loginId).set(entry.toFirestore());
  }

  static DateTime normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  String diaryDocIdForDay({required String userId, required DateTime day}) {
    final d = normalizeDate(day);
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${userId}_$y-$m-$dd';
  }

  Future<DiaryNote?> getDiaryNoteForDay({
    required String userId,
    required DateTime day,
  }) async {
    final docId = diaryDocIdForDay(userId: userId, day: day);
    final snap = await _diaryNotes.doc(docId).get();
    final data = snap.data();
    if (data == null) return null;
    return DiaryNote.fromFirestore(data);
  }

  Future<void> upsertDiaryNoteForDay({
    required String userId,
    required DateTime day,
    required String text,
    required String tag,
  }) async {
    final normalized = normalizeDate(day);
    final docId = diaryDocIdForDay(userId: userId, day: normalized);

    final existing = await _diaryNotes.doc(docId).get();
    final createdAt = (existing.data()?['createdAt'] as Timestamp?) ?? Timestamp.now();
    final noteId = (existing.data()?['noteId'] as String?) ?? _uuid.v4().split('-').first.toUpperCase();

    final note = DiaryNote(
      createdAt: createdAt,
      date: Timestamp.fromDate(normalized),
      noteId: noteId,
      tag: tag,
      text: text,
      userId: userId,
    );
    await _diaryNotes.doc(docId).set(note.toFirestore(), SetOptions(merge: true));
  }

  Future<List<DiaryNote>> listNotesByMonth({
    required String userId,
    required int year,
    required int month,
  }) async {
    final start = DateTime(year, month, 1);
    final end = (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    final q = await _diaryNotes
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .get();
    return q.docs.map((d) => DiaryNote.fromFirestore(d.data())).toList();
  }

  Future<List<DiaryNote>> listNotesByTag({
    required String userId,
    required String tag,
  }) async {
    final q = await _diaryNotes
        .where('userId', isEqualTo: userId)
        .where('tag', isEqualTo: tag)
        .orderBy('date', descending: true)
        .get();
    return q.docs.map((d) => DiaryNote.fromFirestore(d.data())).toList();
  }

  Future<void> logPasswordResetRequest({
    required String email,
    required String userId,
  }) async {
    final resetId = _uuid.v4();
    final req = PasswordResetRequest(
      resetId: resetId,
      email: email,
      otpSent: false,
      requestTime: Timestamp.now(),
      status: 'pending',
      userId: userId,
    );
    await _passwordReset.doc(resetId).set(req.toFirestore());
  }
}

