import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../config/app_config.dart';
import '../utils/app_log.dart';
import '../../features/ai_analysis/domain/entities/meal_analysis_entity.dart';

class GeminiService {
  GeminiService() {
    _dio.options.connectTimeout = const Duration(seconds: 45);
    _dio.options.receiveTimeout = const Duration(seconds: 90);
  }

  final Dio _dio = Dio();

  static const _models = [
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
  ];

  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

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

  Future<MealAnalysisEntity> analyzeMeal(File imageFile) async {
    final apiKey = AppConfig.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY tanımlı değil. .env veya --dart-define ile yapılandırın.',
      );
    }

    final jpegBytes = await _compressToJpeg(imageFile);
    final base64Image = base64Encode(jpegBytes);

    Exception? lastError;
    for (var i = 0; i < _models.length; i++) {
      try {
        final response = await _generateContent(
          model: _models[i],
          apiKey: apiKey,
          base64Image: base64Image,
        );
        return _parseMealResponse(response);
      } on Exception catch (e) {
        lastError = e;
        final retryable = _isRetryableWithAlternateModel(e);
        if (retryable && i < _models.length - 1) {
          appLog('Gemini: ${_models[i]} başarısız, yedek modele geçiliyor.');
          continue;
        }
        rethrow;
      }
    }
    throw lastError ?? Exception('Analiz başarısız. Tekrar deneyin.');
  }

  Future<Uint8List> _compressToJpeg(File imageFile) async {
    final compressed = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      minWidth: 1280,
      minHeight: 1280,
      quality: 75,
      format: CompressFormat.jpeg,
    );
    if (compressed != null && compressed.isNotEmpty) {
      return compressed;
    }
    return imageFile.readAsBytes();
  }

  Future<Response<dynamic>> _generateContent({
    required String model,
    required String apiKey,
    required String base64Image,
  }) async {
    final url = '$_baseUrl/$model:generateContent?key=$apiKey';
    final body = {
      'contents': [
        {
          'parts': [
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Image,
              },
            },
            {'text': _prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1,
        'maxOutputTokens': 1024,
        'responseMimeType': 'application/json',
        'responseSchema': {
          'type': 'object',
          'properties': {
            'food': {'type': 'string'},
            'calories': {'type': 'number'},
            'protein': {'type': 'number'},
            'carbs': {'type': 'number'},
            'fat': {'type': 'number'},
            'portion': {'type': 'string'},
          },
          'required': [
            'food',
            'calories',
            'protein',
            'carbs',
            'fat',
            'portion',
          ],
        },
      },
    };

    DioException? lastError;
    const maxAttempts = 4;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await _dio.post(url, data: body);
      } on DioException catch (e) {
        lastError = e;
        final status = e.response?.statusCode;
        if ((status == 429 || status == 503) && attempt < maxAttempts) {
          await Future<void>.delayed(Duration(seconds: attempt * 3));
          continue;
        }
        throw Exception(_friendlyDioMessage(e));
      }
    }

    throw Exception(_friendlyDioMessage(lastError!));
  }

  MealAnalysisEntity _parseMealResponse(Response<dynamic> response) {
    final candidates = response.data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception(
        'Gemini yanıt vermedi. Fotoğrafı net çekip tekrar deneyin.',
      );
    }

    final candidate = candidates[0] as Map<String, dynamic>;
    final finishReason = candidate['finishReason'] as String?;
    if (finishReason == 'SAFETY') {
      throw Exception(
        'Görsel analiz edilemedi. Farklı bir fotoğraf deneyin.',
      );
    }

    final text = _collectTextFromParts(candidate['content']?['parts']);
    if (text.isEmpty) {
      throw Exception(
        'Gemini boş yanıt döndü. Fotoğrafı net çekip tekrar deneyin.',
      );
    }

    final jsonString = _extractJsonObject(text);
    if (jsonString == null) {
      appLog('Gemini ham yanıt: $text');
      throw Exception(
        'Yanıt okunamadı. Tekrar deneyin veya daha net bir fotoğraf çekin.',
      );
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final food = json['food']?.toString().trim() ?? '';
      if (food.isEmpty) {
        throw Exception(
          'Yemek tanınamadı. Tabaktaki yemeği net gösteren bir fotoğraf çekin.',
        );
      }
      return MealAnalysisEntity.fromMap(json);
    } on FormatException catch (e) {
      appLog('JSON parse hatası: $e | metin: $jsonString');
      throw Exception(
        'Yanıt okunamadı. Tekrar deneyin.',
      );
    }
  }

  String _collectTextFromParts(dynamic parts) {
    if (parts is! List) return '';
    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is! Map) continue;
      final text = part['text'];
      if (text is String && text.trim().isNotEmpty) {
        buffer.writeln(text);
      }
    }
    return buffer.toString().trim();
  }

  String? _extractJsonObject(String text) {
    var clean = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final start = clean.indexOf('{');
    if (start == -1) return null;

    var depth = 0;
    for (var i = start; i < clean.length; i++) {
      final ch = clean[i];
      if (ch == '{') depth++;
      if (ch == '}') {
        depth--;
        if (depth == 0) {
          return clean.substring(start, i + 1);
        }
      }
    }
    return null;
  }

  bool _isRetryableWithAlternateModel(Exception e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('503') ||
        msg.contains('429') ||
        msg.contains('kotası') ||
        msg.contains('yüksek talep') ||
        msg.contains('high demand') ||
        msg.contains('quota') ||
        msg.contains('yanıt okunamadı') ||
        msg.contains('boş yanıt');
  }

  static String _friendlyDioMessage(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    String? apiMessage;
    if (body is Map && body['error'] is Map) {
      apiMessage = body['error']['message'] as String?;
    }

    switch (status) {
      case 404:
        return 'Seçilen Gemini modeli bulunamadı. Uygulamayı güncelleyip tekrar deneyin.';
      case 429:
        return apiMessage ??
            'API kotası doldu. Birkaç dakika bekleyip tekrar deneyin.';
      case 503:
        return apiMessage ??
            'Gemini şu an yoğun. Birkaç saniye bekleyip tekrar deneyin.';
      case 401:
      case 403:
        return 'API anahtarı geçersiz. .env dosyasındaki GEMINI_API_KEY değerini kontrol edin.';
      case 400:
        return apiMessage ??
            'Geçersiz istek. Farklı bir fotoğraf ile tekrar deneyin.';
      case 500:
        return apiMessage ??
            'Gemini geçici hata verdi. Kısa süre sonra tekrar deneyin.';
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return 'Bağlantı zaman aşımına uğradı. İnternetinizi kontrol edin.';
        }
        if (e.type == DioExceptionType.connectionError) {
          return 'İnternet bağlantısı yok.';
        }
        return apiMessage ?? 'Analiz sırasında bir hata oluştu.';
    }
  }
}
