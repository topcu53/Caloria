import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/gemini_service.dart';
import '../../domain/entities/meal_analysis_entity.dart';

final geminiServiceProvider = Provider((ref) => GeminiService());

final aiAnalysisProvider =
    AsyncNotifierProvider<AiAnalysisNotifier, MealAnalysisEntity?>(
      AiAnalysisNotifier.new,
    );

class AiAnalysisNotifier extends AsyncNotifier<MealAnalysisEntity?> {
  @override
  Future<MealAnalysisEntity?> build() async => null;

  Future<void> analyzeImage(File image) async {
    state = const AsyncLoading();
    try {
      await ref.read(geminiServiceProvider).listModels(); // modelleri listele
      final result = await ref.read(geminiServiceProvider).analyzeMeal(image);
      state = AsyncData(result);
    } catch (e, st) {
      print('Gemini HATA: $e');
      print('Stack: $st');
      state = AsyncError(e, st);
    }
  }

  void reset() {
    state = const AsyncData(null);
  }
}
