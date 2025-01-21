// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:pbl5_menu/features/risk_detection.dart';
// import 'package:pbl5_menu/services/l10n.dart';
// import 'package:pbl5_menu/services/picture_service.dart';
// import 'package:pbl5_menu/services/stt/i_tts_service.dart';
// import 'package:pbl5_menu/services/stt/i_stt_service.dart';

// import 'risk_detection_test.mocks.dart';

// @GenerateMocks([PictureService, ITtsService, ISttService])
// void main() {
//   late MockPictureService mockPictureService;
//   late MockITtsService mockTtsService;
//   late MockISttService mockSttService;

//   setUp(() {
//     mockPictureService = MockPictureService();
//     mockTtsService = MockITtsService();
//     mockSttService = MockISttService();

//     when(mockPictureService.isCameraInitialized).thenReturn(true);
//   });

//   testWidgets('should display widgets when camera is initialized',
//       (WidgetTester tester) async {
//     when(mockPictureService.isCameraInitialized).thenReturn(true);

//     await tester.pumpWidget(MaterialApp(
//       home: RiskDetection(
//         pictureService: mockPictureService,
//         ttsService: mockTtsService,
//         sttService: mockSttService,
//         sessionToken: 'testSessionToken',
//       ),
//     ));

//     expect(find.byType(Switch), findsOneWidget);
//     expect(find.byIcon(Icons.warning), findsOneWidget);
//   });

//   testWidgets('should enable risk detection when switch is turned on',
//       (WidgetTester tester) async {
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
//       home: RiskDetection(
//         pictureService: mockPictureService,
//         ttsService: mockTtsService,
//         sttService: mockSttService,
//         sessionToken: 'testSessionToken',
//       ),
//     ));

//     await tester.pumpAndSettle();

//     await tester.tap(find.byType(Switch));
//     await tester.pump();

//     verify(mockTtsService.speakLabels(["Risk detection on"])).called(1);
//     expect(find.byType(Switch), findsOneWidget);
//   });

//   // testWidgets('should disable risk detection when switch is turned off',
//   //     (WidgetTester tester) async {
//   //   await tester.pumpWidget(MaterialApp(
//   //     localizationsDelegates: [
//   //       AppLocalizations.delegate,
//   //       GlobalMaterialLocalizations.delegate,
//   //       GlobalCupertinoLocalizations.delegate,
//   //       GlobalWidgetsLocalizations.delegate,
//   //     ],
//   //     supportedLocales: const [
//   //       Locale('en', 'US'),
//   //       Locale('es', 'ES'),
//   //       Locale('eu', 'ES'),
//   //     ],
//   //     home: RiskDetection(
//   //       pictureService: mockPictureService,
//   //       ttsService: mockTtsService,
//   //       sttService: mockSttService,
//   //       sessionToken: 'testSessionToken',
//   //     ),
//   //   ));

//   //   // Ensure the widget tree is fully built
//   //   await tester.pumpAndSettle();

//   //   // Tap the switch to turn it on
//   //   await tester.tap(find.byType(Switch));
//   //   await tester.pumpAndSettle();

//   //   // Tap the switch again to turn it off
//   //   await tester.tap(find.byType(Switch));
//   //   await tester.pumpAndSettle();

//   //   verify(mockTtsService.speakLabels(["Risk detection off"])).called(1);
//   //   expect(find.byType(Switch), findsOneWidget);
//   // });
// }
