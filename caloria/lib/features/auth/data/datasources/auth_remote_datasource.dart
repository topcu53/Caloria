import 'package:firebase_auth/firebase_auth.dart';
import '../../../profile/data/datasources/profile_remote_datasource.dart';
import '../../../profile/domain/entities/user_profile_entity.dart';
import '../../domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProfileRemoteDataSource _profileDataSource = ProfileRemoteDataSource();

  UserEntity _mapUser(User user) {
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
    );
  }

  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapUser(user);
    });
  }

  Future<UserEntity> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final entity = _mapUser(credential.user!);
    await _ensureFirestoreProfile(entity);
    return entity;
  }

  Future<UserEntity> registerWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    if (displayName != null && displayName.trim().isNotEmpty) {
      await user.updateDisplayName(displayName.trim());
      await user.reload();
    }
    final entity = _mapUser(_auth.currentUser!);
    await _ensureFirestoreProfile(
      entity,
      defaultDisplayName: displayName?.trim(),
    );
    return entity;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  UserEntity? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _mapUser(user);
  }

  Future<UserEntity> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();
    final entity = _mapUser(credential.user!);
    await _ensureFirestoreProfile(
      entity,
      defaultDisplayName: 'Misafir',
    );
    return entity;
  }

  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(name.trim());
    await user.reload();
  }

  Future<void> _ensureFirestoreProfile(
    UserEntity user, {
    String? defaultDisplayName,
  }) async {
    final existing = await _profileDataSource.getUserProfile();
    if (existing != null) {
      if (existing.displayName == null &&
          defaultDisplayName != null &&
          defaultDisplayName.isNotEmpty) {
        await _profileDataSource.saveUserProfile(
          existing.copyWith(displayName: defaultDisplayName),
        );
      }
      return;
    }

    await _profileDataSource.saveUserProfile(
      UserProfileEntity(
        id: user.id,
        email: user.email,
        displayName: defaultDisplayName ?? user.displayName,
      ),
    );
  }
}
