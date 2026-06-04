import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/daily_log_summary.dart';
import '../../domain/entities/meal_entity.dart';

class DailyLogRemoteDataSource {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  static const mealTypes = ['breakfast', 'lunch', 'dinner', 'snacks'];

  String get _uid => _auth.currentUser!.uid;

  static String dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DocumentReference<Map<String, dynamic>> _dayRef(String key) =>
      _firestore.collection('users').doc(_uid).collection('daily_logs').doc(key);

  Future<List<String>> fetchRecentDateKeys({int limit = 30}) async {
    // orderBy documentId Firestore indeksi gerektirir; istemci tarafında sıralıyoruz.
    final snap = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('daily_logs')
        .get();

    final keys = snap.docs.map((d) => d.id).toList();
    keys.sort((a, b) => b.compareTo(a));
    if (keys.length > limit) {
      return keys.sublist(0, limit);
    }
    return keys;
  }

  Future<DailyLogSummary> fetchDaySummary(DateTime date) async {
    final key = dateKey(date);
    final dayDoc = await _dayRef(key).get();
    final waterMl = (dayDoc.data()?['waterMl'] as num?)?.toDouble() ?? 0;

    final meals = <MealEntity>[];
    for (final type in mealTypes) {
      final snap = await _dayRef(key).collection(type).get();
      meals.addAll(snap.docs.map((d) => MealEntity.fromMap(d.data())));
    }

    meals.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return DailyLogSummary(
      dateKey: key,
      date: date,
      meals: meals,
      waterMl: waterMl,
    );
  }

  Stream<double> watchWaterMl(DateTime date) {
    final key = dateKey(date);
    return _dayRef(key).snapshots().map(
          (doc) => (doc.data()?['waterMl'] as num?)?.toDouble() ?? 0,
        );
  }

  Future<void> setWaterMl(DateTime date, double waterMl) async {
    final key = dateKey(date);
    await _dayRef(key).set(
      {
        'waterMl': waterMl,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> addWaterMl(DateTime date, double amountMl) async {
    final key = dateKey(date);
    final doc = await _dayRef(key).get();
    final current = (doc.data()?['waterMl'] as num?)?.toDouble() ?? 0;
    await setWaterMl(date, current + amountMl);
  }
}
