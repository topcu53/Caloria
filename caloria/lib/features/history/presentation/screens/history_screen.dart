import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../meals/presentation/providers/daily_log_provider.dart';
import '../widgets/day_log_tile.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datesAsync = ref.watch(historyDatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Geçmiş')),
      body: datesAsync.when(
        data: (dates) {
          if (dates.isEmpty) {
            return const Center(
              child: Text(
                'Henüz kayıt yok.\nÖğün ekledikçe geçmişiniz burada görünür.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(historyDatesProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Önceki günlerin öğün ve su kayıtları',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                ...dates.map((key) => DayLogTile(dateKey: key)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}
