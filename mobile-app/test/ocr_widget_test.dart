import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/app_initializer.dart';
import 'package:pbl5_menu/features/ocr_widget.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:provider/provider.dart';

import 'ocr_widget_test.mocks.dart';

@GenerateMocks([PictureService, ITtsService, AppInitializer])
void main() {
  late MockPictureService mockPictureService;
  late MockITtsService mockTtsService;
  late MockAppInitializer mockAppInitializer;

  setUp(() {
    mockPictureService = MockPictureService();
    mockTtsService = MockITtsService();
    mockAppInitializer = MockAppInitializer();

    // Default mock behaviors
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

  Future<void> pumpOcrWidget(WidgetTester tester) async {
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
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US')],
          home: const Scaffold(
            body: OcrWidget(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  // testWidgets(
  //     'should display CircularProgressIndicator when camera is not initialized',
  //     (WidgetTester tester) async {
  //   // Camera is not initialized
  //   when(mockPictureService.isCameraInitialized).thenReturn(false);

  //   await pumpOcrWidget(tester);

  //   // Verify that CircularProgressIndicator is displayed
  //   expect(find.byType(CircularProgressIndicator), findsOneWidget);

  //   // Verify that getCameraPreview is not called
  //   verifyNever(mockPictureService.getCameraPreview());
  // });

  testWidgets('should display camera preview when camera is initialized',
      (WidgetTester tester) async {
    // Camera is initialized
    when(mockPictureService.isCameraInitialized).thenReturn(true);

    await pumpOcrWidget(tester);

    // Verify that the camera preview is displayed
    expect(find.byType(CircularProgressIndicator), findsNothing);
    verify(mockPictureService.getCameraPreview()).called(1);
    expect(find.byType(Container), findsOneWidget);
  });

  testWidgets('should call takeAndSendImage when button is pressed',
      (WidgetTester tester) async {
    when(mockPictureService.isCameraInitialized).thenReturn(true);

    await pumpOcrWidget(tester);

    // Ensure the button is present
    final buttonFinder = find.byType(ElevatedButton);
    expect(buttonFinder, findsOneWidget);

    // Tap the button
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Verify that takePicture was called
    verify(mockPictureService.takePicture(
      endpoint: anyNamed('endpoint'),
      onLabelsDetected: anyNamed('onLabelsDetected'),
      onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
    )).called(1);
  });

  testWidgets('should show a SnackBar with labels when labels are detected',
      (WidgetTester tester) async {
    when(mockPictureService.isCameraInitialized).thenReturn(true);

    await pumpOcrWidget(tester);

    // Trigger the button press to call takePicture
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Capture the onLabelsDetected callback
    final capturedInvocation = verify(mockPictureService.takePicture(
      endpoint: anyNamed('endpoint'),
      onLabelsDetected: captureAnyNamed('onLabelsDetected'),
      onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
    )).captured;

    final onLabelsDetected = capturedInvocation.first as Function(List<String>);

    // Invoke the callback with test labels
    const testLabels = ['Sample Text'];
    onLabelsDetected(testLabels);

    // Pump the widget tree to process the SnackBar
    await tester.pumpAndSettle();

    // Verify that the SnackBar is displayed with the correct message
    expect(find.text('Description: $testLabels'), findsOneWidget);

    // Verify that TTS is called with the correct labels
    verify(mockTtsService.speakLabels(testLabels)).called(1);
  });

  testWidgets('should show a SnackBar with response time when updated',
      (WidgetTester tester) async {
    when(mockPictureService.isCameraInitialized).thenReturn(true);

    await pumpOcrWidget(tester);

    // Trigger the button press to call takePicture
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Capture the onResponseTimeUpdated callback
    final capturedInvocation = verify(mockPictureService.takePicture(
      endpoint: anyNamed('endpoint'),
      onLabelsDetected: anyNamed('onLabelsDetected'),
      onResponseTimeUpdated: captureAnyNamed('onResponseTimeUpdated'),
    )).captured;

    final onResponseTimeUpdated = capturedInvocation.last as Function(Duration);

    // Invoke the callback with test duration
    const testDuration = Duration(milliseconds: 500);
    onResponseTimeUpdated(testDuration);

    // Pump the widget tree to process the SnackBar
    await tester.pumpAndSettle();

    // Verify that the SnackBar is displayed with the correct response time
    expect(find.text('Response time: $testDuration'), findsOneWidget);
  });
}
