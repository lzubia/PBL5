import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';
import 'package:provider/provider.dart';
import 'package:pbl5_menu/main.dart';
import 'package:pbl5_menu/features/grid_menu.dart';
import 'package:pbl5_menu/features/risk_detection.dart';
import 'package:pbl5_menu/features/settings_screen.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/shared/database_helper.dart';
import 'package:pbl5_menu/locale_provider.dart';
import 'package:pbl5_menu/theme_provider.dart';
import 'package:pbl5_menu/map_provider.dart';
import 'package:pbl5_menu/features/voice_commands.dart';
import 'package:pbl5_menu/widgetState_provider.dart';
import 'package:pbl5_menu/app_initializer.dart';

import 'main_test.mocks.dart';

@GenerateMocks([
  AppInitializer,
  PictureService,
  SttService,
  TtsServiceGoogle,
  VoiceCommands,
  DatabaseHelper,
  LocaleProvider,
  ThemeProvider,
  MapProvider,
  WidgetStateProvider,
])
void main() {
  // Declare all mocks
  late MockAppInitializer mockAppInitializer;
  late MockPictureService mockPictureService;
  late MockSttService mockSttService;
  late MockTtsServiceGoogle mockTtsServiceGoogle;
  late MockVoiceCommands mockVoiceCommands;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockLocaleProvider mockLocaleProvider;
  late MockThemeProvider mockThemeProvider;
  late MockMapProvider mockMapProvider;
  late MockWidgetStateProvider mockWidgetStateProvider;
  

  // Set up mocks and default behaviors
  setUp(() {
    mockAppInitializer = MockAppInitializer();
    mockPictureService = MockPictureService();
    mockSttService = MockSttService();
    mockTtsServiceGoogle = MockTtsServiceGoogle();
    mockVoiceCommands = MockVoiceCommands();
    mockDatabaseHelper = MockDatabaseHelper();
    mockLocaleProvider = MockLocaleProvider();
    mockThemeProvider = MockThemeProvider();
    mockMapProvider = MockMapProvider();
    mockWidgetStateProvider = MockWidgetStateProvider();

    // Mock common behaviors
    when(mockPictureService.isCameraInitialized).thenReturn(true);
    when(mockVoiceCommands.isActivated).thenReturn(false);
    when(mockVoiceCommands.riskTrigger).thenReturn(false);
    when(mockVoiceCommands.triggerVariable).thenReturn(0);
    when(mockMapProvider.currentLocation).thenReturn(null);
    when(mockLocaleProvider.currentLocale).thenReturn(const Locale('en', 'US'));
    when(mockLocaleProvider.supportedLocales).thenReturn([
      const Locale('en', 'US'),
      const Locale('es', 'ES'),
      const Locale('eu', 'ES'),
    ]);
  });

  // Tear down and reset mocks after each test
  tearDown(() {
    reset(mockAppInitializer);
    reset(mockPictureService);
    reset(mockSttService);
    reset(mockTtsServiceGoogle);
    reset(mockVoiceCommands);
    reset(mockDatabaseHelper);
    reset(mockLocaleProvider);
    reset(mockThemeProvider);
    reset(mockMapProvider);
    reset(mockWidgetStateProvider);
  });

  // Helper function to pump the main app with mocked dependencies
  Future<void> pumpMainApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider(create: (_) => mockAppInitializer),
          ChangeNotifierProvider<LocaleProvider>.value(value: mockLocaleProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
          ChangeNotifierProvider<PictureService>.value(value: mockPictureService),
          ChangeNotifierProvider<MapProvider>.value(value: mockMapProvider),
          ChangeNotifierProvider<VoiceCommands>.value(value: mockVoiceCommands),
          Provider<DatabaseHelper>.value(value: mockDatabaseHelper),
          Provider<ITtsService>.value(value: mockTtsServiceGoogle),
          ChangeNotifierProvider<WidgetStateProvider>.value(value: mockWidgetStateProvider),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('State Management Tests', () {
    testWidgets('should initialize VoiceCommands after app starts', (WidgetTester tester) async {
      await pumpMainApp(tester);

      // Verify that the VoiceCommands is initialized after the app starts
      verify(mockVoiceCommands.initialize(any)).called(1);
    });
  });
}
