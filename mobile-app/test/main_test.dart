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
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock any required dependencies
    when(mockLocaleProvider.currentLocale).thenReturn(const Locale('en', 'US'));
    when(mockLocaleProvider.supportedLocales).thenReturn([
      const Locale('en', 'US'),
      const Locale('es', 'ES'),
      const Locale('eu', 'ES'),
    ]);
    when(mockPictureService.isCameraInitialized).thenReturn(true);

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
        child: const MyApp(),
      ),
    );

    // Pump until all async tasks, animations, and post-frame callbacks are complete
    await tester.pumpAndSettle();
  }

  testWidgets('should display the app title in AppBar',
      (WidgetTester tester) async {
    await pumpMainApp(tester);

    expect(find.text('BEGIA'), findsOneWidget);
  });

  // testWidgets('should display the settings button in AppBar',
  //     (WidgetTester tester) async {
  //   await pumpMainApp(tester);

  //   expect(find.byKey(const Key('settingsButton')),
  //       findsOneWidget); // Verify Settings Button
  // });

  // testWidgets('should navigate to SettingsScreen on settings button tap',
  //     (WidgetTester tester) async {
  //   await pumpMainApp(tester);

  //   await tester
  //       .tap(find.byKey(const Key('settingsButton'))); // Tap on settings button
  //   await tester.pumpAndSettle();

  //   expect(find.byType(SettingsScreen),
  //       findsOneWidget); // Verify SettingsScreen is loaded
  // });

  // testWidgets('should display RiskDetection widget',
  //     (WidgetTester tester) async {
  //   await pumpMainApp(tester);

  //   expect(find.byType(RiskDetection),
  //       findsOneWidget); // RiskDetection should be present
  // });

  // testWidgets('should display GridMenu widget', (WidgetTester tester) async {
  //   await pumpMainApp(tester);

  //   expect(find.byType(GridMenu), findsOneWidget); // GridMenu should be present
  // });

  // testWidgets('should display the voice control gif when enabled',
  //     (WidgetTester tester) async {
  //   VoiceCommands.useVoiceControlNotifier.value = true;

  //   await tester.runAsync(() async {
  //     await pumpMainApp(tester);
  //   });

  //   expect(find.byType(Image), findsOneWidget);
  // });

  testWidgets('should hide the voice control gif when disabled',
      (WidgetTester tester) async {
    when(mockVoiceCommands.isActivated)
        .thenReturn(false); // Mock voice control is disabled
    await pumpMainApp(tester);

    expect(find.byType(Image), findsNothing); // Verify gif is hidden
  });

  // testWidgets('should toggle voice control on double tap',
  //     (WidgetTester tester) async {
  //   await pumpMainApp(tester);

  //   // Locate the specific GestureDetector by Key
  //   final gestureDetectorFinder = find.byKey(const Key('voiceControlGesture'));
  //   expect(gestureDetectorFinder, findsOneWidget);

  //   // Simulate a double-tap
  //   await tester.tap(gestureDetectorFinder);
  //   await tester.pump(const Duration(milliseconds: 50));
  //   await tester.tap(gestureDetectorFinder);
  //   await tester.pumpAndSettle();

  //   // Verify voice control toggle is called
  //   verify(mockVoiceCommands.toggleVoiceControl()).called(1);
  // });

  // testWidgets('should display the current locale in the app',
  //     (WidgetTester tester) async {
  //   when(mockLocaleProvider.currentLocale).thenReturn(const Locale('en', 'US'));

  //   await tester.pumpWidget(
  //     MultiProvider(
  //       providers: [
  //         ChangeNotifierProvider<LocaleProvider>.value(
  //             value: mockLocaleProvider),
  //         // Add other providers if needed
  //       ],
  //       child: MaterialApp(
  //         locale: mockLocaleProvider.currentLocale,
  //         localizationsDelegates: [
  //           AppLocalizations.delegate,
  //           GlobalMaterialLocalizations.delegate,
  //           GlobalWidgetsLocalizations.delegate,
  //           GlobalCupertinoLocalizations.delegate,
  //         ],
  //         supportedLocales: mockLocaleProvider.supportedLocales,
  //         home: const MyApp(),
  //       ),
  //     ),
  //   );

  //   // Allow the widget tree to build
  //   await tester.pumpAndSettle();

  //   expect(Localizations.localeOf(tester.element(find.byType(MyApp))),
  //       const Locale('en', 'US'));
  // });

  // testWidgets('should initialize dependencies on startup',
  //     (WidgetTester tester) async {
  //   await pumpMainApp(tester);

  //   // Verify the dependencies initialized properly
  //   verify(mockAppInitializer.initialize(pictureService: mockPictureService))
  //       .called(1);
  //   verify(mockVoiceCommands.initialize(any)).called(1);
  // });

  // testWidgets(
  //     'should show a loading indicator while dependencies are initializing',
  //     (WidgetTester tester) async {
  //   // Mock initialization delay
  //   when(mockAppInitializer.initialize(pictureService: mockPictureService))
  //       .thenAnswer((_) async {
  //     await Future.delayed(const Duration(seconds: 2));
  //   });

  //   await pumpMainApp(tester);

  //   // Verify that a loading indicator is displayed
  //   expect(find.byType(CircularProgressIndicator), findsOneWidget);

  //   // Wait for initialization to complete
  //   await tester.pumpAndSettle();

  //   // Verify the loading indicator disappears
  //   expect(find.byType(CircularProgressIndicator), findsNothing);
  // });

  // testWidgets('should respect theme changes from ThemeProvider',
  //     (WidgetTester tester) async {
  //   when(mockThemeProvider.currentTheme)
  //       .thenReturn(ThemeData(brightness: Brightness.dark));
  //   await pumpMainApp(tester);

  //   // Check that MaterialApp respects the theme
  //   final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
  //   expect(materialApp.theme?.brightness, Brightness.dark);
  // });
}
