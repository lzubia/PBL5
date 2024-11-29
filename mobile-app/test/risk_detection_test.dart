import 'package:flutter/material.dart';
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
    });

    testWidgets('shows CircularProgressIndicator while initializing', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: RiskDetection(camera: mockCameraDescription),
      ));

      // Verify loading indicator is shown initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders UI after initialization', (WidgetTester tester) async {
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