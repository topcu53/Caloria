import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/weight_log_remote_datasource.dart';
import '../../domain/entities/weight_log_entity.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

final weightLogDataSourceProvider =
    Provider((ref) => WeightLogRemoteDataSource());

final weightLogsProvider = StreamProvider<List<WeightLogEntity>>((ref) {
  return ref.watch(weightLogDataSourceProvider).watchRecentWeights(limit: 30);
});

final todayWeightProvider = FutureProvider<WeightLogEntity?>((ref) async {
  return ref.watch(weightLogDataSourceProvider).getWeightForDate(DateTime.now());
});

final weightNotifierProvider =
    AsyncNotifierProvider<WeightNotifier, void>(WeightNotifier.new);

class WeightNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> saveMorningWeight(double weightKg) async {
    state = const AsyncLoading();
    try {
      await ref.read(weightLogDataSourceProvider).saveMorningWeight(
            DateTime.now(),
            weightKg,
          );
      await ref
          .read(profileNotifierProvider.notifier)
          .updateGoalsFromMorningWeight(weightKg);
      ref.invalidate(weightLogsProvider);
      ref.invalidate(todayWeightProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(profileNotifierProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
