import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:pbl5_menu/features/map_widget.dart';
import 'package:pbl5_menu/features/describe_environment.dart';
import 'package:pbl5_menu/features/money_identifier.dart';
import 'package:pbl5_menu/features/ocr_widget.dart';
import 'package:pbl5_menu/features/risk_detection.dart';
import 'package:pbl5_menu/features/grid_menu.dart';
import 'package:pbl5_menu/features/voice_commands.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';
import 'package:pbl5_menu/shared/database_helper.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:pbl5_menu/app_initializer.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app_initializer_test.mocks.dart';

@GenerateMocks([
  PictureService,
  DatabaseHelper,
  TtsServiceGoogle,
  SttService,
  VoiceCommands,
  http.Client,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockPictureService mockPictureService;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockTtsServiceGoogle mockTtsServiceGoogle;
  late MockSttService mockSttService;
  late MockVoiceCommands mockVoiceCommands;
  late MockClient mockHttpClient;

  setUp(() {
    mockPictureService = MockPictureService();
    mockDatabaseHelper = MockDatabaseHelper();
    mockTtsServiceGoogle = MockTtsServiceGoogle();
    mockSttService = MockSttService();
    mockVoiceCommands = MockVoiceCommands();
    mockHttpClient = MockClient();

    // Mock the MethodChannel for AudioPlayer
    const MethodChannel('xyz.luan/audioplayers')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return null;
    });

    // Mock the MethodChannel for Camera
    const MethodChannel('plugins.flutter.io/camera')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'availableCameras') {
        return [];
      }
      return null;
    });

    // Mock the MethodChannel for SpeechToText
    const MethodChannel('plugin.csdcorp.com/speech_to_text')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'initialize') {
        return true;
      }
      return null;
    });
  });

  group('AppInitializer', () {
    test('should initialize services and dependencies correctly', () async {
      when(mockPictureService.setupCamera()).thenAnswer((_) async {});
      when(mockPictureService.initializeCamera()).thenAnswer((_) async {});
      when(mockTtsServiceGoogle.initializeTts()).thenAnswer((_) async {});
      when(mockSttService.initializeStt()).thenAnswer((_) async {});
      when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response('{"session_id": "testSession"}', 200));

      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      final appInitializer = AppInitializer();

      // Inject the mock dependencies
      appInitializer.databaseHelper = mockDatabaseHelper;
      appInitializer.ttsServiceGoogle = mockTtsServiceGoogle;
      appInitializer.sttService = mockSttService;
      appInitializer.voiceCommands = mockVoiceCommands;

      await appInitializer.initialize(pictureService: mockPictureService);

      expect(appInitializer.pictureService, isA<PictureService>());
      expect(appInitializer.databaseHelper, isA<DatabaseHelper>());
      expect(appInitializer.ttsServiceGoogle, isA<TtsServiceGoogle>());
      expect(appInitializer.sttService, isA<SttService>());
      expect(appInitializer.isInitialized, isTrue);
    });

    test('should start a session and set sessionToken', () async {
      when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response('{"session_id": "testSession"}', 200));

      final appInitializer = AppInitializer();
      await appInitializer.startSession(client: mockHttpClient);

      verify(mockHttpClient.get(any)).called(1);
      expect(appInitializer.sessionToken, equals('testSession'));
    });

    test('should handle start session failure', () async {
      when(mockHttpClient.get(any))
          .thenAnswer((_) async => http.Response('Error', 500));

      final appInitializer = AppInitializer();

      expect(
        () async => await appInitializer.startSession(client: mockHttpClient),
        throwsA(isA<Exception>()),
      );

      verify(mockHttpClient.get(any)).called(1);
      expect(appInitializer.sessionToken, equals(''));
    });

    test('should end a session and reset sessionToken', () async {
      when(mockHttpClient.delete(any))
          .thenAnswer((_) async => http.Response('Success', 200));

      final appInitializer = AppInitializer();
      await appInitializer.endSession('testSession', client: mockHttpClient);

      verify(mockHttpClient.delete(any)).called(1);
      expect(appInitializer.sessionToken, equals(''));
    });

    test('should handle end session failure', () async {
      when(mockHttpClient.delete(any))
          .thenAnswer((_) async => http.Response('Error', 500));

      final appInitializer = AppInitializer();

      expect(
        () async => await appInitializer.endSession('testSession',
            client: mockHttpClient),
        throwsA(isA<Exception>()),
      );

      verify(mockHttpClient.delete(any)).called(1);
      expect(appInitializer.sessionToken, isNot(equals('testSession')));
    });
  });
}
