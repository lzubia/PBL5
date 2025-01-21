import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/features/grid_menu.dart';
import 'package:pbl5_menu/features/map_widget.dart';
import 'package:pbl5_menu/features/ocr_widget.dart';
import 'package:pbl5_menu/features/describe_environment.dart';
import 'package:pbl5_menu/features/money_identifier.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
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

// @GenerateMocks([
//   PictureService,
//   DescribeEnvironment,
//   MapWidget,
//   OcrWidget,
//   MoneyIdentifier,
//   TtsServiceGoogle,
//   SttService,
// ])
// void main() {
//   late MockPictureService mockPictureService;
//   late MockTtsServiceGoogle mockTtsService;
//   late MockSttService mockSttService;

//   setUp(() {
//     mockPictureService = MockPictureService();
//     mockTtsService = MockTtsServiceGoogle();
//     mockSttService = MockSttService();

    // Provide stubs for the methods that will be called
    when(mockPictureService.isCameraInitialized).thenReturn(true);
    when(mockPictureService.getCameraPreview())
        .thenReturn(Container()); // Stub getCameraPreview
  });

  Future<void> pumpGridMenu(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PictureService>.value(
              value: mockPictureService),
          Provider<ITtsService>.value(value: mockTtsService),
          Provider<SttService>.value(value: mockSttService),
        ],
        child: MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            MockAppLocalizationsDelegate(MockAppLocalizations()), // Mocked
          ],
          supportedLocales: const [
            Locale('en', 'US'),
          ],
          locale: const Locale('en', 'US'),
          home: const GridMenu(),
        ),
      ),
    );

    await tester.pumpAndSettle(); // Wait for the widget tree to settle
  }

//   testWidgets('should display all menu options', (WidgetTester tester) async {
//     await pumpGridMenu(tester);

//     expect(find.text('Describe Environment'), findsOneWidget);
//     expect(find.text('GPS (Map)'), findsOneWidget);
//     expect(find.text('Money Identifier'), findsOneWidget);
//     expect(find.text('Scanner (Read Texts, QRs, ...)'), findsOneWidget);
//   });

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

//   // testWidgets('should open bottom sheet for Money Identifier',
//   //     (WidgetTester tester) async {
//   //   await pumpGridMenu(tester);

  //   // Ensure the widget is visible before tapping it
  //   await tester.ensureVisible(find.text('Money Identifier'));
  //   await tester.tap(find.text('Money Identifier'));
  //   await tester.pumpAndSettle();

//   //   expect(find.byType(MoneyIdentifier), findsOneWidget);
//   // });

//   // testWidgets('should open bottom sheet for Scanner',
//   //     (WidgetTester tester) async {
//   //   await pumpGridMenu(tester);

//   //   await tester.tap(find.text('Scanner (Read Texts, QRs, ...)'));
//   //   await tester.pumpAndSettle();

//   //   expect(find.byType(OcrWidget), findsOneWidget);
//   // });

//   // testWidgets(
//   //     'should show CircularProgressIndicator if camera is not initialized',
//   //     (WidgetTester tester) async {
//   //   when(mockPictureService.isCameraInitialized).thenReturn(false);

//   //   await pumpGridMenu(tester);

  //   // Tap on a menu option to trigger the bottom sheet
  //   await tester.tap(find.text('Describe Environment'));
  //   await tester.pumpAndSettle();

  //   // Increase the timeout for pumpAndSettle
  //   await tester.pumpAndSettle(const Duration(seconds: 5));

  //   expect(find.byType(CircularProgressIndicator), findsOneWidget);
  // });
}
