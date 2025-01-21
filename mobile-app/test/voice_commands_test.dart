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
    when(mockTtsService.speakLabels(any))
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
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      if (mockAssetBundle._mockAssets.containsKey(key)) {
        return ByteData.view(
            Uint8List.fromList(utf8.encode(mockAssetBundle._mockAssets[key]!))
                .buffer);
      }
      return null;
    });
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

    test('handleCommand processes risk_detection_command', () async {
      final voiceCommands = VoiceCommands(
        mockSttService,
        audioPlayer: mockAudioPlayer, // Inject mocked AudioPlayer
      )
        ..ttsServiceGoogle = mockTtsService
        ..sttService = mockSttService;

      voiceCommands.voiceCommands['risk_detection_command'] = [
        'start risk detection'
      ];
      voiceCommands.handleCommand('start risk detection');

      expect(voiceCommands.riskTrigger, isTrue);
      verifyNever(mockTtsService.speakLabels(any));
    });

    test('handleCommand processes menu_command and speaks labels', () async {
      final mockLocalizations = MockAppLocalizations();
      when(mockLocalizations.translate(any)).thenAnswer((invocation) {
        final key = invocation.positionalArguments.first;
        if (key == "menu") return "Test Menu"; // Mocked translation for "menu"
        return key;
      });

      final voiceCommands = VoiceCommands(
        mockSttService,
        audioPlayer: mockAudioPlayer,
        appLocalizations: mockLocalizations,
      )
        ..ttsServiceGoogle = mockTtsService
        ..sttService = mockSttService // Manually initialize sttService
        ..widgetStateProvider =
            mockWidgetStateProvider; // Manually initialize widgetStateProvider

      // Add the mocked voice command
      voiceCommands.voiceCommands['menu_command'] = ['open menu'];

      // Execute the command
      voiceCommands.handleCommand('open menu');

      // Verify that the TTS service was called with the correct label
      verify(mockTtsService.speakLabels(['Test Menu'])).called(1);
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

    // test('triggerVariable updates for money_identifier_command', () async {
    //   final voiceCommands = VoiceCommands(
    //     mockSttService,
    //     audioPlayer: mockAudioPlayer,
    //   )
    //     ..ttsServiceGoogle = mockTtsService
    //     ..sttService = mockSttService // Manually initialize sttService
    //     ..widgetStateProvider =
    //         mockWidgetStateProvider; // Manually initialize widgetStateProvider

    //   // Mock the behavior of `getWidgetState` to return false (i.e., widget is not active)
    //   when(mockWidgetStateProvider.getWidgetState('Money Identifier'))
    //       .thenReturn(false);

    //   // Add the mocked voice command
    //   voiceCommands.voiceCommands['money_identifier_command'] = [
    //     'identify money'
    //   ];

    //   // Execute the command
    //   voiceCommands.handleCommand('identify money');

    //   // Check if `triggerVariable` is updated correctly
    //   expect(voiceCommands.triggerVariable, 1);

    //   // Verify that `setWidgetState` was called to activate the Money Identifier widget
    //   verify(mockWidgetStateProvider.setWidgetState('Money Identifier', true))
    //       .called(1);

    //   // Delay to allow `Future.delayed` inside `handleCommand` to reset the value
    //   await Future.delayed(const Duration(seconds: 2));

    //   // Ensure `triggerVariable` resets to 0 after the delay
    //   expect(voiceCommands.triggerVariable, 0);
    // });

    test('calculateSimilarity returns correct similarity value', () {
      final voiceCommands = VoiceCommands(
        mockSttService,
        audioPlayer: mockAudioPlayer,
      );

      final similarity =
          voiceCommands.calculateSimilarity('hello', 'hello world');
      expect(similarity, greaterThan(0));
    });

    test('levenshteinDistance calculates correct distance', () {
      final voiceCommands = VoiceCommands(
        mockSttService,
        audioPlayer: mockAudioPlayer,
      );

      final distance = voiceCommands.levenshteinDistance('kitten', 'sitting');
      expect(distance, 3);
    });
  });
}
