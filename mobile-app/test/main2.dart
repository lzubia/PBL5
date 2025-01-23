import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';
import 'package:provider/provider.dart';
import 'package:pbl5_menu/main.dart';
import 'package:pbl5_menu/features/settings_screen.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/shared/database_helper.dart';
import 'package:pbl5_menu/locale_provider.dart';
import 'package:pbl5_menu/theme_provider.dart';
import 'package:pbl5_menu/map_provider.dart';
import 'package:pbl5_menu/features/voice_commands.dart';
import 'package:pbl5_menu/widgetState_provider.dart';
import 'package:pbl5_menu/app_initializer.dart';

import 'main_test.mocks.dart';

@GenerateMocks([AppInitializer, PictureService, VoiceCommands, DatabaseHelper, LocaleProvider, ThemeProvider, MapProvider, WidgetStateProvider])
class UiAndNavigationTests {
  late MockAppInitializer mockAppInitializer;
  late MockPictureService mockPictureService;
  late MockVoiceCommands mockVoiceCommands;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockLocaleProvider mockLocaleProvider;
  late MockThemeProvider mockThemeProvider;
  late MockMapProvider mockMapProvider;
  late MockWidgetStateProvider mockWidgetStateProvider;

  void setUp() {
    mockAppInitializer = MockAppInitializer();
    mockPictureService = MockPictureService();
    mockVoiceCommands = MockVoiceCommands();
    mockDatabaseHelper = MockDatabaseHelper();
    mockLocaleProvider = MockLocaleProvider();
    mockThemeProvider = MockThemeProvider();
    mockMapProvider = MockMapProvider();
    mockWidgetStateProvider = MockWidgetStateProvider();

    when(mockVoiceCommands.isActivated).thenReturn(false);
    when(mockVoiceCommands.triggerVariable).thenReturn(0);
  }

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
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  void runTests() {
    testWidgets('should navigate to Settings Screen on settings button press', (WidgetTester tester) async {
      await pumpMainApp(tester);
      final settingsButton = find.byKey(const Key('settingsButton'));
      expect(settingsButton, findsOneWidget);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  }

  void tearDown() {
    reset(mockAppInitializer);
    reset(mockPictureService);
    reset(mockVoiceCommands);
    reset(mockDatabaseHelper);
    reset(mockLocaleProvider);
    reset(mockThemeProvider);
    reset(mockMapProvider);
    reset(mockWidgetStateProvider);
  }
}
