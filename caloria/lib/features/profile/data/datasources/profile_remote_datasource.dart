import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileRemoteDataSource {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  Future<void> saveUserProfile(UserProfileEntity profile) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<UserProfileEntity?> getUserProfile() async {
    final doc = await _firestore.collection('users').doc(_uid).get();
    if (!doc.exists) return null;
    return UserProfileEntity.fromMap(doc.data()!);
  }

  Stream<UserProfileEntity?> watchUserProfile() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserProfileEntity.fromMap(doc.data()!);
    });
  }
}