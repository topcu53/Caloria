import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../domain/entities/user_profile_entity.dart';

final profileDataSourceProvider = Provider((ref) => ProfileRemoteDataSource());

final userProfileProvider = StreamProvider<UserProfileEntity?>((ref) {
  return ref.watch(profileDataSourceProvider).watchUserProfile();
});

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfileEntity?>(
        ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<UserProfileEntity?> {
  @override
  Future<UserProfileEntity?> build() async {
    return ref.watch(profileDataSourceProvider).getUserProfile();
  }

  Future<void> saveProfile(UserProfileEntity profile) async {
    await ref.read(profileDataSourceProvider).saveUserProfile(profile);
    state = AsyncData(profile);
  }
}