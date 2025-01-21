import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/features/grid_menu.dart';
import 'package:pbl5_menu/features/map_widget.dart';
import 'package:pbl5_menu/features/ocr_widget.dart';
import 'package:pbl5_menu/features/describe_environment.dart';
import 'package:pbl5_menu/features/money_identifier.dart';
import 'package:pbl5_menu/map_provider.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/widgetState_provider.dart';
import 'package:pbl5_menu/features/voice_commands.dart';
import 'package:provider/provider.dart';

import 'grid_menu_test.mocks.dart';

class MockAppLocalizations extends AppLocalizations {
  MockAppLocalizations() : super(const Locale('en', 'US'));

  @override
  String translate(String key) {
    switch (key) {
      case 'describe_environment':
        return 'Describe Environment';
      case 'gps_map':
        return 'GPS (Map)';
      case 'money_identifier':
        return 'Money Identifier';
      case 'scanner':
        return 'Scanner (Read Texts, QRs, ...)';
      default:
        return key;
    }
  }
}

class MockAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  final MockAppLocalizations mockAppLocalizations;

  MockAppLocalizationsDelegate(this.mockAppLocalizations);

  @override
  bool isSupported(Locale locale) =>
      ['en', 'es', 'eu'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => mockAppLocalizations;

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

@GenerateMocks([
  PictureService,
  DescribeEnvironment,
  MapWidget,
  OcrWidget,
  MoneyIdentifier,
  TtsServiceGoogle,
  SttService,
  WidgetStateProvider,
  VoiceCommands,
  MapProvider, // Mock the MapProvider
])
void main() {
  late MockPictureService mockPictureService;
  late MockTtsServiceGoogle mockTtsService;
  late MockSttService mockSttService;
  late MockWidgetStateProvider mockWidgetStateProvider;
  late MockVoiceCommands mockVoiceCommands;
  late MockMapProvider mockMapProvider; // Declare the MockMapProvider

  setUp(() {
    mockPictureService = MockPictureService();
    mockTtsService = MockTtsServiceGoogle();
    mockSttService = MockSttService();
    mockWidgetStateProvider = MockWidgetStateProvider();
    mockVoiceCommands = MockVoiceCommands();
    mockMapProvider = MockMapProvider(); // Initialize the MockMapProvider

    // Stub PictureService methods
    when(mockPictureService.isCameraInitialized).thenReturn(true);
    when(mockPictureService.getCameraPreview()).thenReturn(Container());

    // Stub WidgetStateProvider and VoiceCommands
    when(mockVoiceCommands.triggerVariable).thenReturn(0);

    // Stub MapProvider properties and methods
    when(mockMapProvider.currentLocation).thenReturn(
      LocationData.fromMap({'latitude': 0.0, 'longitude': 0.0}),
    ); // Stub currentLocation

    when(mockMapProvider.polylineCoordinates)
        .thenReturn([]); // Stub polylineCoordinates

    when(mockMapProvider.destination).thenReturn(
      LatLng(1.0, 1.0),
    ); // Stub destination

    when(mockMapProvider.isLoading).thenReturn(false); // Stub isLoading
  });

  Future<void> pumpGridMenu(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PictureService>.value(
              value: mockPictureService),
          Provider<ITtsService>.value(value: mockTtsService),
          Provider<SttService>.value(value: mockSttService),
          ChangeNotifierProvider<WidgetStateProvider>.value(
              value: mockWidgetStateProvider),
          ChangeNotifierProvider<VoiceCommands>.value(value: mockVoiceCommands),
          ChangeNotifierProvider<MapProvider>.value(
              value: mockMapProvider), // Use ChangeNotifierProvider here
        ],
        child: MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            MockAppLocalizationsDelegate(MockAppLocalizations()),
          ],
          supportedLocales: const [
            Locale('en', 'US'),
          ],
          locale: const Locale('en', 'US'),
          home: const GridMenu(),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('should display all menu options', (WidgetTester tester) async {
    await pumpGridMenu(tester);

    expect(find.text('Describe Environment'), findsOneWidget);
    expect(find.text('GPS (Map)'), findsOneWidget);
    expect(find.text('Money Identifier'), findsOneWidget);
    expect(find.text('Scanner (Read Texts, QRs, ...)'), findsOneWidget);
  });

  testWidgets('should open bottom sheet for Describe Environment',
      (WidgetTester tester) async {
    await pumpGridMenu(tester);

    await tester.tap(find.text('Describe Environment'));
    await tester.pumpAndSettle();

    expect(find.byType(DescribeEnvironment), findsOneWidget);
  });

  testWidgets('should open bottom sheet for GPS (Map)',
      (WidgetTester tester) async {
    await pumpGridMenu(tester);

    await tester.tap(find.text('GPS (Map)'));
    await tester.pumpAndSettle();

    expect(find.byType(MapWidget), findsOneWidget);
  });

  testWidgets('should open bottom sheet for Money Identifier',
      (WidgetTester tester) async {
    await pumpGridMenu(tester);

    // Scroll the GridView to bring "Money Identifier" into view
    await tester.drag(find.byType(GridView), const Offset(0, -200));
    await tester.pumpAndSettle();

    // Debug the widget's layout after scrolling

    // Ensure the "Money Identifier" widget is visible
    await tester.ensureVisible(find.text('Money Identifier'));

    // Tap the "Money Identifier" widget
    await tester.tap(find.text('Money Identifier'));
    await tester.pumpAndSettle();

    // Verify that the MoneyIdentifier widget is displayed
    expect(find.byType(MoneyIdentifier), findsOneWidget);
  });

  testWidgets('should open bottom sheet for Scanner',
      (WidgetTester tester) async {
    await pumpGridMenu(tester);

    // Scroll the GridView to bring "Scanner" into view
    await tester.drag(find.byType(GridView), const Offset(0, -200));
    await tester.pumpAndSettle();

    // Ensure the "Scanner" widget is visible before tapping
    await tester.ensureVisible(find.text('Scanner (Read Texts, QRs, ...)'));

    // Tap the "Scanner" widget
    await tester.tap(find.text('Scanner (Read Texts, QRs, ...)'));
    await tester.pumpAndSettle();

    // Verify that the OcrWidget is displayed in the bottom sheet
    expect(find.byType(OcrWidget), findsOneWidget);
  });

  // testWidgets(
  //     'should show CircularProgressIndicator if camera is not initialized',
  //     (WidgetTester tester) async {
  //   // Stub the camera to be uninitialized
  //   when(mockPictureService.isCameraInitialized).thenReturn(false);

  //   // Pump the widget
  //   await pumpGridMenu(tester);

  //   // Tap on the "Describe Environment" menu option
  //   await tester.tap(find.text('Describe Environment'));

  //   // Use a custom timeout to prevent indefinite waiting
  //   await tester.pumpAndSettle(const Duration(seconds: 5));

  //   // Verify that the CircularProgressIndicator is displayed
  //   expect(find.byType(CircularProgressIndicator), findsOneWidget);
  // });
}
