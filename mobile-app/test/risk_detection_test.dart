import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:pbl5_menu/risk_detection.dart';
import 'risk_detection_test.mocks.dart';

@GenerateMocks([CameraController, CameraDescription])
void main() {
  group('RiskDetection Widget Tests', () {
    late MockCameraController mockCameraController;
    late MockCameraDescription mockCameraDescription;

    setUp(() {
      mockCameraController = MockCameraController();
      mockCameraDescription = MockCameraDescription();

      when(mockCameraController.initialize()).thenAnswer((_) async {});
      when(mockCameraController.value).thenReturn(CameraValue(
        isInitialized: false,
        isRecordingVideo: false,
        isTakingPicture: false,
        isStreamingImages: false,
        isRecordingPaused: false,
        flashMode: FlashMode.off,
        exposureMode: ExposureMode.auto,
        focusMode: FocusMode.auto,
        exposurePointSupported: false,
        focusPointSupported: false,
        deviceOrientation: DeviceOrientation.portraitUp,
        description: mockCameraDescription,
      ));
      when(mockCameraController.value).thenReturn(CameraValue(
        isInitialized: true,
        isRecordingVideo: false,
        isTakingPicture: false,
        isStreamingImages: false,
        isRecordingPaused: false,
        flashMode: FlashMode.off,
        exposureMode: ExposureMode.auto,
        focusMode: FocusMode.auto,
        exposurePointSupported: false,
        focusPointSupported: false,
        deviceOrientation: DeviceOrientation.portraitUp,
        description: mockCameraDescription,
      ));
    });

    testWidgets('renders UI after initialization', (WidgetTester tester) async {
      when(mockCameraController.value).thenReturn(CameraValue(
        isInitialized: true,
        isRecordingVideo: false,
        isTakingPicture: false,
        isStreamingImages: false,
        isRecordingPaused: false,
        flashMode: FlashMode.off,
        exposureMode: ExposureMode.auto,
        focusMode: FocusMode.auto,
        exposurePointSupported: false,
        focusPointSupported: false,
        deviceOrientation: DeviceOrientation.portraitUp,
        description: mockCameraDescription,
      ));

      await tester.pumpWidget(MaterialApp(
        home: RiskDetection(camera: mockCameraDescription),
      ));

      // Simulate camera initialization complete
      await tester.pumpAndSettle();

      // Verify that widgets appear
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('renders UI after initialization', (WidgetTester tester) async {
      when(mockCameraController.value).thenReturn(CameraValue(
        isInitialized: true,
        isRecordingVideo: false,
        isTakingPicture: false,
        isStreamingImages: false,
        isRecordingPaused: false,
        flashMode: FlashMode.off,
        exposureMode: ExposureMode.auto,
        focusMode: FocusMode.auto,
        exposurePointSupported: false,
        focusPointSupported: false,
        deviceOrientation: DeviceOrientation.portraitUp,
        description: mockCameraDescription,
      ));

      await tester.pumpWidget(MaterialApp(
        home: RiskDetection(camera: mockCameraDescription),
      ));

      // Simulate camera initialization complete
      await tester.pumpAndSettle();

      // Verify that widgets appear
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });
  });
}