import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pbl5_menu/services/tts/tts_service.dart';
import 'package:pbl5_menu/shared/database_helper.dart';

import 'tts_service_test.mocks.dart';

@GenerateMocks([FlutterTts, DatabaseHelper])
void main() {
  late MockFlutterTts mockFlutterTts;
  late MockDatabaseHelper mockDatabaseHelper;
  late TtsService ttsService;

  setUp(() {
    mockFlutterTts = MockFlutterTts();
    mockDatabaseHelper = MockDatabaseHelper();
    ttsService = TtsService(mockDatabaseHelper);
    ttsService.flutterTts = mockFlutterTts;

    when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => null);
    when(mockFlutterTts.setSpeechRate(any)).thenAnswer((_) async => null);
    when(mockFlutterTts.setVolume(any)).thenAnswer((_) async => null);
    when(mockFlutterTts.setPitch(any)).thenAnswer((_) async => null);
    when(mockFlutterTts.getLanguages).thenAnswer((_) async => ["en-US"]);
    when(mockFlutterTts.isLanguageAvailable(any)).thenAnswer((_) async => true);
    when(mockFlutterTts.getEngines).thenAnswer((_) async => ["engine1"]);
    when(mockDatabaseHelper.getTtsSettings()).thenAnswer((_) async => {
          'languageCode': 'en-US',
          'speechRate': '1.0', // Return as String
          'pitch': '1.0', // Return as String
          'volume': '1.0', // Return as String
        });
  });

  test('should initialize TTS handlers', () async {
    await ttsService.initialize();
    ttsService.initializeTts();

    verify(mockFlutterTts.setStartHandler(any)).called(1);
    verify(mockFlutterTts.setCompletionHandler(any)).called(1);
    verify(mockFlutterTts.setErrorHandler(any)).called(1);
  });

  test('should set TTS language and properties', () async {
    await ttsService.setTtsLanguage();

    verify(mockFlutterTts.setLanguage("en-US")).called(1);
    verify(mockFlutterTts.setSpeechRate(1.0)).called(1);
    verify(mockFlutterTts.setVolume(1.0)).called(1);
    verify(mockFlutterTts.setPitch(1.0)).called(1);
  });

  test('should check TTS availability', () async {
    when(mockFlutterTts.isLanguageAvailable(any)).thenAnswer((_) async => true);
    when(mockFlutterTts.getEngines).thenAnswer((_) async => ["engine1"]);

    await ttsService.checkTtsAvailability();

    verify(mockFlutterTts.getLanguages).called(1);
    verify(mockFlutterTts.isLanguageAvailable("en-US")).called(1);
    verify(mockFlutterTts.getEngines).called(1);
  });

  test('should speak labels', () async {
    when(mockFlutterTts.speak(any)).thenAnswer((_) async => null);
    when(mockFlutterTts.awaitSpeakCompletion(any))
        .thenAnswer((_) async => null);

    List<dynamic> labels = ["Label1", "Label2"];
    await ttsService.speakLabels(labels);

    verify(mockFlutterTts.speak("Label1")).called(1);
    verify(mockFlutterTts.speak("Label2")).called(1);
    verify(mockFlutterTts.awaitSpeakCompletion(true)).called(2);
  });

  test('should load default settings when database returns null values',
      () async {
    // Mock the database to return null for settings
    when(mockDatabaseHelper.getTtsSettings()).thenAnswer((_) async => {
          'languageCode': '',
          'speechRate': '',
          'pitch': '',
          'volume': '',
        });

    await ttsService.initialize();

    // Verify default values
    expect(ttsService.languageCode, 'en-US');
    expect(ttsService.speechRate, 1.0);
    expect(ttsService.pitch, 1.0);
    expect(ttsService.volume, 1.0);
  });

  test('should update speech rate and call the method', () async {
    double newRate = 1.5;

    await ttsService.updateSpeechRate(newRate);

    verify(mockFlutterTts.setSpeechRate(newRate)).called(1);
    verify(mockDatabaseHelper.updateTtsSettings('speechRate', '1.5')).called(1);
  });

  test('should update language and voice name, and update the database',
      () async {
    String newLanguage = 'es-ES';
    String newVoice = 'esVoice';

    await ttsService.updateLanguage(newLanguage, newVoice);

    verify(mockDatabaseHelper.updateTtsSettings('languageCode', newLanguage))
        .called(1);
    verify(mockDatabaseHelper.updateTtsSettings('voiceName', newVoice))
        .called(1);
    verify(mockFlutterTts.setLanguage(newLanguage)).called(1);
  });

  test('should handle TTS error correctly', () async {
    // Simulate an error in the TTS service
    when(mockFlutterTts.speak(any)).thenThrow(Exception('TTS error'));

    try {
      await ttsService.speakLabels(["ErrorTest"]);
    } catch (e) {
      expect(e.toString(), contains("TTS error"));
    }
  });

  // test(
  //     'should update language and voice correctly when language is unavailable',
  //     () async {
  //   // Mock an unavailable language
  //   when(mockFlutterTts.isLanguageAvailable(any))
  //       .thenAnswer((_) async => false);

  //   String unavailableLanguage = 'fr-FR';
  //   String newVoice = 'frVoice';

  //   // Call updateLanguage with an unavailable language
  //   await ttsService.updateLanguage(unavailableLanguage, newVoice);

  //   // Verify that isLanguageAvailable was called with the unavailable language
  //   verify(mockFlutterTts.isLanguageAvailable(unavailableLanguage)).called(1);

  //   // Verify that setLanguage was **not** called since the language is unavailable
  //   verify(mockFlutterTts.setLanguage(unavailableLanguage))
  //       .called(0); // Should not be called
  // });
}
