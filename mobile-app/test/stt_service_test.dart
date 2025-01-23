import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pbl5_menu/services/stt/i_stt_service.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';

import 'stt_service_test.mocks.dart';

@GenerateMocks([stt.SpeechToText])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SttService sttService;
  late MockSpeechToText mockSpeechToText;

  setUp(() {
    mockSpeechToText = MockSpeechToText();
    sttService =
        SttService(speech: mockSpeechToText); // Inject the mock instance
  });

  group('SttService Tests', () {
    // test('initializeStt initializes SpeechToText successfully', () async {
    //   when(mockSpeechToText.initialize(onStatus: anyNamed('onStatus')))
    //       .thenAnswer((_) async => true);

    //   await sttService.initializeStt();

    //   verify(mockSpeechToText.initialize(onStatus: anyNamed('onStatus')))
    //       .called(1);
    // });

    // test('initializeStt prints error if initialization fails', () async {
    //   when(mockSpeechToText.initialize(onStatus: anyNamed('onStatus')))
    //       .thenAnswer((_) async => false);

    //   await sttService.initializeStt();

    //   verify(mockSpeechToText.initialize(onStatus: anyNamed('onStatus')))
    //       .called(1);
    // });

    test('startListening starts listening and triggers onResult callback',
        () async {
      final mockResult = SpeechRecognitionResult(
        [SpeechRecognitionWords('hello world', 1.0)],
        true,
      );
      bool callbackCalled = false;

      when(mockSpeechToText.listen(onResult: anyNamed('onResult')))
          .thenAnswer((invocation) async {
        // Simulate the result callback being invoked
        final onResultCallback =
            invocation.namedArguments[const Symbol('onResult')];
        if (onResultCallback != null) {
          onResultCallback(mockResult);
        }
        return Future.value();
      });

      await sttService.startListening((result) {
        callbackCalled = true;
        expect(result, 'hello world'); // Ensure recognized words are passed
      });

      expect(sttService.isListening, isTrue); // Verify listening state
      verify(mockSpeechToText.listen(onResult: anyNamed('onResult'))).called(1);
      expect(callbackCalled, isTrue); // Ensure callback was called
    });

    test('startListening does nothing if already listening', () async {
      sttService.isListening = true;

      await sttService.startListening((_) {});

      verifyNever(mockSpeechToText.listen(onResult: anyNamed('onResult')));
    });

    test('stopListening stops listening if currently listening', () {
      sttService.isListening = true;

      sttService.stopListening();

      expect(sttService.isListening, isFalse);
      verify(mockSpeechToText.stop()).called(1);
    });

    test('stopListening does nothing if not listening', () {
      sttService.isListening = false;

      sttService.stopListening();

      verifyNever(mockSpeechToText.stop());
    });

    // test('restartListening stops current listening and starts again', () async {
    //   sttService.isListening = true; // Set initial listening state
    //   bool callbackCalled = false;

    //   // Mock the stop method
    //   when(mockSpeechToText.stop()).thenAnswer((_) async => Future.value());

    //   // Mock the startListening method
    //   when(mockSpeechToText.listen(onResult: anyNamed('onResult')))
    //       .thenAnswer((_) async => Future.value());

    //   // Start listening
    //   await sttService.startListening((result) {
    //     callbackCalled = true;
    //   });

    //   // Restart listening
    //   sttService.restartListening();

    //   // Verify the stop and listen methods were called
    //   verify(mockSpeechToText.stop()).called(1); // Verify stop was called
    //   verify(mockSpeechToText.listen(onResult: anyNamed('onResult')))
    //       .called(1); // Verify restart
    //   expect(callbackCalled, isFalse); // Ensure no premature callback
    // });

    test('restartListening starts listening if not currently listening',
        () async {
      sttService.isListening = false;
      bool callbackCalled = false;

      // Mock the startListening method
      when(mockSpeechToText.listen(onResult: anyNamed('onResult')))
          .thenAnswer((_) async => Future.value());

      await sttService.startListening((result) {
        callbackCalled = true;
      });

      sttService.restartListening();

      await Future.delayed(Duration(milliseconds: 200)); // Wait for delay

      verify(mockSpeechToText.listen(onResult: anyNamed('onResult')))
          .called(2); // Verify restart
      expect(callbackCalled, isFalse); // Ensure no premature callback
    });

    // test('handles status changes and restarts listening if needed', () async {
    //   sttService.isListening = true;

    //   // Mock the restartListening method
    //   when(mockSpeechToText.stop()).thenAnswer((_) async => Future.value());
    //   when(mockSpeechToText.listen(onResult: anyNamed('onResult')))
    //       .thenAnswer((_) async => Future.value());

    //   // Simulate status change to 'done'
    //   sttService.handleStatus('done');

    //   await Future.delayed(Duration(milliseconds: 200)); // Wait for delay

    //   verify(mockSpeechToText.stop()).called(1); // Verify stop
    //   verify(mockSpeechToText.listen(onResult: anyNamed('onResult')))
    //       .called(1); // Verify restart
    // });

    test(
        'does not restart listening if status changes but not "done" or "notListening"',
        () async {
      sttService.isListening = true;

      // Mock the restartListening method
      when(mockSpeechToText.stop()).thenAnswer((_) async => Future.value());
      when(mockSpeechToText.listen(onResult: anyNamed('onResult')))
          .thenAnswer((_) async => Future.value());

      // Simulate status change to 'listening'
      sttService.handleStatus('listening');

      await Future.delayed(Duration(milliseconds: 200)); // Wait for delay

      verifyNever(mockSpeechToText.stop()); // Stop should not be called
      verifyNever(mockSpeechToText.listen(onResult: anyNamed('onResult')));
    });
  });
}
