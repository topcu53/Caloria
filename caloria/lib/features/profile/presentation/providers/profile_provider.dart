import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/nutrition_goal_calculator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../domain/entities/user_profile_entity.dart';

final profileDataSourceProvider = Provider((ref) => ProfileRemoteDataSource());

final userProfileProvider = StreamProvider<UserProfileEntity?>((ref) {
  return ref.watch(profileDataSourceProvider).watchUserProfile();
});

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfileEntity?>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<UserProfileEntity?> {
  @override
  Future<UserProfileEntity?> build() async {
    return ref.watch(profileDataSourceProvider).getUserProfile();
  }

  Future<void> saveProfile(UserProfileEntity profile) async {
    await ref.read(profileDataSourceProvider).saveUserProfile(profile);
    state = AsyncData(profile);
  }

  Future<void> saveBodyMetricsAndGoals({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
    required String goal,
    double? targetWeightKg,
  }) async {
    final goals = NutritionGoalCalculator.calculate(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
      activityLevel: activityLevel,
      goal: goal,
    );

    final base = await _currentOrNewProfile();
    final updated = base.copyWith(
      weight: weightKg,
      height: heightCm,
      age: age,
      gender: gender,
      activityLevel: activityLevel,
      goal: goal,
      dailyCalorieGoal: goals.dailyCalories,
      dailyProteinGoal: goals.dailyProtein,
      dailyCarbsGoal: goals.dailyCarbs,
      dailyFatGoal: goals.dailyFat,
      targetWeightKg: targetWeightKg,
    );

    await saveProfile(updated);
  }

  /// Sabah tartımı kaydedilirse kilo güncellenir ve hedefler yeniden hesaplanır.
  Future<void> updateGoalsFromMorningWeight(double weightKg) async {
    final base = await _currentOrNewProfile();
    if (!base.hasBodyMetrics && base.height == null) {
      await saveProfile(base.copyWith(weight: weightKg));
      return;
    }

    final height = base.height;
    final age = base.age;
    if (height == null || age == null || height <= 0) {
      await saveProfile(base.copyWith(weight: weightKg));
      return;
    }

    final goals = NutritionGoalCalculator.calculate(
      weightKg: weightKg,
      heightCm: height,
      age: age,
      gender: base.gender ?? 'male',
      activityLevel: base.activityLevel ?? 'moderate',
      goal: base.goal ?? 'maintain',
    );

    await saveProfile(
      base.copyWith(
        weight: weightKg,
        dailyCalorieGoal: goals.dailyCalories,
        dailyProteinGoal: goals.dailyProtein,
        dailyCarbsGoal: goals.dailyCarbs,
        dailyFatGoal: goals.dailyFat,
      ),
    );
  }

  Future<void> saveDisplayName(String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('İsim boş olamaz');
    }
    await ref.read(authRepositoryProvider).updateDisplayName(trimmed);
    final base = await _currentOrNewProfile();
    await saveProfile(base.copyWith(displayName: trimmed));
    ref.invalidate(authStateProvider);
  }

  Future<void> saveTargetWeight(double targetWeightKg) async {
    final base = await _currentOrNewProfile();
    await saveProfile(base.copyWith(targetWeightKg: targetWeightKg));
  }

  Future<void> setWaterReminderEnabled(bool enabled) async {
    final base = await _currentOrNewProfile();
    await saveProfile(base.copyWith(waterReminderEnabled: enabled));
  }

  Future<UserProfileEntity> _currentOrNewProfile() async {
    final user = FirebaseAuth.instance.currentUser!;
    final existing =
        state.valueOrNull ?? await ref.read(profileDataSourceProvider).getUserProfile();

    return existing ??
        UserProfileEntity(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
        );
  }
}
