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

  testWidgets('should display widgets when camera is initialized', (WidgetTester tester) async {
    when(mockPictureService.isCameraInitialized).thenReturn(true);

    await tester.pumpWidget(MaterialApp(
      home: RiskDetection(pictureService: mockPictureService, ttsService: mockTtsService),
    ));

    // Verify that widgets appear
    expect(find.byType(Switch), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsOneWidget);
  });

  testWidgets('should take picture periodically when switch is on', (WidgetTester tester) async {
    when(mockPictureService.isCameraInitialized).thenReturn(true);

    await tester.pumpWidget(MaterialApp(
      home: RiskDetection(pictureService: mockPictureService, ttsService: mockTtsService),
    ));

    // Turn on the switch
    await tester.tap(find.byType(Switch));
    await tester.pump();

    // Verify that takePicture is called periodically
    verify(mockPictureService.takePicture(
      onLabelsDetected: anyNamed('onLabelsDetected'),
      onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
    )).called(greaterThan(0));
  });
}