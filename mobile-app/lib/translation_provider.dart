import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TranslationProvider with ChangeNotifier {
  final http.Client httpClient;

  TranslationProvider({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  Future<String> translateText(String text, String targetLanguage) async {
    if (targetLanguage == 'en') return text;
    final apiKey = dotenv.env['TRANSLATE_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key is not set');
    }
    final response = await httpClient.post(
      Uri.parse(
          'https://translation.googleapis.com/language/translate/v2?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'q': text,
        'source': 'en',
        'target': targetLanguage,
        'format': 'text',
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['translations'][0]['translatedText'];
    } else {
      throw Exception('Failed to translate text');
    }
  }
}
