import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/meal_entity.dart';

class MealRemoteDataSource {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> saveMeal(MealEntity meal, DateTime date) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('daily_logs')
        .doc(_dateKey(date))
        .collection(meal.mealType)
        .doc(meal.id)
        .set(meal.toMap());
  }

  Future<void> deleteMeal(String mealId, String mealType, DateTime date) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('daily_logs')
        .doc(_dateKey(date))
        .collection(mealType)
        .doc(mealId)
        .delete();
  }

  Stream<List<MealEntity>> watchMealsForDate(DateTime date, String mealType) {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('daily_logs')
        .doc(_dateKey(date))
        .collection(mealType)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MealEntity.fromMap(doc.data()))
            .toList());
  }
}