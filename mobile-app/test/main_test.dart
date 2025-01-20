import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/material.dart';
import 'package:pbl5_menu/features/describe_environment.dart';
import 'package:pbl5_menu/features/grid_menu.dart';
import 'package:pbl5_menu/features/map_widget.dart';
import 'package:pbl5_menu/features/money_identifier.dart';
import 'package:pbl5_menu/features/ocr_widget.dart';
import 'package:pbl5_menu/features/risk_detection.dart';
import 'package:pbl5_menu/features/voice_commands.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';
import 'package:pbl5_menu/features/settings_screen.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:pbl5_menu/shared/database_helper.dart';
import 'package:pbl5_menu/main.dart';
import 'package:pbl5_menu/app_initializer.dart';
import 'package:pbl5_menu/locale_provider.dart';
import 'package:pbl5_menu/theme_provider.dart';
import 'package:provider/provider.dart';

import 'main_test.mocks.dart';

@GenerateMocks([
  PictureService,
  TtsServiceGoogle,
  DatabaseHelper,
  SttService,
  VoiceCommands,
  NavigatorObserver,
])
void main() {
  late MockPictureService mockPictureService;
  late MockTtsServiceGoogle mockTtsServiceGoogle;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockSttService mockSttService;
  late MockVoiceCommands mockVoiceCommands;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockPictureService = MockPictureService();
    mockTtsServiceGoogle = MockTtsServiceGoogle();
    mockDatabaseHelper = MockDatabaseHelper();
    mockSttService = MockSttService();
    mockVoiceCommands = MockVoiceCommands();
    mockNavigatorObserver = MockNavigatorObserver();

    // Mock the necessary methods
    when(mockPictureService.isCameraInitialized).thenAnswer((_) => true);
    // when(mockVoiceCommands.setContext(any, any)).thenReturn(null);
    when(mockVoiceCommands.loadVoiceCommands()).thenAnswer((_) async {});
    when(mockVoiceCommands.startListening()).thenReturn(null);
    when(mockDatabaseHelper.getPreferences()).thenAnswer((_) async => {});
  });

  // testWidgets('MyApp initializes and displays MyHomePage',
  //     (WidgetTester tester) async {
  //   await tester.pumpWidget(
  //     MultiProvider(
  //       providers: [
  //         ChangeNotifierProvider(create: (_) => LocaleProvider()),
  //         ChangeNotifierProvider(create: (_) => ThemeProvider()),
  //         ChangeNotifierProvider(create: (_) => mockVoiceCommands),
  //         ChangeNotifierProvider.value(value: mockPictureService),
  //         Provider(create: (_) => mockDatabaseHelper),
  //         Provider<ITtsService>(create: (_) => mockTtsServiceGoogle),
  //         Provider(create: (_) => AppInitializer()),
  //         Provider(create: (_) => mockSttService),
  //       ],
  //       child: const MyApp(),
  //     ),
  //   );

  //   await tester.pumpAndSettle();

  //   expect(find.byType(MyHomePage), findsOneWidget);
  // });

  // testWidgets('MyHomePage displays the correct widgets',
  //     (WidgetTester tester) async {
  //   await tester.pumpWidget(
  //     MultiProvider(
  //       providers: [
  //         ChangeNotifierProvider(create: (_) => LocaleProvider()),
  //         ChangeNotifierProvider(create: (_) => ThemeProvider()),
  //         ChangeNotifierProvider(create: (_) => mockVoiceCommands),
  //         ChangeNotifierProvider.value(value: mockPictureService),
  //         Provider(create: (_) => mockDatabaseHelper),
  //         Provider<ITtsService>(create: (_) => mockTtsServiceGoogle),
  //         Provider(create: (_) => AppInitializer()),
  //         Provider(create: (_) => mockSttService),
  //       ],
  //       child: MaterialApp(
  //         localizationsDelegates: [
  //           AppLocalizations.delegate,
  //           GlobalMaterialLocalizations.delegate,
  //           GlobalCupertinoLocalizations.delegate,
  //           GlobalWidgetsLocalizations.delegate,
  //         ],
  //         supportedLocales: const [
  //           Locale('en', 'US'),
  //           Locale('es', 'ES'),
  //           Locale('eu', 'ES'),
  //         ],
  //         home: const MyHomePage(),
  //       ),
  //     ),
  //   );

  //   await tester.pumpAndSettle();

  //   // Verify widgets
  //   expect(find.byType(RiskDetection), findsOneWidget);
  //   expect(find.byType(GridMenu), findsOneWidget);
  //   expect(find.byKey(const Key('voiceControlSwitch')), findsOneWidget);
  // });

  // testWidgets('Settings button navigates to SettingsScreen',
  //     (WidgetTester tester) async {
  //   await tester.pumpWidget(
  //     MultiProvider(
  //       providers: [
  //         ChangeNotifierProvider(create: (_) => LocaleProvider()),
  //         ChangeNotifierProvider(create: (_) => ThemeProvider()),
  //         ChangeNotifierProvider(create: (_) => mockVoiceCommands),
  //         ChangeNotifierProvider.value(value: mockPictureService),
  //         Provider(create: (_) => mockDatabaseHelper),
  //         Provider<ITtsService>(create: (_) => mockTtsServiceGoogle),
  //         Provider(create: (_) => AppInitializer()),
  //         Provider(create: (_) => mockSttService),
  //       ],
  //       child: MaterialApp(
  //         navigatorObservers: [mockNavigatorObserver], // Add the observer
  //         localizationsDelegates: [
  //           AppLocalizations.delegate, // Localization delegate
  //           GlobalMaterialLocalizations.delegate,
  //           GlobalCupertinoLocalizations.delegate,
  //           GlobalWidgetsLocalizations.delegate,
  //         ],
  //         supportedLocales: const [
  //           Locale('en', 'US'),
  //           Locale('es', 'ES'),
  //           Locale('eu', 'ES'),
  //         ],
  //         home: const MyHomePage(),
  //       ),
  //     ),
  //   );

  //   await tester.pumpAndSettle();

  //   // Tap on the settings button using the Key
  //   await tester.tap(find.byKey(const Key('settingsButton')));
  //   await tester.pumpAndSettle();

  //   // Verify navigation to SettingsScreen
  //   verify(mockNavigatorObserver.didPush(any, any)).called(1);
  //   expect(find.byType(SettingsScreen), findsOneWidget);
  // });
}
