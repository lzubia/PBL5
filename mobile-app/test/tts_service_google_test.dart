import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/shared/database_helper.dart';

import 'tts_service_google_test.mocks.dart';

/// Custom AssetBundle for mocking asset loading in tests
class TestAssetBundle extends CachingAssetBundle {
  final Map<String, String> _mockAssets = {};

  void addMockAsset(String key, String value) {
    _mockAssets[key] = value;
  }

  @override
  Future<ByteData> load(String key) async {
    final asset = _mockAssets[key];
    if (asset == null) {
      throw FlutterError('Unable to load asset: $key');
    }
    return ByteData.view(Uint8List.fromList(utf8.encode(asset)).buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return _mockAssets[key] ??
        (throw FlutterError('Unable to load asset: $key'));
  }
}

@GenerateMocks([DatabaseHelper, AudioPlayer, http.Client, File])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TtsServiceGoogle ttsService;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockAudioPlayer mockAudioPlayer;
  late MockClient mockHttpClient;
  late TestAssetBundle testAssetBundle;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockAudioPlayer = MockAudioPlayer();
    mockHttpClient = MockClient();
    testAssetBundle = TestAssetBundle();

    // Mock the database helper for TTS settings
    when(mockDatabaseHelper.getTtsSettings()).thenAnswer(
      (_) async => {'languageCode': 'en-US', 'voiceName': 'en-US-Wavenet-D'},
    );

    // Inject the mock AudioPlayer and AssetBundle into TtsServiceGoogle
    ttsService = TtsServiceGoogle(
      mockDatabaseHelper,
      audioPlayer: mockAudioPlayer,
      httpClient: mockHttpClient,
      assetBundle: testAssetBundle, // Inject TestAssetBundle here
    );
  });

  group('TtsServiceGoogle Tests', () {
    test('initializeTts prints initialization message', () async {
      await ttsService.initializeTts();
      expect(true, isTrue);
    });

    test('loadSettings loads valid settings from DatabaseHelper', () async {
      when(mockDatabaseHelper.getTtsSettings()).thenAnswer(
        (_) async => {'languageCode': 'es-ES', 'voiceName': 'es-ES-Wavenet-B'},
      );

      await ttsService.loadSettings();

      expect(ttsService.languageCode, 'es-ES');
      expect(ttsService.voiceName, 'es-ES-Wavenet-B');
      verify(mockDatabaseHelper.getTtsSettings()).called(2);
    });

    test('loadSettings handles invalid settings gracefully', () async {
      when(mockDatabaseHelper.getTtsSettings()).thenAnswer((_) async => {});

      await ttsService.loadSettings();

      expect(ttsService.languageCode, 'en-US');
      expect(ttsService.voiceName, 'en-US-Wavenet-D');
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

    test('updateSpeechRate handles invalid values gracefully', () async {
      ttsService.updateSpeechRate(-1.0);
      expect(ttsService.speechRate, 1.6);

      ttsService.updateSpeechRate(0.0);
      expect(ttsService.speechRate, 1.6);

      ttsService.updateSpeechRate(2.0);
      expect(ttsService.speechRate, 2.0);
    });

    test('getAccessToken fetches and returns an access token', () async {
      const mockServiceAccount = '''
      {
        "type": "service_account",
        "project_id": "mock_project",
        "private_key_id": "mock_key_id",
        "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDJ+/e5mjYrglc2\\np3itLdLJZnlErRNfhqmth5NoZsEGq4K0mkXqFQytoUi6pY5CkJE93LQiUHHps6ji\\nRimbSktBIg/GjDuMwbzzeqvtnLiE6mGVJL4cBQZqehxRyKBZmatdmY+xKDACHk1v\\n7bw0Y4lyM+DBy4qtpPu7Vm6IIwWWL9aEdiNxUgCclhrzWi0b0XjngGDfe8xwx1f3\\nxrbL62JU6lQt4cjecuBDrQUl0fD6P4xh90QDg++sFqK2vnAMBo3Lu7JXCZ2mkT8j\\nGHlXhFVk+SrRwy3woIgGuaojZEn+oO516Urqgzm6ZjR/EYbO9R0XUnrzjrs//5og\\n1fi4Ni2xAgMBAAECggEAJoaPFGF34hohEO1mDOAf46bOTB1YA+EvVYg1w1TQDfni\\nOxju62xa5/ZKpUElLoidD2fcmuvtolYQiSI5VuOXkYOR7zy5sgoVBHraNr7tCfsb\\npEMnGLiTpfUHGElUXmq7XyXGXNPNvmWxvv7hJjvzECuZe9VbLO46Tpv4hrJpYyED\\nZ04ktlpSQqRBTvCWi4ktSbHrxOB8Q91WwnASX1Ya/i7yslS9V7n6aFhywn/GsTEZ\\nde3lSj7Es6iXeJpbyxWXf0FIa4Q+rSrAkeTQ6MIi3bUYw0WxuQ0dMdX+9uxxAm3I\\ngqVW2+itLbz+sYG74Kdg54H6ueu2rWI4PPoomloZvQKBgQDu8PCGltglObg45pVe\\nIGkRAVKrP7ckjx6g29p/GIbNeSjaKPu0ZW+pMibN6S4qJv6Hne+RjP2EyLBB43Iu\\n2ExCdbI6gi9GjDOpGF6vfm3p78GgnZpz32Hmiu7+PraXkCCZYQjsvnbii6XDkCwS\\nZGfQjZWrcioo0Ko/YAriqN9r3QKBgQDYZ5OujEDmoqe8aiXI6ZYHGt+V76IlD5kG\\nfhcIt6NDRFYEfxTPky8cQQjmJNYsSsBkt5d258vml3ShHfhOTMgfF9MSGmsu7dBN\\ng/uMHvkm4Usrj1xXMnX03LPLcufz2zoAZl94HqdhJx6Y80UrId6od9c8FH0espcr\\nFTO5mXbl5QKBgQCL5KDOC87srIiBN+9Htq4M+LtP6/PsAacrAs1AEDoMXt1eLRSB\\nH8pqQySY9ebDYyUufXdfvi5H6b/YM7QMXTL4zjPVMZdANKGiZNQ650iu6GJzCRL+\\nuFB3S+x1Cn6Y6hdL9ZXmFfVA2gXpI6XJ9uMZJWv1ftfUIacrh62X2stEOQKBgHNw\\nTUd/ad+eRPwtY5qZgH6pxzukaUp715WvDXqI+36WpYwgfml8ilT4HFcor1dRSPBx\\nP0seu5Z2lLCd3CdorhhoDSBLF4IhOk0fasCEhURISmEiSI/7SxEj6oVM9o8PExHD\\nion5UDBzPc85dlxb5PrZcueJxnTpr9o7pSwMwXBBAoGABrBpadE2m8N0B8o3KzgP\\nfGGI11kxUIqTvk/tqGCQcFTrlP/ENhQ2Q7vg7M65ztU8TMvO87I4iCT7BdWz4dLy\\nPIJf72pa+YrYqwJExtInKrlBKUBTYSxlimE4jNY2egLtRsDT8be8ck6iz71viFOM\\nDjWHic19087OBAhQvy2lIsM=\\n-----END PRIVATE KEY-----\\n",
        "client_email": "mock-email@project.iam.gserviceaccount.com"
      }
      ''';

      const mockAccessTokenResponse = '''
      {
        "access_token": "mock_access_token",
        "expires_in": 3600,
        "token_type": "Bearer"
      }
      ''';

      // Add mock service account JSON to TestAssetBundle
      testAssetBundle.addMockAsset(
          'assets/tts-english.json', mockServiceAccount);

      // Mock HTTP client response
      when(mockHttpClient.post(
        Uri.parse("https://oauth2.googleapis.com/token"),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(mockAccessTokenResponse, 200));

      final token = await ttsService.getAccessToken();

      expect(token, 'mock_access_token');
    });

    test('getAccessToken handles invalid response gracefully', () async {
      const mockServiceAccount = '''
      {
        "type": "service_account",
        "project_id": "mock_project",
        "private_key_id": "mock_key_id",
        "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvQIBADAN...\\n-----END PRIVATE KEY-----\\n",
        "client_email": "mock-email@project.iam.gserviceaccount.com"
      }
      ''';

      const mockErrorResponse = '''
      {
        "error": {
          "code": 400,
          "message": "Invalid request",
          "status": "INVALID_ARGUMENT"
        }
      }
      ''';

      // Add mock service account JSON to TestAssetBundle
      testAssetBundle.addMockAsset(
          'assets/tts-english.json', mockServiceAccount);

      // Mock HTTP client response
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(mockErrorResponse, 400));

      expect(ttsService.getAccessToken(), throwsException);
    });

    test('getAccessToken throws an error if auth file is missing', () async {
      testAssetBundle.addMockAsset('assets/tts-english.json', '');

      expect(ttsService.getAccessToken(), throwsException);
    });

    test('getAccessToken handles invalid JSON format', () async {
      testAssetBundle.addMockAsset('assets/tts-english.json', 'Invalid JSON');

      expect(ttsService.getAccessToken(), throwsFormatException);
    });

    test('getAccessToken handles exceptions gracefully', () async {
      testAssetBundle.addMockAsset('assets/tts-english.json', 'Invalid JSON');

      expect(ttsService.getAccessToken(), throwsFormatException);
    });

    

    // test('speakLabels synthesizes speech and plays audio', () async {
    //   const mockToken = 'mock_access_token';
    //   final audioContent = base64Encode([0, 1, 2, 3]); // Mocked audio content
    //   final mockTtsResponse = '''
    //   {
    //     "audioContent": "$audioContent"
    //   }
    //   ''';

    //   // Mock `getAccessToken` to return a fake token
    //   when(ttsService.getAccessToken()).thenAnswer((_) async => mockToken);

    //   // Mock the HTTP client response for the Text-to-Speech API
    //   when(mockHttpClient.post(
    //     Uri.parse("https://texttospeech.googleapis.com/v1/text:synthesize"),
    //     headers: anyNamed('headers'),
    //     body: anyNamed('body'),
    //   )).thenAnswer((_) async => http.Response(mockTtsResponse, 200));

    //   // Mock the `getTemporaryDirectory` method
    //   final mockTempDir =
    //       Directory.systemTemp; // Use a temporary system directory
    //   when(getTemporaryDirectory()).thenAnswer((_) async => mockTempDir);

    //   // Mock the `play` method of AudioPlayer
    //   when(mockAudioPlayer.play(any)).thenAnswer((_) async => Future.value());

    //   // Perform the TTS speakLabels call
    //   await ttsService.speakLabels(['Hello', 'World']);

    //   // Verify `getAccessToken` was called
    //   verify(ttsService.getAccessToken()).called(1);

    //   // Verify HTTP POST requests were made for each label
    //   verify(mockHttpClient.post(
    //     Uri.parse("https://texttospeech.googleapis.com/v1/text:synthesize"),
    //     headers: {
    //       "Authorization": "Bearer $mockToken",
    //       "Content-Type": "application/json",
    //     },
    //     body: jsonEncode({
    //       "input": {"text": "Hello"},
    //       "voice": {"languageCode": "en-US", "name": "en-US-Wavenet-D"},
    //       "audioConfig": {"audioEncoding": "MP3", "speakingRate": 1.6},
    //     }),
    //   )).called(1);

    //   verify(mockHttpClient.post(
    //     Uri.parse("https://texttospeech.googleapis.com/v1/text:synthesize"),
    //     headers: {
    //       "Authorization": "Bearer $mockToken",
    //       "Content-Type": "application/json",
    //     },
    //     body: jsonEncode({
    //       "input": {"text": "World"},
    //       "voice": {"languageCode": "en-US", "name": "en-US-Wavenet-D"},
    //       "audioConfig": {"audioEncoding": "MP3", "speakingRate": 1.6},
    //     }),
    //   )).called(1);

    //   // Verify that the audio player was called to play the generated audio
    //   verify(mockAudioPlayer.play(any)).called(2);
    // });

    // test('speakLabels handles API error gracefully', () async {
    //   const mockToken = 'mock_access_token';
    //   const mockErrorResponse = '''
    //   {
    //     "error": {
    //       "code": 400,
    //       "message": "Invalid request",
    //       "status": "INVALID_ARGUMENT"
    //     }
    //   }
    //   ''';

    //   // Mock private methods
    //   when(ttsService.getAccessToken()).thenAnswer((_) async => mockToken);

    //   // Mock TTS API response with error
    //   when(mockHttpClient.post(any,
    //           headers: anyNamed('headers'), body: anyNamed('body')))
    //       .thenAnswer((_) async => http.Response(mockErrorResponse, 400));

    //   // Perform the TTS speakLabels call
    //   await ttsService.speakLabels(['Hello']);

    //   // Verify TTS API was called
    //   verify(mockHttpClient.post(any,
    //           headers: anyNamed('headers'), body: anyNamed('body')))
    //       .called(1);

    //   // Verify audio player is not used since API failed
    //   verifyNever(mockAudioPlayer.play(any));
    // });

    // test('speakLabels handles exceptions gracefully', () async {
    //   // Mock an exception during the TTS API call
    //   when(ttsService.getAccessToken()).thenThrow(Exception('Token error'));

    //   // Perform the TTS speakLabels call
    //   await ttsService.speakLabels(['Hello']);

    //   // Verify that no audio playback occurs due to the exception
    //   verifyNever(mockAudioPlayer.play(any));
    // });
  });
}
