import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/translation_provider.dart';

import 'translation_provider_test.mocks.dart';

@GenerateMocks([http.Client, DotEnv])
void main() {
  late TranslationProvider translationProvider;
  late MockClient mockHttpClient;
  late MockDotEnv mockDotEnv;

  setUp(() {
    mockHttpClient = MockClient();
    mockDotEnv = MockDotEnv();
    dotenv = mockDotEnv; // Inject mock dotenv
    translationProvider = TranslationProvider(httpClient: mockHttpClient);
  });

  group('TranslationProvider.translateText', () {
    const String apiKey = 'dummy-api-key';
    const String mockText = 'Hello';
    const String targetLanguage = 'es';
    const String translatedText = 'Hola';
    const String mockResponseBody = '''
      {
        "data": {
          "translations": [
            { "translatedText": "$translatedText" }
          ]
        }
      }
    ''';

    test('should return the original text if target language is "en"',
        () async {
      final result = await translationProvider.translateText('Hello', 'en');
      expect(result, 'Hello');
    });

    test('should return translated text on successful API call', () async {
      // Mock dotenv to return API key
      when(mockDotEnv.env).thenReturn({'TRANSLATE_API_KEY': apiKey});

      // Mock successful HTTP response
      when(mockHttpClient.post(
        Uri.parse(
            'https://translation.googleapis.com/language/translate/v2?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'q': mockText,
          'source': 'en',
          'target': targetLanguage,
          'format': 'text',
        }),
      )).thenAnswer((_) async => http.Response(mockResponseBody, 200));

      // Call the translateText method
      final result =
          await translationProvider.translateText(mockText, targetLanguage);

      // Verify HTTP call and response
      verify(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
      expect(result, translatedText);
    });

    test('should throw an exception on a failed API call', () async {
      // Mock dotenv to return API key
      when(mockDotEnv.env).thenReturn({'TRANSLATE_API_KEY': apiKey});

      // Mock failed HTTP response
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error', 400));

      // Expect the method to throw an exception
      expect(
        () async =>
            await translationProvider.translateText(mockText, targetLanguage),
        throwsA(isA<Exception>()),
      );

      // Verify HTTP call
      verify(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
    });

    test('should throw an exception if API key is not set', () async {
      // Mock dotenv to return an empty API key
      when(mockDotEnv.env).thenReturn({'TRANSLATE_API_KEY': ''});

      // Expect the method to throw an exception
      expect(
        () async =>
            await translationProvider.translateText(mockText, targetLanguage),
        throwsA(isA<Exception>()),
      );

      // Verify that no HTTP call is made
      verifyNever(mockHttpClient.post(any,
          headers: anyNamed('headers'), body: anyNamed('body')));
    });
  });
}
