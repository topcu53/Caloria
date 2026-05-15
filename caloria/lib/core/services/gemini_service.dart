import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../features/ai_analysis/domain/entities/meal_analysis_entity.dart';

class GeminiService {
  final _dio = Dio();

  static const _prompt = '''
Sen bir beslenme uzmanısın. Bu yemek fotoğrafını analiz et ve aşağıdaki JSON formatında yanıt ver.
Sadece JSON döndür, başka hiçbir şey yazma.

{
  "food": "yemeğin adı (Türkçe)",
  "calories": kalori_sayısı,
  "protein": protein_gram,
  "carbs": karbonhidrat_gram,
  "fat": yağ_gram,
  "portion": "porsiyon açıklaması"
}

Türk yemeklerini de tanı. Yaklaşık değerler ver.
''';

  Future<void> listModels() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final response = await _dio.get(
      'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey',
    );
    print('MODELLER: ${response.data}');
  }

  Future<MealAnalysisEntity> analyzeMeal(File imageFile) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    String mimeType = 'image/jpeg';
    if (imageFile.path.toLowerCase().endsWith('.png')) {
      mimeType = 'image/png';
    } else if (imageFile.path.toLowerCase().endsWith('.heic')) {
      mimeType = 'image/heic';
    } else if (imageFile.path.toLowerCase().endsWith('.heif')) {
      mimeType = 'image/heif';
    }

    final response = await _dio.post(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey',
      data: {
        'contents': [
          {
            'parts': [
              {
                'inline_data': {'mime_type': mimeType, 'data': base64Image},
              },
              {'text': _prompt},
            ],
          },
        ],
        'generationConfig': {'temperature': 0.1, 'maxOutputTokens': 500},
      },
    );

    final text =
        response.data['candidates'][0]['content']['parts'][0]['text'] as String;

    final cleanText = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final json = jsonDecode(cleanText);
    return MealAnalysisEntity.fromMap(json);
  }
}
