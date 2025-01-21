// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:pbl5_menu/features/grid_menu.dart';
// import 'package:pbl5_menu/features/map_widget.dart';
// import 'package:pbl5_menu/features/ocr_widget.dart';
// import 'package:pbl5_menu/features/describe_environment.dart';
// import 'package:pbl5_menu/features/money_identifier.dart';
// import 'package:pbl5_menu/services/picture_service.dart';
// import 'package:pbl5_menu/services/l10n.dart';
// import 'package:pbl5_menu/services/stt/stt_service.dart';
// import 'package:pbl5_menu/services/tts/tts_service_google.dart';

// import 'grid_menu_test.mocks.dart';

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

//     // Provide stubs for the methods that will be called
//     when(mockPictureService.isCameraInitialized).thenReturn(true);
//   });

//   Future<void> pumpGridMenu(WidgetTester tester) async {
//     await tester.pumpWidget(MaterialApp(
//       localizationsDelegates: [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//       ],
//       supportedLocales: const [
//         Locale('en', 'US'),
//         Locale('es', 'ES'),
//         Locale('eu', 'ES'),
//       ],
//       home: GridMenu(
//         pictureService: mockPictureService,
//         ttsService: mockTtsService,
//         sessionToken: 'testSessionToken',
//         moneyIdentifierKey: GlobalKey<MoneyIdentifierState>(),
//         describeEnvironmentKey: GlobalKey<DescribeEnvironmentState>(),
//         ocrWidgetKey: GlobalKey<OcrWidgetState>(),
//         mapKey: GlobalKey<MapWidgetState>(),
//       ),
//     ));

//     await tester.pumpAndSettle();
//   }

//   testWidgets('should display all menu options', (WidgetTester tester) async {
//     await pumpGridMenu(tester);

//     expect(find.text('Describe Environment'), findsOneWidget);
//     expect(find.text('GPS (Map)'), findsOneWidget);
//     expect(find.text('Money Identifier'), findsOneWidget);
//     expect(find.text('Scanner (Read Texts, QRs, ...)'), findsOneWidget);
//   });

//   // testWidgets('should open bottom sheet for Describe Environment', (WidgetTester tester) async {
//   //   await pumpGridMenu(tester);

//   //   await tester.tap(find.text('Describe Environment'));
//   //   await tester.pumpAndSettle();

//   //   expect(find.byType(DescribeEnvironment), findsOneWidget);
//   // });

//   // testWidgets('should open bottom sheet for GPS (Map)',
//   //     (WidgetTester tester) async {
//   //   await pumpGridMenu(tester);

//   //   await tester.tap(find.text('GPS (Map)'));
//   //   await tester.pumpAndSettle();

//   //   expect(find.byType(MapWidget), findsOneWidget);
//   // });

//   // testWidgets('should open bottom sheet for Money Identifier',
//   //     (WidgetTester tester) async {
//   //   await pumpGridMenu(tester);

//   //   await tester.tap(find.text('Money Identifier'));
//   //   await tester.pumpAndSettle();

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

//   //   expect(find.byType(CircularProgressIndicator), findsWidgets);
//   // });
// }
