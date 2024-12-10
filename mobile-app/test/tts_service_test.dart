import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pbl5_menu/tts_service.dart';

import 'tts_service_test.mocks.dart';

@GenerateMocks([FlutterTts])
void main() {
  late MockFlutterTts mockFlutterTts;
  late TtsService ttsService;

  setUp(() {
    mockFlutterTts = MockFlutterTts();
    ttsService = TtsService();
    ttsService.flutterTts = mockFlutterTts;

    when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => null);
    when(mockFlutterTts.setSpeechRate(any)).thenAnswer((_) async => null);
    when(mockFlutterTts.setVolume(any)).thenAnswer((_) async => null);
    when(mockFlutterTts.setPitch(any)).thenAnswer((_) async => null);
    when(mockFlutterTts.getLanguages).thenAnswer((_) async => ["en-US"]);
    when(mockFlutterTts.isLanguageAvailable(any)).thenAnswer((_) async => true);
    when(mockFlutterTts.getEngines).thenAnswer((_) async => ["engine1"]);

    ttsService.initializeTts();
  });

  test('should initialize TTS handlers', () {
    verify(mockFlutterTts.setStartHandler(any)).called(1);
    verify(mockFlutterTts.setCompletionHandler(any)).called(1);
    verify(mockFlutterTts.setErrorHandler(any)).called(1);
  });

  test('should set TTS language and properties', () async {
    mockFlutterTts = MockFlutterTts();
    ttsService = TtsService();
    ttsService.flutterTts = mockFlutterTts;

    when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => null);
    when(mockFlutterTts.setSpeechRate(any)).thenAnswer((_) async => null);
    when(mockFlutterTts.setVolume(any)).thenAnswer((_) async => null);
    when(mockFlutterTts.setPitch(any)).thenAnswer((_) async => null);

    await ttsService.setTtsLanguage();

    verify(mockFlutterTts.setLanguage("en-US")).called(1);
    verify(mockFlutterTts.setSpeechRate(1)).called(1);
    verify(mockFlutterTts.setVolume(1.0)).called(1);
    verify(mockFlutterTts.setPitch(1.0)).called(1);
  });

  test('should check TTS availability', () async {
    mockFlutterTts = MockFlutterTts();
    ttsService = TtsService();
    ttsService.flutterTts = mockFlutterTts;

    when(mockFlutterTts.getLanguages).thenAnswer((_) async => ["en-US"]);
    when(mockFlutterTts.isLanguageAvailable(any)).thenAnswer((_) async => true);
    when(mockFlutterTts.getEngines).thenAnswer((_) async => ["engine1"]);

    await ttsService.checkTtsAvailability();

    verify(mockFlutterTts.getLanguages).called(1);
    verify(mockFlutterTts.isLanguageAvailable("en-US")).called(1);
    verify(mockFlutterTts.getEngines).called(1);
  });

  test('should speak labels', () async {
    mockFlutterTts = MockFlutterTts();
    ttsService = TtsService();
    ttsService.flutterTts = mockFlutterTts;

    // Stub only the methods used in speakLabels
    when(mockFlutterTts.speak(any)).thenAnswer((_) async => null);
    when(mockFlutterTts.awaitSpeakCompletion(any))
        .thenAnswer((_) async => null);

    // Test the speakLabels method
    List<dynamic> labels = ["Label1", "Label2"];
    await ttsService.speakLabels(labels);

    // Verify each label is spoken and await completion is called
    verify(mockFlutterTts.speak("Label1")).called(1);
    verify(mockFlutterTts.speak("Label2")).called(1);
    verify(mockFlutterTts.awaitSpeakCompletion(true)).called(2);

    // Ensure no extraneous calls
    verifyNoMoreInteractions(mockFlutterTts);
  });
}
