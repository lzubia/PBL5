import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/app_initializer.dart';
import 'package:pbl5_menu/features/money_identifier.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:provider/provider.dart';

import 'money_identifier_test.mocks.dart';

@GenerateMocks([PictureService, ITtsService, AppInitializer])
void main() {
  late MockPictureService mockPictureService;
  late MockITtsService mockTtsService;
  late MockAppInitializer mockAppInitializer;

  setUp(() {
    mockPictureService = MockPictureService();
    mockTtsService = MockITtsService();
    mockAppInitializer = MockAppInitializer();

    when(mockPictureService.isCameraInitialized).thenReturn(true);
    when(mockAppInitializer.sessionToken).thenReturn('test-session-token');
    when(mockPictureService.getCameraPreview()).thenReturn(Container());
  });

  tearDown(() {
    reset(mockPictureService);
    reset(mockTtsService);
    reset(mockAppInitializer);
    clearInteractions(mockPictureService);
    clearInteractions(mockTtsService);
    clearInteractions(mockAppInitializer);
  });

  Future<void> pumpMoneyIdentifier(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PictureService>.value(
              value: mockPictureService),
          Provider<ITtsService>.value(value: mockTtsService),
          Provider<AppInitializer>.value(value: mockAppInitializer),
        ],
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('es', 'ES'),
            Locale('eu', 'ES'),
          ],
          home: Scaffold(
            // Ensure a Scaffold is present
            body: MoneyIdentifier(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  // testWidgets(
  //     'should display CircularProgressIndicator when camera is not initialized',
  //     (WidgetTester tester) async {
  //   when(mockPictureService.isCameraInitialized).thenReturn(false);

  //   await pumpMoneyIdentifier(tester);

  //   expect(find.byType(CircularProgressIndicator), findsOneWidget);
  //   verify(mockPictureService.isCameraInitialized).called(1);
  // });

  testWidgets('should display camera preview when camera is initialized',
      (WidgetTester tester) async {
    when(mockPictureService.isCameraInitialized).thenReturn(true);

    await pumpMoneyIdentifier(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    verify(mockPictureService.isCameraInitialized).called(1);
    verify(mockPictureService.getCameraPreview()).called(1);
  });

  // testWidgets('should start periodic picture-taking on init',
  //     (WidgetTester tester) async {
  //   await tester.runAsync(() async {
  //     when(mockPictureService.isCameraInitialized).thenReturn(true);

  //     await pumpMoneyIdentifier(tester);

  //     verify(mockTtsService.speakLabels(any)).called(1);

  //     final moneyIdentifierState =
  //         tester.state<MoneyIdentifierState>(find.byType(MoneyIdentifier));

  //     await moneyIdentifierState.takeAndSendImage();

  //     verify(mockPictureService.takePicture(
  //       endpoint: anyNamed('endpoint'),
  //       onLabelsDetected: anyNamed('onLabelsDetected'),
  //       onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
  //     )).called(1);

  //     moneyIdentifierState.cancelTimer();
  //   });
  // });

  // testWidgets('should update response time and show a Snackbar',
  //     (WidgetTester tester) async {
  //   await tester.runAsync(() async {
  //     when(mockPictureService.isCameraInitialized).thenReturn(true);

  //     await pumpMoneyIdentifier(tester);

  //     final moneyIdentifierState =
  //         tester.state<MoneyIdentifierState>(find.byType(MoneyIdentifier));
  //     moneyIdentifierState.setState(() {
  //       moneyIdentifierState.responseTime = const Duration(milliseconds: 500);
  //     });

  //     await tester.pump();

  //     expect(find.text('Response Time: 500 ms'), findsOneWidget);
  //   });
  // });

  // testWidgets('should detect money and show a Snackbar with labels',
  //     (WidgetTester tester) async {
  //   await tester.runAsync(() async {
  //     when(mockPictureService.isCameraInitialized).thenReturn(true);

  //     // Pump the widget
  //     await pumpMoneyIdentifier(tester);

  //     // Get the widget state
  //     final moneyIdentifierState =
  //         tester.state<MoneyIdentifierState>(find.byType(MoneyIdentifier));

  //     // Labels to simulate
  //     final labels = ['10 dollars', '20 euros'];

  //     // Call the method that triggers the mock `takePicture` function
  //     await moneyIdentifierState.takeAndSendImage();

  //     // Capture the `onLabelsDetected` callback
  //     final capturedInvocation = verify(mockPictureService.takePicture(
  //       endpoint: anyNamed('endpoint'),
  //       onLabelsDetected: captureAnyNamed('onLabelsDetected'),
  //       onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
  //     )).captured;

  //     // Ensure `onLabelsDetected` was passed to the mock
  //     final onLabelsDetected =
  //         capturedInvocation.first as Function(List<String>);

  //     // Invoke the `onLabelsDetected` callback manually with test labels
  //     onLabelsDetected(labels);

  //     // Pump the widget tree to process the callback
  //     await tester.pumpAndSettle();

  //     // Verify that TTS is called with the detected labels
  //     verify(mockTtsService.speakLabels(labels)).called(1);

  //     // Verify that the Snackbar is shown with the correct labels
  //     expect(find.text('Money Identified: [10 dollars, 20 euros]'),
  //         findsOneWidget);
  //   });
  // });
}
