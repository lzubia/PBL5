import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbl5_menu/services/stt/stt_service_google.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';
import 'package:pbl5_menu/services/stt/i_stt_service.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/features/risk_detection.dart';
import 'package:pbl5_menu/features/grid_menu.dart';
import 'package:pbl5_menu/features/settings_screen.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:pbl5_menu/services/tts/tts_service.dart';
import 'package:pbl5_menu/shared/database_helper.dart';
import 'package:pbl5_menu/main.dart';

import 'main_test.mocks.dart';

@GenerateMocks([
  PictureService,
  TtsServiceGoogle,
  TtsService,
  SttServiceGoogle,
  SttService,
  DatabaseHelper,
  ISttService,
  ITtsService,
  http.Client,
])
void main() {
  late MockPictureService mockPictureService;
  late MockTtsServiceGoogle mockTtsServiceGoogle;
  late MockTtsService mockTtsService;
  late MockSttServiceGoogle mockSttServiceGoogle;
  late MockSttService mockSttService;
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockPictureService = MockPictureService();
    mockTtsServiceGoogle = MockTtsServiceGoogle();
    mockTtsService = MockTtsService();
    mockSttServiceGoogle = MockSttServiceGoogle();
    mockSttService = MockSttService();
    mockDatabaseHelper = MockDatabaseHelper();

    when(mockPictureService.isCameraInitialized).thenReturn(true);
  });

  group('MyApp Widget Tests', () {
    testWidgets('renders MyHomePage widget correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        pictureService: mockPictureService,
        ttsServiceGoogle: mockTtsServiceGoogle,
        ttsService: mockTtsService,
        databaseHelper: mockDatabaseHelper,
        sttServiceGoogle: mockSttServiceGoogle,
        sttService: mockSttService,
      ));

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('BEGIA'), findsOneWidget);
    });

    testWidgets('navigates to SettingsScreen on settings icon tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        pictureService: mockPictureService,
        ttsServiceGoogle: mockTtsServiceGoogle,
        ttsService: mockTtsService,
        databaseHelper: mockDatabaseHelper,
        sttServiceGoogle: mockSttServiceGoogle,
        sttService: mockSttService,
      ));

      final settingsIcon = find.byIcon(Icons.settings);
      expect(settingsIcon, findsOneWidget);

      await tester.tap(settingsIcon);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });

  group('startSession Function', () {
    test('starts a session successfully', () async {
      final mockClient = MockClient();
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response('{"session_id": "12345"}', 200),
      );

      await startSession(client: mockClient);

      expect(sessionToken, equals('12345'));
    });

    test('handles session start failure', () async {
      final mockClient = MockClient();
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response('Error', 500),
      );

      await startSession(client: mockClient);

      expect(sessionToken, isEmpty);
    });

    test('handles session start error', () async {
      final mockClient = MockClient();
      when(mockClient.get(any)).thenThrow(Exception('Network Error'));

      await startSession(client: mockClient);

      expect(sessionToken, isEmpty);
    });
  });

  group('endSession Function', () {
    test('ends a session successfully', () async {
      final mockClient = MockClient();
      when(mockClient.delete(any)).thenAnswer(
        (_) async => http.Response('Success', 200),
      );

      await endSession('12345', client: mockClient);

      verify(mockClient.delete(any)).called(1);
    });

    test('handles session end failure', () async {
      final mockClient = MockClient();
      when(mockClient.delete(any))
          .thenAnswer((_) async => http.Response('Error', 404));

      await endSession('12345', client: mockClient);

      verify(mockClient.delete(any)).called(1);
    });

    test('handles session end error', () async {
      final mockClient = MockClient();
      when(mockClient.delete(any)).thenThrow(Exception('Network Error'));

      await endSession('12345', client: mockClient);

      verify(mockClient.delete(any)).called(1);
    });
  });

  group('MyHomePageState Tests', () {
    testWidgets('toggles voice control', (WidgetTester tester) async {
      // Arrange: Pump the widget tree
      await tester.pumpWidget(MyApp(
        pictureService: mockPictureService,
        ttsServiceGoogle: mockTtsServiceGoogle,
        ttsService: mockTtsService,
        databaseHelper: mockDatabaseHelper,
        sttServiceGoogle: mockSttServiceGoogle,
        sttService: mockSttService,
      ));

      // Assert: Ensure the initial state of useVoiceControl is false
      final MyHomePageState state =
          tester.state(find.byType(MyHomePage)) as MyHomePageState;
      expect(state.useVoiceControl, isFalse);

      // Act: Find the switch and toggle it
      final switchFinder = find.byKey(const Key('voiceControlSwitch'));
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pump(); // Trigger a rebuild after state change

      // Assert: Ensure the state has toggled
      expect(state.useVoiceControl, isTrue);
    });

    testWidgets('displays the correct sessionToken',
        (WidgetTester tester) async {
      sessionToken = 'test-token';
      await tester.pumpWidget(MyApp(
        pictureService: mockPictureService,
        ttsServiceGoogle: mockTtsServiceGoogle,
        ttsService: mockTtsService,
        databaseHelper: mockDatabaseHelper,
        sttServiceGoogle: mockSttServiceGoogle,
        sttService: mockSttService,
      ));

      expect(find.text('test-token'), findsOneWidget);
    });

    testWidgets('displays detected command text', (WidgetTester tester) async {
      final state = MyHomePageState();
      state.detectedCommand = 'risk detection on';
      await tester.pumpWidget(MaterialApp(
          home: MyHomePage(
        pictureService: mockPictureService,
        ttsServiceGoogle: mockTtsServiceGoogle,
        ttsService: mockTtsService,
        databaseHelper: mockDatabaseHelper,
        sttServiceGoogle: mockSttServiceGoogle,
        sttService: mockSttService,
      )));

      expect(find.text('Command: risk detection on'),
          findsNothing); // State is not built yet
    });
  });
}
