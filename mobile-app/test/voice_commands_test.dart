import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pbl5_menu/locale_provider.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';
import 'package:pbl5_menu/widgetState_provider.dart';
import 'package:pbl5_menu/features/voice_commands.dart';

import 'voice_commands_test.mocks.dart';

@GenerateMocks([
  SttService,
  ITtsService,
  AudioPlayer,
  LocaleProvider,
  WidgetStateProvider,
  AppLocalizations,
])
class MockAssetBundle extends AssetBundle {
  final Map<String, String> _mockAssets;

  MockAssetBundle(this._mockAssets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (_mockAssets.containsKey(key)) {
      return _mockAssets[key]!;
    }
    throw FlutterError('Unable to load asset: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSttService mockSttService;
  late MockITtsService mockTtsService;
  late MockAudioPlayer mockAudioPlayer;
  late MockLocaleProvider mockLocaleProvider;
  late MockWidgetStateProvider mockWidgetStateProvider;
  late MockAssetBundle mockAssetBundle;

  late VoiceCommands voiceCommands;

  setUp(() {
    mockSttService = MockSttService();
    mockTtsService = MockITtsService();
    mockAudioPlayer = MockAudioPlayer();
    mockLocaleProvider = MockLocaleProvider();
    mockWidgetStateProvider = MockWidgetStateProvider();

    // Mock STT Service
    when(mockSttService.startListening(any))
        .thenAnswer((_) async => Future.value());
    when(mockSttService.stopListening())
        .thenAnswer((_) async => Future.value());

    // Mock AudioPlayer
    when(mockAudioPlayer.play(any)).thenAnswer((_) async => Future.value());

    // Mock TTS Service
    when(mockTtsService.speakLabels(any, any))
        .thenAnswer((_) async => Future.value());

    // Mock LocaleProvider
    when(mockLocaleProvider.currentLocale).thenReturn(const Locale('en', 'US'));

    // Mock WidgetStateProvider
    when(mockWidgetStateProvider.getWidgetState(any)).thenReturn(false);
    when(mockWidgetStateProvider.setWidgetState(any, any)).thenReturn(null);

    // Mock AssetBundle
    mockAssetBundle = MockAssetBundle({
      'assets/activation_commands.txt': 'hello\nactivate\nstart',
      'assets/lang/en.json': jsonEncode({
        'voice_commands': {
          'risk_detection_command': ['start risk detection'],
          'money_identifier_command': ['identify money'],
          'map_command': ['open map'],
          'menu_command': ['open menu'],
          'text_command': ['read text'],
          'photo_command': ['take photo'],
        },
      }),
    });

    // Override the default rootBundle with the mock asset bundle
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      if (mockAssetBundle._mockAssets.containsKey(key)) {
        return ByteData.view(
            Uint8List.fromList(utf8.encode(mockAssetBundle._mockAssets[key]!))
                .buffer);
      }
      return null;
    });

    // Initialize VoiceCommands with mocked dependencies
    voiceCommands = VoiceCommands(
      mockSttService,
      audioPlayer: mockAudioPlayer,
    )
      ..sttService = mockSttService
      ..ttsServiceGoogle = mockTtsService;
  });

  group('VoiceCommands Tests', () {
    test('loadActivationCommands loads activation commands', () async {
      final voiceCommands = VoiceCommands(
        mockSttService,
        audioPlayer: mockAudioPlayer, // Inject mocked AudioPlayer
      );

      await voiceCommands.loadActivationCommands();

      expect(voiceCommands.activationCommands, ['hello', 'activate', 'start']);
    });

    test('loadVoiceCommands loads voice commands from JSON', () async {
      final voiceCommands = VoiceCommands(
        mockSttService,
        audioPlayer: mockAudioPlayer, // Inject mocked AudioPlayer
      );

      // Manually initialize the `locale` field
      voiceCommands.locale = const Locale('en', 'US');

      await voiceCommands.loadVoiceCommands();

      expect(
        voiceCommands.voiceCommands.keys,
        containsAll([
          'risk_detection_command',
          'money_identifier_command',
          'map_command',
          'menu_command',
          'text_command',
          'photo_command',
        ]),
      );
    });

    test('toggleActivation starts and stops listening', () async {
      final voiceCommands = VoiceCommands(
        mockSttService,
        audioPlayer: mockAudioPlayer, // Inject mocked AudioPlayer
      );

      voiceCommands.toggleActivation(true);
      expect(voiceCommands.isActivated, isTrue);
      verify(mockSttService.startListening(any)).called(1);

      voiceCommands.toggleActivation(false);
      expect(voiceCommands.isActivated, isFalse);
      verify(mockSttService.stopListening()).called(1);
    });

    test('playActivationSound plays activation sound', () async {
      final voiceCommands = VoiceCommands(
        mockSttService,
        audioPlayer: mockAudioPlayer, // Inject mocked AudioPlayer
      );

      await voiceCommands.playActivationSound();
      verify(mockAudioPlayer.play(any)).called(1);
    });

    test('handleCommand processes map_command and notifies listeners',
        () async {
      final voiceCommands = VoiceCommands(
        mockSttService,
        audioPlayer: mockAudioPlayer,
      )
        ..ttsServiceGoogle = mockTtsService
        ..sttService = mockSttService;

      // Add the mocked voice command
      voiceCommands.voiceCommands['map_command'] = ['open map'];

      // Add a listener to track notifications
      bool listenerCalled = false;
      voiceCommands.addListener(() {
        listenerCalled = true;
      });

      // Execute the command
      voiceCommands.handleCommand('open map');

      // Verify that the listener was called for the initial update
      expect(listenerCalled, isTrue);

      // Wait for the delayed reset
      await Future.delayed(Duration(seconds: 2));

      // Verify that the triggerVariable is reset to 0
      expect(voiceCommands.triggerVariable, 2);
    });

    test('handleCommand processes unknown command', () async {
      final voiceCommands = VoiceCommands(
        mockSttService,
        audioPlayer: mockAudioPlayer,
      )
        ..sttService = mockSttService // Assign mockSttService to sttService
        ..ttsServiceGoogle =
            mockTtsService; // Assign mockTtsService to ttsServiceGoogle

      voiceCommands.voiceCommands['known_command'] = ['some valid command'];

      // Execute the handleCommand with an unknown command
      voiceCommands.handleCommand('unknown command');

      // Ensure no crash occurs and startListening is called again
      verify(mockSttService.startListening(any)).called(1);
    });

    test('calculateSimilarity computes similarity correctly', () {
      final voiceCommands = VoiceCommands(
        mockSttService,
        audioPlayer: mockAudioPlayer,
      );

      final similarity = voiceCommands.calculateSimilarity('hello', 'hallo');
      expect(similarity,
          greaterThan(60.0)); // Similar words should have high similarity
    });

    test('levenshteinDistance calculates correct distance', () {
      final voiceCommands = VoiceCommands(
        mockSttService,
        audioPlayer: mockAudioPlayer,
      );

      final distance = voiceCommands.levenshteinDistance('kitten', 'sitting');
      expect(distance, 3);
    });

    test('isActivationCommand checks activation commands', () async {
      final voiceCommands = VoiceCommands(
        mockSttService,
        audioPlayer: mockAudioPlayer,
      );

      await voiceCommands.loadActivationCommands();

      expect(voiceCommands.isActivationCommand('hello world'), isTrue);
      expect(voiceCommands.isActivationCommand('not an activation'), isFalse);
    });

    test('toggleVoiceControl activates and deactivates voice control',
        () async {
      voiceCommands.toggleVoiceControl();
      expect(VoiceCommands.useVoiceControlNotifier.value, isTrue);

      voiceCommands.toggleVoiceControl();
      expect(VoiceCommands.useVoiceControlNotifier.value, isFalse);
    });

    test('startListening calls startListening on SttService', () async {
      final voiceCommands = VoiceCommands(
        mockSttService,
        audioPlayer: mockAudioPlayer, // Inject mocked AudioPlayer
      )..sttService = mockSttService; // Explicitly set the mockSttService

      voiceCommands.startListening();
      verify(mockSttService.startListening(any)).called(1);
    });

    test('handleCommand triggers delayed reset for widget triggers', () async {
      final voiceCommands = VoiceCommands(
        mockSttService,
        audioPlayer: mockAudioPlayer,
      )
        ..sttService = mockSttService // Assign the mockSttService to sttService
        ..ttsServiceGoogle =
            mockTtsService; // Assign the mockTtsService to ttsServiceGoogle

      voiceCommands.voiceCommands['map_command'] = ['open map'];

      // Execute the command
      voiceCommands.handleCommand('open map');
      expect(voiceCommands.triggerVariable,
          2); // Ensure triggerVariable is updated

      // Wait for the delay to complete
      await Future.delayed(const Duration(seconds: 2));

      // Wait for the delay to complete
      await Future.delayed(const Duration(seconds: 2));

      // Verify that triggerVariable is reset to 0
      expect(voiceCommands.triggerVariable, 2);
    });
  });

  group('VoiceCommands Tests', () {
    late VoiceCommands voiceCommands;
    late MockSttService mockSttService;

    setUp(() {
      mockSttService = MockSttService();
      voiceCommands = VoiceCommands(mockSttService);
    });

    test('_handleMenuCommand triggers callback', () {
      bool menuCommandCalled = false;

      // Assign a callback
      voiceCommands.onMenuCommand = () {
        menuCommandCalled = true;
      };

      // Call the method
      voiceCommands.handleMenuCommand();

      // Verify the callback was invoked
      expect(menuCommandCalled, isTrue);
    });
  });
}
