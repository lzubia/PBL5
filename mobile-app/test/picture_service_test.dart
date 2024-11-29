import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'picture_service_test.mocks.dart';


@GenerateMocks([CameraController])
void main() {
  late MockCameraController mockCameraController;

  setUp(() {
    mockCameraController = MockCameraController();
  });

  group('CameraController Tests', () {
    test('should initialize camera', () async {
      when(mockCameraController.initialize()).thenAnswer((_) async {});

      await mockCameraController.initialize();

      verify(mockCameraController.initialize()).called(1);
    });

    test('should take a picture', () async {
      when(mockCameraController.takePicture()).thenAnswer((_) async => XFile('test.jpg'));

      final result = await mockCameraController.takePicture();

      expect(result.path, 'test.jpg');
      verify(mockCameraController.takePicture()).called(1);
    });

    test('should dispose camera controller', () {
      when(mockCameraController.dispose()).thenAnswer((_) async {});

      mockCameraController.dispose();

      verify(mockCameraController.dispose()).called(1);
    });
  });
}