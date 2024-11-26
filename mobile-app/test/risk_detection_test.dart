import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pbl5_menu/risk_detection.dart';
import 'dart:io';

import 'risk_detection_test.mocks.dart';

@GenerateMocks([CameraController, FlutterTts, PictureService])
void main() {
  late MockCameraController mockCameraController;
  late MockFlutterTts mockFlutterTts;
  late MockPictureService mockPictureService;

  setUp(() {
    mockCameraController = MockCameraController();
    mockFlutterTts = MockFlutterTts();
    mockPictureService = MockPictureService();
  });

  group('RiskDetection widget tests', () {
    testWidgets('Camera initialization test', (WidgetTester tester) async {
      // Mock the camera list
      when(mockCameraController.initialize()).thenAnswer((_) async {});

      await tester.pumpWidget(MaterialApp(
        home: RiskDetection(
          camera: CameraDescription(
            name: 'TestCamera',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
        ),
      ));

      // Check if the CircularProgressIndicator is shown while initializing
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Simulate camera initialization
      await tester.pumpAndSettle();

      // Check if CameraPreview is displayed after initialization
      expect(find.byType(CameraPreview), findsOneWidget);
    });

    testWidgets('Picture capture functionality test', (WidgetTester tester) async {
      when(mockCameraController.takePicture())
          .thenAnswer((_) async => XFile('/path/to/mock_image.jpg'));

      await tester.pumpWidget(MaterialApp(
        home: RiskDetection(
          camera: CameraDescription(
            name: 'TestCamera',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
        ),
      ));

      await tester.pumpAndSettle();

      // Simulate button press to capture image
      final riskDetectionState =
          tester.state<RiskDetectionState>(find.byType(RiskDetection));

      await riskDetectionState._takePicture();

      verify(mockCameraController.takePicture()).called(1);
    });

    testWidgets('Text-to-speech functionality test', (WidgetTester tester) async {
      when(mockFlutterTts.speak(any)).thenAnswer((_) async => 'Success');

      await tester.pumpWidget(MaterialApp(
        home: RiskDetection(
          camera: CameraDescription(
            name: 'TestCamera',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
        ),
      ));

      await tester.pumpAndSettle();

      final riskDetectionState =
          tester.state<RiskDetectionState>(find.byType(RiskDetection));

      await riskDetectionState._speakLabels([{'label': 'test'}]);

      verify(mockFlutterTts.speak('test')).called(1);
    });

    testWidgets('Response time update test', (WidgetTester tester) async {
      when(mockCameraController.takePicture())
          .thenAnswer((_) async => XFile('/path/to/mock_image.jpg'));

      await tester.pumpWidget(MaterialApp(
        home: RiskDetection(
          camera: CameraDescription(
            name: 'TestCamera',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
        ),
      ));

      await tester.pumpAndSettle();

      final riskDetectionState =
          tester.state<RiskDetectionState>(find.byType(RiskDetection));

      await riskDetectionState._takePicture();

      expect(riskDetectionState.responseTime, isNot(Duration.zero));
    });

    testWidgets('Switch functionality test', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: RiskDetection(
          camera: CameraDescription(
            name: 'TestCamera',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
        ),
      ));

      await tester.pumpAndSettle();

      final riskDetectionState =
          tester.state<RiskDetectionState>(find.byType(RiskDetection));

      // Initially, the switch should be off
      expect(riskDetectionState._timer?.isActive ?? false, false);

      // Toggle the switch on
      await tester.tap(find.byType(Switch));
      await tester.pump();

      // Verify the timer is active
      expect(riskDetectionState._timer?.isActive ?? false, true);

      // Toggle the switch off
      await tester.tap(find.byType(Switch));
      await tester.pump();

      // Verify the timer is inactive
      expect(riskDetectionState._timer?.isActive ?? false, false);
    });
  });
}


























































































































































