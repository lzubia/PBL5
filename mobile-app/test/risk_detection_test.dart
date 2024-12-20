import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/risk_detection.dart';
import 'package:pbl5_menu/picture_service.dart';
import 'package:pbl5_menu/i_tts_service.dart';
import 'package:pbl5_menu/i_stt_service.dart';

import 'risk_detection_test.mocks.dart';

@GenerateMocks([PictureService, ITtsService, ISttService])
void main() {
  late MockPictureService mockPictureService;
  late MockITtsService mockTtsService;
  late MockISttService mockSttService;

  setUp(() {
    mockPictureService = MockPictureService();
    mockTtsService = MockITtsService();
    mockSttService = MockISttService();
  });

  testWidgets('should display widgets when camera is initialized',
      (WidgetTester tester) async {
    when(mockPictureService.isCameraInitialized).thenReturn(true);

    await tester.pumpWidget(MaterialApp(
      home: RiskDetection(
        pictureService: mockPictureService,
        ttsService: mockTtsService,
        sttService: mockSttService,
      ),
    ));

    expect(find.byType(Switch), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsOneWidget);
  });

  testWidgets('should enable risk detection when switch is turned on',
      (WidgetTester tester) async {
    when(mockPictureService.isCameraInitialized).thenReturn(true);

    await tester.pumpWidget(MaterialApp(
      home: RiskDetection(
        pictureService: mockPictureService,
        ttsService: mockTtsService,
        sttService: mockSttService,
      ),
    ));

    await tester.tap(find.byType(Switch));
    await tester.pump();

    verify(mockTtsService.speakLabels(["Risk detection on"])).called(1);
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('should disable risk detection when switch is turned off',
      (WidgetTester tester) async {
    when(mockPictureService.isCameraInitialized).thenReturn(true);

    await tester.pumpWidget(MaterialApp(
      home: RiskDetection(
        pictureService: mockPictureService,
        ttsService: mockTtsService,
        sttService: mockSttService,
      ),
    ));

    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.byType(Switch));
    await tester.pump();

    verify(mockTtsService.speakLabels(["Risk detection off"])).called(1);
    expect(find.byType(Switch), findsOneWidget);
  });
}