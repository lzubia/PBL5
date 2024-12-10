import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/risk_detection.dart';
import 'package:pbl5_menu/picture_service.dart';
import 'package:pbl5_menu/tts_service.dart';

import 'risk_detection_test.mocks.dart';

@GenerateMocks([PictureService, TtsService])
void main() {
  late MockPictureService mockPictureService;
  late MockTtsService mockTtsService;

  setUp(() {
    mockPictureService = MockPictureService();
    mockTtsService = MockTtsService();
  });

  testWidgets('should display widgets when camera is initialized',
      (WidgetTester tester) async {
    when(mockPictureService.isCameraInitialized).thenReturn(true);

    await tester.pumpWidget(MaterialApp(
      home: RiskDetection(
          pictureService: mockPictureService, ttsService: mockTtsService),
    ));

    // Verify that widgets appear
    expect(find.byType(Switch), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsOneWidget);
  });

  testWidgets('should take picture periodically when switch is on',
      (WidgetTester tester) async {
    when(mockPictureService.isCameraInitialized).thenReturn(true);
    when(mockPictureService.takePicture(
      onLabelsDetected: anyNamed('onLabelsDetected'),
      onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
    )).thenAnswer((_) async {});

    await tester.pumpWidget(MaterialApp(
      home: RiskDetection(
          pictureService: mockPictureService, ttsService: mockTtsService),
    ));

    // Turn on the switch
    await tester.tap(find.byType(Switch));
    await tester.pump();

    // Verify initial call to `isCameraInitialized`
    verify(mockPictureService.isCameraInitialized).called(2);

    // Advance time to trigger the first periodic timer call
    await tester.pump(const Duration(milliseconds: 1500));

    // Verify that `takePicture` was called once
    verify(mockPictureService.takePicture(
      onLabelsDetected: anyNamed('onLabelsDetected'),
      onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
    )).called(1);

    // Ensure no further interactions at this point
    verifyNoMoreInteractions(mockPictureService);

    // Advance time again for the next interval
    await tester.pump(const Duration(milliseconds: 1500));

    // Verify `takePicture` is called one more time (total now 2)
    verify(mockPictureService.takePicture(
      onLabelsDetected: anyNamed('onLabelsDetected'),
      onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
    )).called(1); // This call checks the second invocation only.

    // Ensure no further interactions after second call
    verifyNoMoreInteractions(mockPictureService);
  });

  testWidgets('should display response time when updated',
      (WidgetTester tester) async {
    when(mockPictureService.isCameraInitialized).thenReturn(true);
    when(mockPictureService.takePicture(
      onLabelsDetected: anyNamed('onLabelsDetected'),
      onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
    )).thenAnswer((invocation) async {
      final onResponseTimeUpdated = invocation
          .namedArguments[#onResponseTimeUpdated] as Function(Duration);
      // Simulate response time update
      onResponseTimeUpdated(Duration(milliseconds: 500));
    });

    await tester.pumpWidget(MaterialApp(
      home: RiskDetection(
          pictureService: mockPictureService, ttsService: mockTtsService),
    ));

    // Turn on the switch to start the periodic timer
    await tester.tap(find.byType(Switch));
    await tester.pump();

    // Advance time to trigger the first periodic timer call
    await tester.pump(const Duration(milliseconds: 1500));

    // Verify `takePicture` is called
    verify(mockPictureService.takePicture(
      onLabelsDetected: anyNamed('onLabelsDetected'),
      onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
    )).called(1);

    // Verify that the response time is displayed
    expect(find.text('Response Time: 500 ms'), findsOneWidget);
  });
}
