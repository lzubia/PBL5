import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
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

  tearDown(() {
    // Dispose of all ChangeNotifiers (if necessary)
    mockLocaleProvider.dispose();
    mockThemeProvider.dispose();
    mockPictureService.dispose();
    mockMapProvider.dispose();
    mockVoiceCommands.dispose();
    mockWidgetStateProvider.dispose();

    // Reset all mocks
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

    // Forcefully reset WidgetsBinding to clear any lingering state
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Future<void> pumpMainApp(WidgetTester tester) async {
    // Reset the WidgetsBinding to ensure clean state
    TestWidgetsFlutterBinding.ensureInitialized();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider(create: (_) => mockAppInitializer),
          ChangeNotifierProvider<LocaleProvider>.value(
              value: mockLocaleProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
          ChangeNotifierProvider<PictureService>.value(
              value: mockPictureService),
          ChangeNotifierProvider<MapProvider>.value(value: mockMapProvider),
          ChangeNotifierProvider<VoiceCommands>.value(value: mockVoiceCommands),
          Provider<DatabaseHelper>.value(value: mockDatabaseHelper),
          Provider<ITtsService>.value(value: mockTtsServiceGoogle),
          ChangeNotifierProvider<WidgetStateProvider>.value(
            value: mockWidgetStateProvider,
          ),
        ],
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<VoiceCommands>().initialize(context);
            });
            return const MyApp();
          },
        ),
      ),
    );

    // Ensure all async tasks, animations, and post-frame callbacks are resolved
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  testWidgets('should display the app title in AppBar',
      (WidgetTester tester) async {
    await pumpMainApp(tester);

    expect(find.text('BEGIA'), findsOneWidget);
  });

  // testWidgets('should display the settings button in AppBar',
  //     (WidgetTester tester) async {
  //   await pumpMainApp(tester);

  //   expect(find.byKey(const Key('settingsButton')), findsOneWidget);
  // });

  // testWidgets('should navigate to SettingsScreen on settings button tap',
  //     (WidgetTester tester) async {
  //   await pumpMainApp(tester);

  //   await tester.tap(find.byKey(const Key('settingsButton')));
  //   await tester.pumpAndSettle();

  //   expect(find.byType(SettingsScreen), findsOneWidget);
  // });

  // testWidgets('should display RiskDetection widget',
  //     (WidgetTester tester) async {
  //   await pumpMainApp(tester);

  //   expect(find.byType(RiskDetection), findsOneWidget);
  // });

  // testWidgets('should display GridMenu widget', (WidgetTester tester) async {
  //   await pumpMainApp(tester);

  //   expect(find.byType(GridMenu), findsOneWidget);
  // });

  // testWidgets('should display the camera status', (WidgetTester tester) async {
  //   await pumpMainApp(tester);

  //   expect(find.text('Camera: Enabled'), findsOneWidget);
  // });

  // testWidgets('should toggle voice control switch',
  //     (WidgetTester tester) async {
  //   await pumpMainApp(tester);

  //   final switchFinder = find.byKey(const Key('voiceControlSwitch'));

  //   expect(switchFinder, findsOneWidget);

  //   await tester.tap(switchFinder);
  //   verify(mockVoiceCommands.toggleActivation(any)).called(1);
  // });
}
