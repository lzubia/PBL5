import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/shared/database_helper.dart';

import 'tts_service_google_test.mocks.dart';

@GenerateMocks([DatabaseHelper, AudioPlayer, http.Client, File])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TtsServiceGoogle ttsService;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockAudioPlayer mockAudioPlayer;
  late MockClient mockHttpClient;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockAudioPlayer = MockAudioPlayer();
    mockHttpClient = MockClient();

    // Mock the database helper for TTS settings
    when(mockDatabaseHelper.getTtsSettings()).thenAnswer(
      (_) async => {'languageCode': 'en-US', 'voiceName': 'en-US-Wavenet-D'},
    );

    // Inject the mock AudioPlayer
    ttsService = TtsServiceGoogle(
      mockDatabaseHelper,
      audioPlayer: mockAudioPlayer, // Inject mocked AudioPlayer
    );
  });

  group('TtsServiceGoogle Tests', () {
    test('initializeTts prints initialization message', () async {
      await ttsService.initializeTts();
      // No exception should occur, just ensure the print statement executes
      expect(true, isTrue);
    });

    test('loadSettings loads language and voice settings from DatabaseHelper',
        () async {
      when(mockDatabaseHelper.getTtsSettings()).thenAnswer(
        (_) async => {'languageCode': 'es-ES', 'voiceName': 'es-ES-Wavenet-B'},
      );

      await ttsService.loadSettings();

      expect(ttsService.languageCode, 'es-ES');
      expect(ttsService.voiceName, 'es-ES-Wavenet-B');
      verify(mockDatabaseHelper.getTtsSettings()).called(2);
    });

    test('updateLanguage updates language and voice name', () async {
      ttsService.updateLanguage('fr-FR', 'fr-FR-Wavenet-C');

      expect(ttsService.languageCode, 'fr-FR');
      expect(ttsService.voiceName, 'fr-FR-Wavenet-C');
    });

    test('updateSpeechRate updates speech rate', () async {
      ttsService.updateSpeechRate(1.0);

      expect(ttsService.speechRate, 1.0);
    });

    //   test('speakLabels synthesizes speech and plays audio', () async {
    //     const mockToken = 'mock_access_token';
    //     final audioContent = base64Encode([0, 1, 2, 3]);
    //     final mockTtsResponse = '''
    // {
    //   "audioContent": "$audioContent"
    // }
    // ''';

    //     // Mock private methods
    //     when(ttsService.getAccessToken()).thenAnswer((_) async => mockToken);

    //     // Mock TTS API response
    //     when(mockHttpClient.post(any,
    //             headers: anyNamed('headers'), body: anyNamed('body')))
    //         .thenAnswer((_) async => http.Response(mockTtsResponse, 200));

    //     // Mock temporary directory and file creation
    //     final mockTempDir = Directory.systemTemp;
    //     final mockFile = MockFile();
    //     when(getTemporaryDirectory()).thenAnswer((_) async => mockTempDir);
    //     when(mockFile.writeAsBytes(captureAny))
    //         .thenAnswer((_) async => Future.value(mockFile));

    //     // Perform the TTS speakLabels call
    //     await ttsService.speakLabels(['Hello', 'World']);

    //     // Verify TTS API was called
    //     verify(mockHttpClient.post(any,
    //             headers: anyNamed('headers'), body: anyNamed('body')))
    //         .called(2); // Once for each label

    //     // Verify the audio player was used
    //     verify(mockAudioPlayer.play(any)).called(2); // Once for each label
    //   });

    //   test('getAccessToken fetches and returns an access token', () async {
    //     const mockServiceAccount = '''
    // {
    //   "type": "service_account",
    //   "project_id": "mock_project",
    //   "private_key_id": "mock_key_id",
    //   "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBALsdjKDUEA1vY9Us\\nBAQEFAASCAmIwggJeAgEAAoGBALsdjKDUEA1vY9UsBQXg5AO/8tRUEDNKj92HQo\\nRmKi2UEUd3cTwBzOA0bhKmY4rAen5kS+N5d\\n-----END PRIVATE KEY-----\\n",
    //   "client_email": "mock_email",
    //   "client_id": "mock_client_id",
    //   "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    //   "token_uri": "https://oauth2.googleapis.com/token",
    //   "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    //   "client_x509_cert_url": "mock_cert_url"
    // }
    // ''';

    //     const mockAccessTokenResponse = '''
    // {
    //   "access_token": "mock_access_token",
    //   "expires_in": 3600,
    //   "token_type": "Bearer"
    // }
    // ''';

    //     // Mock rootBundle to load the service account JSON
    //     TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    //         .setMockMessageHandler('flutter/assets', (message) async {
    //       final assetKey = utf8.decode(message!.buffer.asUint8List());
    //       if (assetKey == 'assets/tts-english.json') {
    //         return ByteData.view(
    //             Uint8List.fromList(utf8.encode(mockServiceAccount)).buffer);
    //       }
    //       return null;
    //     });

    //     // Mock the HTTP client for token API
    //     when(mockHttpClient.post(any,
    //             headers: anyNamed('headers'), body: anyNamed('body')))
    //         .thenAnswer((_) async => http.Response(mockAccessTokenResponse, 200));

    //     final accessToken = await ttsService.getAccessToken();

    //     expect(accessToken, 'mock_access_token');
    //     verify(mockHttpClient.post(any,
    //             headers: anyNamed('headers'), body: anyNamed('body')))
    //         .called(1);
    //   });

    //   test('getAccessToken fetches and returns an access token', () async {
    //     const mockServiceAccount = '''
    // {
    //   "type": "service_account",
    //   "project_id": "mock_project",
    //   "private_key_id": "mock_key_id",
    //   "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBALsdjKDUEA1vY9UsBQXg5AO/8tRUEDNKj92HQoRmKi2UEUd3cTwBzOA0bhKmY4rAen5kS+N5\\n-----END PRIVATE KEY-----\\n",
    //   "client_email": "mock_email",
    //   "client_id": "mock_client_id",
    //   "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    //   "token_uri": "https://oauth2.googleapis.com/token",
    //   "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    //   "client_x509_cert_url": "mock_cert_url"
    // }
    // ''';

    //     const mockAccessTokenResponse = '''
    // {
    //   "access_token": "mock_access_token",
    //   "expires_in": 3600,
    //   "token_type": "Bearer"
    // }
    // ''';

    //     // Mock rootBundle to load the service account JSON
    //     TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    //         .setMockMessageHandler('flutter/assets', (message) async {
    //       final assetKey = utf8.decode(message!.buffer.asUint8List());
    //       if (assetKey == 'assets/tts-english.json') {
    //         return ByteData.view(
    //             Uint8List.fromList(utf8.encode(mockServiceAccount)).buffer);
    //       }
    //       return null;
    //     });

    //     // Mock the HTTP client for token API
    //     when(mockHttpClient.post(any,
    //             headers: anyNamed('headers'), body: anyNamed('body')))
    //         .thenAnswer((_) async => http.Response(mockAccessTokenResponse, 200));

    //     final accessToken = await ttsService.getAccessToken();

    //     expect(accessToken, 'mock_access_token');
    //     verify(mockHttpClient.post(any,
    //             headers: anyNamed('headers'), body: anyNamed('body')))
    //         .called(1);
    //   });

    //   test('speakLabels handles API error gracefully', () async {
    //     const mockToken = 'mock_access_token';
    //     const mockErrorResponse = '''
    //     {
    //       "error": {
    //         "code": 400,
    //         "message": "Invalid request",
    //         "status": "INVALID_ARGUMENT"
    //       }
    //     }
    //     ''';

    //     // Mock private methods
    //     when(ttsService.getAccessToken()).thenAnswer((_) async => mockToken);

    //     // Mock TTS API response with error
    //     when(mockHttpClient.post(any,
    //             headers: anyNamed('headers'), body: anyNamed('body')))
    //         .thenAnswer((_) async => http.Response(mockErrorResponse, 400));

    //     // Perform the TTS speakLabels call
    //     await ttsService.speakLabels(['Hello']);

    //     // Verify TTS API was called
    //     verify(mockHttpClient.post(any,
    //             headers: anyNamed('headers'), body: anyNamed('body')))
    //         .called(1);

    //     // Verify audio player is not used since API failed
    //     verifyNever(mockAudioPlayer.play(any));
    //   });

    //   test('speakLabels handles exceptions gracefully', () async {
    //     // Mock an exception during the TTS API call
    //     when(ttsService.getAccessToken()).thenThrow(Exception('Token error'));

    //     // Perform the TTS speakLabels call
    //     await ttsService.speakLabels(['Hello']);

    //     // Verify that no audio playback occurs due to the exception
    //     verifyNever(mockAudioPlayer.play(any));
    //   });
  });
}
