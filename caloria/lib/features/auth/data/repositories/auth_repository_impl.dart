import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource = AuthRemoteDataSource();

  @override
  Stream<UserEntity?> get authStateChanges => _dataSource.authStateChanges;

  @override
  Future<UserEntity> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _dataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<UserEntity> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _dataSource.registerWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }

  @override
  UserEntity? get currentUser => _dataSource.currentUser;
  @override
  Future<UserEntity> signInAnonymously() async {
    return await _dataSource.signInAnonymously();
  }
}
