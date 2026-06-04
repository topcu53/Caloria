import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity> signInWithEmailAndPassword(String email, String password);
  Future<UserEntity> registerWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  });
  Future<UserEntity> signInAnonymously();
  Future<void> updateDisplayName(String name);
  Future<void> signOut();
  UserEntity? get currentUser;
}