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
import 'package:provider/provider.dart';

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

  group('VoiceCommands Initialization', () {
    testWidgets('initialize() loads activation and voice commands',
        (WidgetTester tester) async {
      // Mock the dependencies
      when(mockLocaleProvider.currentLocale)
          .thenReturn(const Locale('en', 'US'));
      when(mockSttService.startListening(any)).thenAnswer((_) async {});
      when(mockAudioPlayer.play(any)).thenAnswer((_) async {});

      // Wrap the test widget with the necessary providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<SttService>.value(
                value: mockSttService), // Provide SttService
            ChangeNotifierProvider<LocaleProvider>.value(
                value:
                    mockLocaleProvider), // Use ChangeNotifierProvider for LocaleProvider
            Provider<ITtsService>.value(
                value: mockTtsService), // Provide ITtsService if necessary
            Provider<AudioPlayer>.value(
                value: mockAudioPlayer), // Provide AudioPlayer if necessary
          ],
          child: Builder(
            builder: (BuildContext context) {
              return Container();
            },
          ),
        ),
      );

      // Now, use the widgetTester to get the context and pass it to initialize
      await voiceCommands.initialize(tester.element(find.byType(Container)));

      // Verify that startListening was called once
      verify(mockSttService.startListening(any)).called(1);
    });
  });

  group('VoiceCommands Activation', () {
    test('toggleActivation starts and stops listening', () async {
      voiceCommands.toggleActivation(true);
      expect(voiceCommands.isActivated, isTrue);
      verify(mockSttService.startListening(any)).called(1);

      voiceCommands.toggleActivation(false);
      expect(voiceCommands.isActivated, isFalse);
      verify(mockSttService.stopListening()).called(1);
    });

    test('playActivationSound plays activation sound', () async {
      await voiceCommands.playActivationSound();
      verify(mockAudioPlayer.play(any)).called(1);
    });
  });

  group('VoiceCommands Command Handling', () {
    test('handleCommand processes unknown command', () async {
      voiceCommands.voiceCommands['known_command'] = ['some valid command'];

      voiceCommands.handleCommand('unknown command');
      verify(mockSttService.startListening(any)).called(1);
    });
  });

  group('VoiceCommands Utilities', () {
    test('calculateSimilarity computes similarity correctly', () {
      final similarity = voiceCommands.calculateSimilarity('hello', 'hallo');
      expect(similarity, greaterThan(60.0));
    });

    test('levenshteinDistance calculates correct distance', () {
      final distance = voiceCommands.levenshteinDistance('kitten', 'sitting');
      expect(distance, 3);
    });
  });

  group('VoiceCommands Timers', () {
    test('commandTimer setter triggers notifyListeners', () {
      bool notified = false;
      voiceCommands.addListener(() {
        notified = true;
      });

      final timer = Timer(const Duration(seconds: 1), () {});
      voiceCommands.commandTimer = timer;

      expect(voiceCommands.commandTimer, equals(timer));
      expect(notified, isTrue);

      timer.cancel();
    });

    test('commandTimer getter retrieves the timer', () {
      final timer = Timer(const Duration(seconds: 1), () {});
      voiceCommands.commandTimer = timer;

      expect(voiceCommands.commandTimer, equals(timer));
      timer.cancel();
    });
  });
}
