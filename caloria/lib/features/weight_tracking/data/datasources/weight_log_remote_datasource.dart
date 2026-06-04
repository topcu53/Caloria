import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/weight_log_entity.dart';
import '../../../meals/data/datasources/daily_log_remote_datasource.dart';

class WeightLogRemoteDataSource {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users').doc(_uid).collection('weight_logs');

  Future<void> saveMorningWeight(DateTime date, double weightKg) async {
    final key = DailyLogRemoteDataSource.dateKey(date);
    await _col.doc(key).set(
      WeightLogEntity(
        dateKey: key,
        weightKg: weightKg,
        recordedAt: DateTime.now(),
      ).toMap(),
    );
  }

  Future<WeightLogEntity?> getWeightForDate(DateTime date) async {
    final key = DailyLogRemoteDataSource.dateKey(date);
    final doc = await _col.doc(key).get();
    if (!doc.exists || doc.data() == null) return null;
    return WeightLogEntity.fromMap(key, doc.data()!);
  }

  Stream<List<WeightLogEntity>> watchRecentWeights({int limit = 30}) {
    return _col.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => WeightLogEntity.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.dateKey.compareTo(a.dateKey));
      if (list.length > limit) {
        return list.sublist(0, limit);
      }
      return list;
    });
  }
}
