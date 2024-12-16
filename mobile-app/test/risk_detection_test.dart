import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/risk_detection.dart';
import 'package:pbl5_menu/picture_service.dart';

import 'risk_detection_test.mocks.dart';

@GenerateMocks([PictureService])
void main() {
  late MockPictureService mockPictureService;
  late dynamic mockTtsService; // Accepts either TtsService or TtsServiceGoogle

  setUp(() {
    mockPictureService = MockPictureService();
    mockTtsService = Mock(); // Mock for dynamic TtsService type
  });

  testWidgets('should display widgets when camera is initialized',
      (WidgetTester tester) async {
    when(mockPictureService.isCameraInitialized).thenReturn(true);

    await tester.pumpWidget(MaterialApp(
      home: RiskDetection(
        pictureService: mockPictureService,
        ttsService: mockTtsService,
      ),
    ));

    expect(find.byType(Switch), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsOneWidget);
  });

  testWidgets('should trigger TTS and periodic actions when switch is on',
      (WidgetTester tester) async {
    when(mockPictureService.isCameraInitialized).thenReturn(true);
    when(mockPictureService.takePicture(
      onLabelsDetected: anyNamed('onLabelsDetected'),
      onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
    )).thenAnswer((_) async {});

    await tester.pumpWidget(MaterialApp(
      home: RiskDetection(
        pictureService: mockPictureService,
        ttsService: mockTtsService,
      ),
    ));

    // Turn on the switch
    await tester.tap(find.byType(Switch));
    await tester.pump();

    // Verify `isCameraInitialized` is called
    verify(mockPictureService.isCameraInitialized).called(2);

    // Simulate the timer triggering once
    await tester.pump(const Duration(milliseconds: 1500));

    // Verify that `takePicture` was called once
    verify(mockPictureService.takePicture(
      onLabelsDetected: anyNamed('onLabelsDetected'),
      onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
    )).called(1);

    // Ensure no further interactions after this specific test
    verifyNoMoreInteractions(mockPictureService);
    verifyNoMoreInteractions(mockTtsService);
  });

  testWidgets('should update and display response time',
      (WidgetTester tester) async {
    when(mockPictureService.isCameraInitialized).thenReturn(true);

    when(mockPictureService.takePicture(
      onLabelsDetected: anyNamed('onLabelsDetected'),
      onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
    )).thenAnswer((invocation) async {
      final onResponseTimeUpdated = invocation
          .namedArguments[#onResponseTimeUpdated] as Function(Duration);
      onResponseTimeUpdated(Duration(milliseconds: 500));
    });

    await tester.pumpWidget(MaterialApp(
      home: RiskDetection(
        pictureService: mockPictureService,
        ttsService: mockTtsService,
      ),
    ));

    // Turn on the switch to start the periodic timer
    await tester.tap(find.byType(Switch));
    await tester.pump();

    // Advance time to trigger the periodic timer
    await tester.pump(const Duration(milliseconds: 1500));

    // Verify `takePicture` was called
    verify(mockPictureService.takePicture(
      onLabelsDetected: anyNamed('onLabelsDetected'),
      onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
    )).called(1);

    // Verify that the response time is displayed
    expect(find.text('Response Time: 500 ms'), findsOneWidget);
  });

  testWidgets('should cancel periodic timer when switch is turned off',
      (WidgetTester tester) async {
    when(mockPictureService.isCameraInitialized).thenReturn(true);

    await tester.pumpWidget(MaterialApp(
      home: RiskDetection(
        pictureService: mockPictureService,
        ttsService: mockTtsService,
      ),
    ));

    // Turn on the switch
    await tester.tap(find.byType(Switch));
    await tester.pump();

    // Advance time to trigger the periodic timer call
    await tester.pump(const Duration(milliseconds: 1500));

    // Verify that `takePicture` was called once when the switch was on
    verify(mockPictureService.takePicture(
      onLabelsDetected: anyNamed('onLabelsDetected'),
      onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
    )).called(1);

    // Turn off the switch
    await tester.tap(find.byType(Switch));
    await tester.pump();

    // Advance time to ensure no further periodic timer calls
    await tester.pump(const Duration(milliseconds: 1500));

    // Verify `isCameraInitialized` is called again after turning off the switch
    verify(mockPictureService.isCameraInitialized).called(3);

    // Ensure no further interactions after the switch is turned off
    verifyNoMoreInteractions(mockPictureService);
    verifyNoMoreInteractions(mockTtsService);
  });
}
