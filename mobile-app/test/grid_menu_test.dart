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
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:pbl5_menu/services/sos.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/shared/database_helper.dart';
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
      case 'opened':
        return 'Opened';
      case 'going-home':
        return 'Going Home';
      case 'home-not-set':
        return 'Home not set';
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
  MapProvider,
  SosService,
  DatabaseHelper,
  ITtsService,
  VoiceCommands,
])
void main() {
  late MockPictureService mockPictureService;
  late MockMapProvider mockMapProvider;
  late MockSosService mockSosService;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockITtsService mockTtsService;
  late MockVoiceCommands mockVoiceCommands;

  setUp(() {
    mockPictureService = MockPictureService();
    mockMapProvider = MockMapProvider();
    mockSosService = MockSosService();
    mockDatabaseHelper = MockDatabaseHelper();
    mockTtsService = MockITtsService();
    mockVoiceCommands = MockVoiceCommands();

    when(mockPictureService.isCameraInitialized).thenReturn(true);
    when(mockPictureService.getCameraPreview())
        .thenAnswer((_) => const SizedBox());
    when(mockMapProvider.polylineCoordinates).thenReturn([]);
    when(mockMapProvider.destination).thenReturn(LatLng(1.0, 1.0));
    when(mockMapProvider.isLoading).thenReturn(false); // Add this stub
    when(mockMapProvider.currentLocation)
        .thenReturn(LocationData.fromMap({'latitude': 37.7749, 'longitude': -122.4194})); // Stub currentLocation
    when(mockDatabaseHelper.getContacts()).thenAnswer((_) async => [
          {'name': 'Test Contact', 'phone': '123456'},
        ]);
    when(mockDatabaseHelper.getHomeLocation())
        .thenAnswer((_) async => LatLng(10.0, 20.0));
    when(mockVoiceCommands.triggerVariable)
        .thenReturn(0); // Stub triggerVariable
  });

  Future<void> pumpGridMenu(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PictureService>.value(
            value: mockPictureService,
          ),
          ChangeNotifierProvider<MapProvider>.value(value: mockMapProvider),
          ChangeNotifierProvider<VoiceCommands>.value(value: mockVoiceCommands),
          Provider<DatabaseHelper>.value(value: mockDatabaseHelper),
          Provider<ITtsService>.value(value: mockTtsService),
          Provider<SosService>.value(value: mockSosService),
        ],
        child: MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            MockAppLocalizationsDelegate(MockAppLocalizations()),
          ],
          supportedLocales: const [Locale('en', 'US')],
          home: const GridMenu(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('should display all menu options', (WidgetTester tester) async {
    await pumpGridMenu(tester);
    expect(find.byIcon(Icons.description), findsOneWidget);
    expect(find.byIcon(Icons.map), findsOneWidget);
    expect(find.byIcon(Icons.attach_money), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
  });

  testWidgets('should open bottom sheet for Describe Environment',
      (WidgetTester tester) async {
    await pumpGridMenu(tester);
    await tester.tap(find.byIcon(Icons.description));
    await tester.pumpAndSettle(
        const Duration(seconds: 2)); // Ensure bottom sheet renders
    print(
        find.byType(DescribeEnvironment).evaluate().toList()); // Debugging line
    expect(find.byType(DescribeEnvironment), findsOneWidget);
  });

  testWidgets('should open bottom sheet for GPS (Map)',
      (WidgetTester tester) async {
    await pumpGridMenu(tester);

    // Tap the button for the GPS (Map) menu option
    await tester.tap(find.byIcon(Icons.map));
    await tester
        .pumpAndSettle(const Duration(seconds: 2)); // Wait for rendering

    // Debugging line to print widget tree
    print(find.byType(MapWidget).evaluate().toList());

    // Check if the MapWidget exists
    expect(find.byType(MapWidget), findsOneWidget);
  });

  // testWidgets('should open bottom sheet for Money Identifier',
  //     (WidgetTester tester) async {
  //   await pumpGridMenu(tester);
  //   await tester.tap(find.byIcon(Icons.attach_money));
  //   await tester.pumpAndSettle();
  //   await tester.pump(const Duration(seconds: 1)); // Add delay
  //   expect(find.byType(MoneyIdentifier), findsOneWidget);
  // });

  // testWidgets('should open bottom sheet for Scanner',
  //     (WidgetTester tester) async {
  //   await pumpGridMenu(tester);
  //   await tester.tap(find.byIcon(Icons.qr_code_scanner));
  //   await tester.pumpAndSettle();
  //   await tester.pump(const Duration(seconds: 1)); // Add delay
  //   expect(find.byType(OcrWidget), findsOneWidget);
  // });

  // testWidgets('should handle SOS command', (WidgetTester tester) async {
  //   await pumpGridMenu(tester);
  //   mockVoiceCommands.onSosCommand?.call();
  //   await tester.pumpAndSettle();
  //   verify(mockDatabaseHelper.getContacts()).called(1);
  //   verify(mockSosService.sendSosRequest(any, any)).called(1);
  // });
}
